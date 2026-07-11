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
HOST="acemagic-s1"      # <- по умолчанию, как в вашем flake.nix
FLAKE_PATH="."          # локальный flake (корень репозитория)
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

# Prompt helper: ask to retry with --force-git. Empty input = YES.
prompt_force() {
  local prompt_msg="$1"
  local ans
  read -r -p "$prompt_msg [Enter/д/да/y/yes = да, n/no/н/нет = нет]: " ans
  ans="$(echo "${ans:-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  if [ -z "$ans" ]; then
    FORCE_GIT=true
    return 0
  fi
  case "$ans" in
    д|да|y|yes) FORCE_GIT=true; return 0;;
    n|no|н|нет) return 1;;
    *) 
      # если непонятный ввод — считаем отказом
      return 1
      ;;
  esac
}

# parse args
if [ $# -eq 0 ]; then
  # ничего — оставляем BRANCH пустой, дальше автопополнение
  :
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --action)
      ACTION="$2"; shift 2;;
    --host)
      HOST="$2"; shift 2;;
    --remote)
      REMOTE="$2"; shift 2;;
    --no-sudo)
      NO_SUDO=true; shift;;
    --force-git)
      FORCE_GIT=true; shift;;
    --branch|-b)
      BRANCH="$2"; shift 2;;
    -h|--help)
      usage;;
    -*)
      # возможно позиционный - ветка указан как первый arg без ключа
      echo "Неизвестный флаг: $1"
      usage;;
    *)
      # позиционный аргумент: если BRANCH ещё не задан — присвоим
      if [ -z "$BRANCH" ]; then
        BRANCH="$1"
        shift
      else
        echo "Излишний позиционный аргумент: $1"
        usage
      fi
      ;;
  esac
done

# Ensure flake exists
if [ ! -f "${FLAKE_PATH}/flake.nix" ]; then
  echo "Ошибка: flake.nix не найден(а) в ${FLAKE_PATH}. Запустите скрипт из корня репозитория с flake.nix или измените FLAKE_PATH."
  exit 2
fi

cd "${FLAKE_PATH}"

# Check git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Текущий каталог не git-репозиторий."
  exit 3
fi

# If branch not specified, detect current branch
if [ -z "$BRANCH" ]; then
  # try to get symbolic ref short name
  BRANCH="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if [ -z "$BRANCH" ]; then
    # fallback to abbrev-ref (could return HEAD on detached)
    BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  fi
  if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
    echo "Не удалось определить текущую ветку (detached HEAD). Укажите ветку явно: --branch <name>"
    exit 7
  fi
  echo ">>> Ветка не указана: используем текущую ветку '$BRANCH'"
fi

echo ">>> Fetching remotes ($REMOTE)..."
git fetch "${REMOTE}" --prune || {
  echo "Предупреждение: не удалось выполнить git fetch ${REMOTE} — проверьте сеть/доступ."
}

# Ensure working tree cleanliness unless forced
if ! git diff --quiet --ignore-submodules --; then
  echo "Рабочее дерево содержит незакоммиченные изменения:"
  git status --porcelain
  if ! $FORCE_GIT; then
    if prompt_force "Хотите восстановить состояние в соответствии с ${REMOTE}/${BRANCH} (будет выполняться hard reset) и продолжить?"; then
      echo ">>> Продолжаем с --force-git"
    else
      echo "Отмена: закоммитьте/стэшните изменения или запустите с --force-git."
      exit 4
    fi
  else
    echo ">>> FORCE_GIT задан: выполню hard reset."
  fi
fi

# Switch/create branch and update
# If local branch exists, checkout it and update (ff or hard reset if forced)
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  echo ">>> Переключаюсь на локальную ветку ${BRANCH}"
  git checkout "${BRANCH}" || { echo "Ошибка: git checkout ${BRANCH}"; exit 8; }

  if $FORCE_GIT; then
    echo ">>> Hard reset к ${REMOTE}/${BRANCH}"
    git reset --hard "${REMOTE}/${BRANCH}" || { echo "Ошибка: git reset --hard ${REMOTE}/${BRANCH}"; exit 9; }
  else
    echo ">>> Обновляю локальную ветку ${BRANCH} (fast-forward) от ${REMOTE}/${BRANCH}"
    if git merge --ff-only "${REMOTE}/${BRANCH}"; then
      echo ">>> Fast-forward успешно выполнен."
    else
      echo "Не удалось выполнить fast-forward для ${BRANCH} от ${REMOTE}/${BRANCH}."
      if prompt_force "Повторить операцию с --force-git (hard reset к ${REMOTE}/${BRANCH})?"; then
        echo ">>> Выполняю hard reset к ${REMOTE}/${BRANCH}"
        git reset --hard "${REMOTE}/${BRANCH}" || { echo "Ошибка: git reset --hard ${REMOTE}/${BRANCH}"; exit 9; }
      else
        echo "Отмена: не выполнено обновление ветки."
        exit 5
      fi
    fi
  fi

else
  # локальной ветки нет — попробуем создать отслеживающую ветку с remote
  if git ls-remote --exit-code --heads "${REMOTE}" "${BRANCH}" >/dev/null 2>&1; then
    echo ">>> Создаю локальную ветку ${BRANCH}, отслеживающую ${REMOTE}/${BRANCH}"
    git checkout -b "${BRANCH}" --track "${REMOTE}/${BRANCH}" || { echo "Ошибка: git checkout -b --track"; exit 6; }
  else
    echo "Ветка ${BRANCH} не найдена ни локально, ни в ${REMOTE}."
    echo "Укажите существующую ветку или создайте её в удалённом репозитории."
    exit 6
  fi
fi

echo ">>> Текущий коммит:"
git --no-pager log -1 --oneline

# Build / switch
FLAKE_REF="${FLAKE_PATH}#${HOST}"
case "$ACTION" in
  dry-run)
    echo "DRY-RUN: команда, которую будет выполнена:"
    if $NO_SUDO; then
      echo "nixos-rebuild switch --flake ${FLAKE_REF}"
    else
      echo "sudo nixos-rebuild switch --flake ${FLAKE_REF}"
    fi
    exit 0
    ;;
  build)
    echo ">>> Выполняю: nixos-rebuild build --flake ${FLAKE_REF}"
    nixos-rebuild build --flake "${FLAKE_REF}"
    echo ">>> Готово: сборка в /nix/var/nix/profiles/system-*"
    exit 0
    ;;
  switch)
    if $NO_SUDO; then
      CMD=(nixos-rebuild switch --flake "${FLAKE_REF}")
    else
      CMD=(sudo nixos-rebuild switch --flake "${FLAKE_REF}")
    fi
    echo ">>> Выполняю: ${CMD[*]}"
    "${CMD[@]}"
    echo ">>> nixos-rebuild выполнен."
    exit 0
    ;;
  iso)
    echo ">>> Выполняю: nix build ${FLAKE_REF}"
    nix build "${FLAKE_REF}"
    echo ">>> Готово: сборка в result/iso"
    exit 0
    ;;
  *)
    echo "Неизвестное действие: ${ACTION}"
    usage
    ;;
esac