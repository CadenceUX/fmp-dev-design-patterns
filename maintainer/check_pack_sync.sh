#!/usr/bin/env bash
# Checks that this skill's copy of the cadenceux pack matches the published pack.
#
#   bash maintainer/check_pack_sync.sh [path-to-cadenceux-filemaker-standards-clone]
#
# With no path, it compares against the pack's main branch on GitHub. Run it before every
# release of either repo: the two copies must ship identical.
# Exit 0: identical. Exit 1: they differ (the diff is printed). Exit 2: couldn't read the pack.
set -uo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
src="${1:-}"
tmp=""
if [ -z "$src" ]; then
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  git clone -q --depth 1 https://github.com/CadenceUX/cadenceux-filemaker-standards.git "$tmp/pack" || { echo "check: couldn't clone the pack" >&2; exit 2; }
  src="$tmp/pack"
fi
[ -d "$src/standards" ] || { echo "check: no standards/ folder in $src" >&2; exit 2; }
status=0
for f in naming.md patterns.md advisory.md; do
  if ! diff -u "$src/standards/$f" "$here/references/cadenceux-pack/$f"; then status=1; fi
done
[ $status -eq 0 ] && echo "Pack copy matches: naming.md, patterns.md, advisory.md"
exit $status
