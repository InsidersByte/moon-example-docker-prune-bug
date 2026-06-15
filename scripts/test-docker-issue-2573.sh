#!/usr/bin/env bash
set -uo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

apps=(
  non-scoped-package
  non-scoped-package-moon-start
  non-scoped-package-different-name
  scoped-package
)

expected_fail="non-scoped-package"
failed=0

printf "Reproducing moonrepo/moon#2573 with Docker builds\n"

for app in "${apps[@]}"; do
  image="moon-example-docker-prune-bug:${app}"
  dockerfile="apps/${app}/Dockerfile"

  printf "\n=== Building %s ===\n" "$app"
  if ! docker build --no-cache -t "$image" -f "$dockerfile" .; then
    printf "ERROR: Docker build failed for %s\n" "$app"
    failed=1
    continue
  fi

  printf "\n=== Running %s ===\n" "$app"

  if docker run --rm "$image"; then
    exit_code=0
  else
    exit_code=$?
  fi

  if [[ "$app" == "$expected_fail" ]]; then
    if [[ "$exit_code" -eq 0 ]]; then
      printf "ERROR: %s was expected to fail but succeeded\n" "$app"
      failed=1
    else
      printf "EXPECTED FAIL: %s failed as expected\n" "$app"
    fi
  else
    if [[ "$exit_code" -ne 0 ]]; then
      printf "ERROR: %s failed unexpectedly\n" "$app"
      failed=1
    else
      printf "OK: %s succeeded\n" "$app"
    fi
  fi

done

if [[ "$failed" -ne 0 ]]; then
  printf "\nOne or more expectations failed.\n"
  exit 1
fi

printf "\nAll expected results observed.\n"
