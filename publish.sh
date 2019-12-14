#!/bin/sh
if [ -n "$(git status -s)" ]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

# echo "Deleting old publication"
# rm -rf public
# mkdir public
# git worktree prune
# rm -rf .git/worktrees/public/

# echo "Checking out gh-pages branch into public"
# git worktree add -B gh-pages public origin/gh-pages

# echo "Removing existing files"
# rm -rf public/*

# echo "Generating site"
# hugo

# echo "Adding files"
# cp CNAME public
# cp gh-pages-README.md public/README.md

# echo "Updating master branch"
# git add --all && git commit -m "Publishing to master (publish.sh)"
# git push origin master

# echo "Updating gh-pages branch"
# cd public && git add --all && git commit -m "Publishing to gh-pages (publish.sh)"
# git push origin gh-pages