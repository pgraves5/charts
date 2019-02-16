#!/usr/bin/env bash

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_repo_files() {
  git add docs
  git commit -m "Update repo index and packages" -m "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git push --quiet origin master
}

setup_git
commit_repo_files
upload_files