#!/bin/sh
set -e

EXT_DIR="/extensions"
mkdir -p "$EXT_DIR"

# Format: "GIT_URL TARGET_DIRECTORY_NAME GIT_TAG_OR_BRANCH"
# Leave or specify 'main' / 'master' if an extension doesn't use version tags.
EXTENSIONS="
https://github.com/civilblur/youlag.git xExtension-Youlag main
"

echo "$EXTENSIONS" | while IFS=' ' read -r repo dir ref; do
  # Skip empty or whitespace-only lines
  [ -z "$repo" ] && continue

  target_path="$EXT_DIR/$dir"

  if [ -d "$target_path/.git" ]; then
    echo "Updating and switching $dir to $ref..."
    # Fetch all tags/branches and discard shallow/fetch limits
    git -C "$target_path" fetch --all --tags --prune
  else
    echo "Cloning $dir..."
    git clone "$repo" "$target_path"
  fi

  # Checkout the exact tag/branch/commit
  echo "Checking out $ref in $dir..."
  git -C "$target_path" checkout "$ref"

  # If pointing to a tracking branch (like master/main), pull latest commits
  if git -C "$target_path" symbolic-ref -q HEAD >/dev/null; then
    git -C "$target_path" pull --ff-only
  fi
done

echo "Extension sync complete."