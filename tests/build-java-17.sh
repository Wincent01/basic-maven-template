#!/usr/bin/env bash
# Run with JDK 17 (JAVA_HOME set, or java on PATH) and Copier installed.
# Builds both generated projects, including formatting, tests, and the executable jar.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
java="${JAVA_HOME:+$JAVA_HOME/bin/}java"
if ! "$java" -version 2>&1 | grep -q 'version "17\.'; then
  echo "Run this test with JDK 17 to verify the minimum supported runtime." >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

copier copy --quiet --defaults --vcs-ref HEAD -d java_version=17 "$repo" "$work/copier"
printf '\n\n\n\n17\n' | bash "$repo/new-project.sh" "$work/script"

for generator in copier script; do
  echo "Building $generator project on Java 17"
  (cd "$work/$generator" && ./mvnw --batch-mode package)
done
