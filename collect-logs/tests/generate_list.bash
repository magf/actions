#!/bin/bash
# collect-logs/tests/generate_inc.bash
set -euo pipefail

dirs=()
files=()

while IFS= read -r param; do
  [ -z "$param" ] && continue
  read -r path name type <<< "$param"

  if [ -z "$name" ]; then
    name=$(basename "$path")
    type="d"
  fi

  clean_name="${name//\*/_}"

  if [ "$type" = "f" ]; then
    files+=("$path/$clean_name")
    dirs+=("$path")
  else
    if [ "$name" = "$(basename "$path")" ]; then
      dirs+=("$path")
    else
      dirs+=("$path/$clean_name")
    fi
  fi
done

# 1. Сначала сортируем и убираем дубликаты из исходных dirs
mapfile -t dirs < <(printf "%s\n" "${dirs[@]}" | sort -u)

# 2. Потом генерируем вложенные каталоги на основе уже чистого списка
nested_dirs=()
for d in "${dirs[@]}"; do
  parent=$(dirname "$d")
  base=$(basename "$d")
  if [ "$parent" = "." ]; then
    nested_dirs+=("subdir/$base")
  else
    nested_dirs+=("$parent/subdir/$base")
  fi
done

# 3. Объединяем (для чистоты можно еще раз отсортировать, но без дублей)
all_dirs=("${dirs[@]}" "${nested_dirs[@]}")

echo "dirs=("
for d in "${all_dirs[@]}"; do printf "  %q\n" "$d"; done
echo ")"
echo "files=("
for f in "${files[@]}"; do printf "  %q\n" "$f"; done
echo ")"
