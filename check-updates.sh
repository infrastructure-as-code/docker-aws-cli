#!/bin/bash
set -euxo pipefail

function cleanup()
{
  rm -f ~/.netrc
}

function install_deps()
{
  # Write .netrc to enable git tagging
  echo "machine github.com" > ~/.netrc
  echo "login vincetse" >> ~/.netrc
  echo "password ${GITHUB_TOKEN}" >> ~/.netrc
  echo "protocol https" >> ~/.netrc
  # Allows git commit
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

function install_latest()
{
  pip install awscli
}

function update()
{
  local latest=$(pip show awscli | grep Version | awk '{print $2}')
  local current=$(grep "ENV AWSCLI_VERSION" Dockerfile | awk '{print $3}' | sed -e 's/"//g')
  local user=$(echo ${TRAVIS_REPO_SLUG} | awk -F/ '{ print $1 }')

  # Update version and push to origin, the tag it if we find a version
  # of the AWS CLI that is different than the current version at HEAD.
  if [[ "${current}" != "${latest}" ]]; then
    git checkout -qf ${TRAVIS_BRANCH}
    git pull origin ${TRAVIS_BRANCH}
    sed -i -e "s/${current}/${latest}/" Dockerfile
    git commit -m"AWS CLI ${latest}" .
    git push origin ${TRAVIS_BRANCH}
    # create and push the tag
    git tag --annotate "${latest}" -m"AWS CLI ${latest}" --force
    git push origin "${latest}" --force
  fi
}

if [[ "${TRAVIS_BRANCH}" == "master" && "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
  # Install the latest awscli, then compare the version just cloned from
  # Github against the installed version, and updated the Dockerfile and
  # push new version if there is a new awscli version.
  trap cleanup EXIT
  install_deps
  install_latest
  update
fi
