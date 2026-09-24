#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
flutter_bin=${FLUTTER_BIN:-flutter}
check_tmp=$(mktemp -d "${TMPDIR:-/tmp}/appleui-flutter.XXXXXX")
trap 'rm -rf "$check_tmp"' EXIT HUP INT TERM

# Check exactly what users copy, without writing caches into the skill assets.
source_dir="$repo_dir/appleui-design-pro/assets/flutter_tab_bar"
cp "$source_dir/pubspec.yaml" "$check_tmp/"
cp -R "$source_dir/lib" "$source_dir/test" "$check_tmp/"
cd "$check_tmp"
"$flutter_bin" pub get
"$flutter_bin" analyze
"$flutter_bin" test
