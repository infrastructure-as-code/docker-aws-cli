#!/bin/bash
set -euxo pipefail

function cleanup()
{
  rm -f ~/.netrc
}

function update()
{
  local latest=$(pip2 show awscli | grep Version | awk '{print $2}')
  local current=$(grep "ENV AWSCLI_VERSION" Dockerfile | awk '{print $3}' | sed -e 's/"//g')

  if [[ "${current}" != "${latest}" ]]; then
    git checkout -qf ${TRAVIS_BRANCH}
    git pull origin ${TRAVIS_BRANCH}
    sed -i -e "s/${current}/${latest}/" Dockerfile
    git commit -m"AWS CLI ${latest}" .
    git push origin ${TRAVIS_BRANCH}
  fi
}

trap cleanup EXIT ERR
if [[ "${TRAVIS_BRANCH}" == "automate-update" ]]; then
  update
fi
