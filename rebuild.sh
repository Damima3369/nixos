#!/usr/bin/env bash
# Скрипт: scripts/rebuild.sh
# Назначение: переключить локальный git на указанную ветку репозитория с конфигурацией NixOS
#            и запустить сборку/применение конфигурации через nixos-rebuild.
#
# Особенности этой версии:
# - если запустить без указания ветки, скрипт автоматически определит текущую активную ветку и будет работать с ней
# - при ошибках, связанных с незакоммиченными изменениями или невозможностью fast-forward, скрипт предложит
#   повторить операцию с --force-git (Enter/д/да/y/yes = согласие, n/no/н/нет = отказ)
#
# Установка:
#   Сохраните файл в репозитории как scripts/rebuild-branch.sh и сделайте исполняемым:
#     chmod +x scripts/rebuild.sh
#
# Запуск:
#   ./scripts/rebuild.sh [<branch>|--branch <branch>] [--action switch|build|dry-run] [--host <flake-name>] [--remote <name>] [--no-sudo] [--force-git]
#
set -uo pipefail
IFS=$'\n\t'

# Defaults
REMOTE="origin"
ACTION="switch"         # switch | build | dry-run | iso
FORCE_GIT=false
NO_SUDO=false
HOST="acemagic-s1"      
FLAKE_PATH="."          
BRANCH=""

usage() {
  cat <<EOF
Использование: $0 [<branch> | --branch <branch>] [опции]

Если ветка не указана — будет использована текущая активная ветка git.

Опции:
  --branch, -b <branch>   имя ветки (например feature/foo или master)
  --action <switch|build|dry-run>  (default: switch)
     switch  - выполнит: sudo nixos-rebuild switch --flake .#<host>
     build   - выполнит: nixos-rebuild build  --flake .#<host>
     dry-run - покажет команду и выйдет
     iso     - соберёт ISO-образ, если конфигурация настроена для этого
  --host <name>           имя конфигурации в flake.nix (default: acemagic-s1)
  --remote <name>         git-remote (default: origin)
  --no-sudo               не использовать sudo при switch (если не требуется)
  --force-git             принудительно делать hard reset на remote/<branch> при необходимости
  -h, --help              показать это сообщение

Примеры:
  ./scripts/rebuild.sh               # использовать текущую ветку
  ./scripts/rebuild.sh feature/foo   # переключиться на local/feature/foo (или origin/feature/foo) и сделать switch
  ./scripts/rebuild.sh --branch main --action build
EOF
  exit 1
}

# Parse args (оставим для совместимости)
while [ $# -gt 0 ]; do
  case "$1" in
    --action) ACTION="$2"; shift 2;;
    --host) HOST="$2"; shift 2;;
    --remote) REMOTE="$2"; shift 2;;
    --no-sudo) NO_SUDO=true; shift;;
    --force-git) FORCE_GIT=true; shift;;
    --branch|-b) BRANCH="$2"; shift 2;;
    -h|--help) usage;;
    *) shift;;
  esac
done

if [ ! -f "${FLAKE_PATH}/flake.nix" ]; then
  echo "Ошибка: flake.nix не найден в ${FLAKE_PATH}."
  exit 2
fi

cd "${FLAKE_PATH}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Текущий каталог не git-репозиторий."
  exit 3
fi

# Определяем ветку
CURRENT_BRANCH="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [ -z "$BRANCH" ]; then
  BRANCH="$CURRENT_BRANCH"
fi

# --- УМНАЯ ПРОВЕРКА ЛОКАЛЬНЫХ ИЗМЕНЕНИЙ ---
LOCAL_CHANGES=false
if ! git diff --quiet --no-ext-diff 2>/dev/null || git status --porcelain | grep -q "^??"; then
  LOCAL_CHANGES=true
fi

SHOULD_SYNC=false

if [ "$LOCAL_CHANGES" = true ]; then
  echo "⚠️  Хозяин, я обнаружил локальные правки или новые файлы в репозитории."
  read -r -p "Хотите стянуть обновления из облака перед сборкой? [д/Н]: " ans
  ans="$(echo "${ans:-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  case "$ans" in
    д|да|y|yes)
      SHOULD_SYNC=true
      ;;
    *)
      echo ">>> Понял, облако игнорируем. Собираем локальные наработки..."
      # Регистрируем новые файлы в индексе гит, чтобы Flakes их увидели
      git add -N . 2>/dev/null || true
      ;;
  esac
else
  # Если всё чисто — синк включается автоматически без лишних вопросов
  SHOULD_SYNC=true
fi

# --- БЛОК СИНХРОНИЗАЦИИ ---
if [ "$SHOULD_SYNC" = true ]; then
  if [ "$LOCAL_CHANGES" = true ]; then
    # Сценарий 1: У пользователя есть правки, но он принудительно захотел обновиться
    echo ">>> Подключаюсь к серверу ($REMOTE)..."
    if git fetch "${REMOTE}" --prune; then
      echo "❌ Внимание! Для чистой синхронизации локальные правки будут стёрты (hard reset)."
      read -r -p "Вы уверены, что хотите затереть локальные изменения ради версии из облака? [д/Н]: " confirm
      if [[ "$confirm" =~ ^[yYдД]$ ]]; then
        if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then git checkout "${BRANCH}" || exit 8; fi
        git reset --hard "${REMOTE}/${BRANCH}" || exit 9
      else
        echo "Отмена: ухожу на локальную сборку без обновления."
        git add -N . 2>/dev/null || true
      fi
    else
      echo "⚠️  Не удалось достучаться до GitHub — собираю локальную версию."
      git add -N . 2>/dev/null || true
    fi
  else
    # Сценарий 2: Локально всё чисто, проверяем обновления молча и безболезненно
    echo ">>> Проверяю обновления в облаке..."
    if git fetch "${REMOTE}" --prune 2>/dev/null; then
      if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
        git checkout "${BRANCH}" 2>/dev/null || true
      fi
      if git merge --ff-only "${REMOTE}/${BRANCH}" 2>/dev/null; then
        echo "✨ Найдено новое в облаке, успешно обновился!"
      else
        echo "ℹ️  Обновлений нет или автоматический fast-forward невозможен. Собираю текущую копию."
      fi
    else
      echo "⚠️  Не удалось проверить облако (нет сети или GitHub недоступен). Собираю локальную версию."
    fi
  fi
fi

echo ">>> Текущий коммит-база:"
git --no-pager log -1 --oneline

# --- СБОРКА СИСТЕМЫ ---
FLAKE_REF="${FLAKE_PATH}#${HOST}"
case "$ACTION" in
  dry-run)
    echo "nixos-rebuild switch --flake ${FLAKE_REF}"
    exit 0
    ;;
  build)
    echo ">>> Выполняю: nixos-rebuild build --flake ${FLAKE_REF}"
    nixos-rebuild build --flake "${FLAKE_REF}"
    exit 0
    ;;
  switch)
    CMD=(sudo nixos-rebuild switch --flake "${FLAKE_REF}")
    echo ">>> Запускаю сборку: ${CMD[*]}"
    "${CMD[@]}"
    echo ">>> Всё готово, конфигурация успешно применена!"
    exit 0
    ;;
  iso)
    nix build "${FLAKE_REF}"
    exit 0
    ;;
esac