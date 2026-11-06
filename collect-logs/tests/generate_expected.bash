#!/bin/bash
# collect-logs/tests/generate_expected.bash
# shellcheck disable=SC2154 # using -u option
set -euo pipefail

# shellcheck source=/dev/null
source list~

params=$(cat)
matches=()

while IFS= read -r line; do
  [ -z "$line" ] && continue
  read -r p name type <<< "$line"

  # Normalize path (remove leading/trailing slashes)
  p="${p#/}"
  p="${p%/}"

  if [ -z "$name" ]; then
    name=$(basename "$p")
    type="d"
  else
    name=$(basename "$name")
  fi

  # Replace wildcards with _ (same as during file creation)
  clean_name="${name//\*/_}"

  # Search for matches among directories
  for d in "${dirs[@]}"; do
    d="${d#/}"
    d="${d%/}"
    
    # Check that d is inside p and its basename matches
    if [[ "$d" == "$p" || "$d" == "$p/"* ]]; then
      if [[ "$(basename "$d")" == "$clean_name" ]]; then
        if [ -z "$type" ] || [ "$type" = "d" ]; then
          matches+=("$d/")
        fi
      fi
    fi
  done

  # Search for matches among files
  for f in "${files[@]}"; do
    f="${f#/}"
    if [[ "$f" == "$p/"* ]]; then
      if [[ "$(basename "$f")" == "$clean_name" ]]; then
        if [ -z "$type" ] || [ "$type" = "f" ]; then
          matches+=("$f")
        fi
      fi
    fi
  done
done <<< "$params"

# Output unique sorted paths
if [ ${#matches[@]} -gt 0 ]; then
  printf "%s\n" "${matches[@]}" | sort -u
fi
