#!/bin/bash
set -euo pipefail # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="dev"
TARGET_BRANCH="main"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_CHANGES=$(git status --porcelain)
CURRENT_SHA=$(git rev-parse --verify HEAD)

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$CURRENT_BRANCH" != "$SOURCE_BRANCH" ] || [ -n "$CURRENT_CHANGES" ]; then
    echo -e "Skipping deploy because current branch is $CURRENT_BRANCH or changes exist:\n$CURRENT_CHANGES."
    exit 1
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deploy)
git clone $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH

# Copy the compiled stuff here
rsync -avm \
    --include='*.html' \
    --include='*.md' \
    --include="*.css" \
    --include="*.js" \
    --include="*.jpg" \
    --include="*.png" \
    --include="*.ico" \
    --include="*.pdf" \
    --include="*.xml" \
    --include="*.txt" \
    -f 'hide,! */' \
    ../_site/ ./

# If there are no changes to the compiled out then just bail.
if git diff --quiet; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add -A .
git commit -m "Deploy to GitHub Pages: ${CURRENT_SHA}"

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH
