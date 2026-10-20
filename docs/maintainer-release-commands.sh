#!/usr/bin/env bash
# Maintainer-only helper: create a branch, commit everything and push it.
# Usage: docs/maintainer-release-commands.sh [branch] ["commit message"]
set -euo pipefail

BRANCH="${1:-chore/standardize-skills-repo}"
MESSAGE="${2:-chore: standardize and modernize enterprise skills repository}"

# Run from the repository root no matter where the script is invoked from.
cd "$(git rev-parse --show-toplevel)"

git checkout -b "${BRANCH}"
git add .
git commit -m "${MESSAGE}"
git push -u origin "${BRANCH}"