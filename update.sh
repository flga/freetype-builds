#!/bin/sh

cd src/freetype-tip
git pull
cd ../..
if [[ ! `git status --porcelain` ]]; then
    exit
fi

git tag -d tip
git push origin :refs/tags/tip
git add src
git commit -m "update tip"
git tag tip -m tip
echo "run git push --follow-tags"