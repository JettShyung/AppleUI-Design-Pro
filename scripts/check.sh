#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skill_dir="$repo_dir/appleui-design-pro"

ruby -ryaml -rfind - "$repo_dir" "$skill_dir" <<'RUBY'
repo_dir, skill_dir = ARGV

text = File.read(File.join(skill_dir, "SKILL.md"))
frontmatter = text.split(/^---\s*$/, 3)[1]
skill = YAML.safe_load(frontmatter)
agent = YAML.safe_load(File.read(File.join(skill_dir, "agents/openai.yaml")))

abort "Missing skill name or description" unless skill["name"] && skill["description"]
abort "Skill name does not match its folder" unless skill["name"] == File.basename(skill_dir)
abort "Default prompt must mention $appleui-design-pro" unless agent.dig("interface", "default_prompt")&.include?("$appleui-design-pro")

missing = []
Find.find(repo_dir) do |path|
  next unless File.file?(path) && path.end_with?(".md")

  File.read(path).scan(/\[[^\]]*\]\(([^)]+)\)/).flatten.each do |link|
    next if link.match?(%r{^(?:https?://|mailto:|#)})

    target = link.split("#", 2).first
    next if target.empty?

    resolved = File.expand_path(target, File.dirname(path))
    missing << "#{path.delete_prefix(repo_dir + "/")}: #{link}" unless File.exist?(resolved)
  end
end
abort "Missing local Markdown links:\n#{missing.join("\n")}" unless missing.empty?

puts "Metadata and local Markdown links OK."
RUBY

if command -v node >/dev/null 2>&1; then
  node "$skill_dir/assets/displacement.test.mjs"
else
  echo "SKIP: Node.js is unavailable; displacement checks did not run."
fi

flutter_bin=${FLUTTER_BIN:-flutter}
if command -v "$flutter_bin" >/dev/null 2>&1; then
  "$repo_dir/scripts/check_flutter_tab_bar.sh"
else
  echo "SKIP: Flutter is unavailable; set FLUTTER_BIN to check the Tab Bar template."
fi

if command -v xcrun >/dev/null 2>&1; then
  check_tmp=$(mktemp -d "${TMPDIR:-/tmp}/appleui-check.XXXXXX")
  trap 'rm -rf "$check_tmp"' EXIT HUP INT TERM

  xcrun swiftc -typecheck -parse-as-library \
    -module-cache-path "$check_tmp/swift-modules" \
    "$skill_dir/assets/GlassActions.swift" \
    "$skill_dir/assets/OwnedImageLens.swift" \
    "$skill_dir/assets/StyleDrivenCard.swift"

  if xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1; then
    xcrun --sdk iphoneos swiftc -typecheck -parse-as-library \
      -target arm64-apple-ios17.0 \
      -module-cache-path "$check_tmp/swift-modules" \
      "$skill_dir/assets/GlassActions.swift" \
      "$skill_dir/assets/NativeSurfaces.swift" \
      "$skill_dir/assets/OwnedImageLens.swift" \
      "$skill_dir/assets/StyleDrivenCard.swift"
  else
    echo "SKIP: iPhoneOS SDK is unavailable; iOS type-check did not run."
  fi

  if xcrun -sdk macosx metal -v >/dev/null 2>&1; then
    xcrun -sdk macosx metal -c "$skill_dir/assets/AppleUILens.metal" \
      -o "$check_tmp/AppleUILens.air"
  else
    echo "SKIP: Metal Toolchain is unavailable; Metal compilation did not run."
  fi
else
  echo "SKIP: Xcode command-line tools are unavailable; Swift and Metal checks did not run."
fi

echo "Checks complete. Review any SKIP lines before a release."
