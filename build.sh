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
    sed -i -e "s/${current}/${latest}/" Dockerfile
    docker build --rm -t aws-cli .
    git commit -m"AWS CLI ${latest}" .
    git push origin ${TRAVIS_BRANCH}
  else
    docker build --rm -t aws-cli .
  fi
}

trap cleanup EXIT ERR
if [[ "${TRAVIS_BRANCH}" == "automate-update" ]]; then
  update
fi
