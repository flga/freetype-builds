#!/bin/sh

cd src/freetype-tip
git pull
cd ../..
git tag -d tip
git push origin :refs/tags/tip
git add src
git commit -m "update tip"
git tag tip
git push --follow-tags
