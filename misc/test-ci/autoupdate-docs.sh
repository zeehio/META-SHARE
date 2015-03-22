#!/bin/bash

git config user.name "Travis-CI"
git config user.email "travis@travis-ci.org"

# Build the docs:
(cd misc/docs/ && make html)
# Move the output to gh-pages
git checkout gh-pages
# Replace the old web pages by the new ones
rm -rf dev
mv misc/docs/_build/html/ dev
git add --all dev
git commit -m "Automatic update of documentation"
#git remote add rworigin "https://${GH_AUTH}@${GH_REF}"
#git push rworigin gh-pages
git push origin gh-pages
