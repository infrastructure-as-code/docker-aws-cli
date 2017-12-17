#!/bin/bash
set -euxo pipefail

function write_release_json()
{
  local tag_name=$1
  local name=$2
  cat <<END > release.json
{
  "tag_name": "${tag_name}",
  "name": "${name}",
  "draft": false,
  "prerelease": false
}
END
}

function update()
{
  local latest=$(pip2 show awscli | grep Version | awk '{print $2}')
  local current=$(grep "ENV AWSCLI_VERSION" Dockerfile | awk '{print $3}' | sed -e 's/"//g')
  local user=$(echo ${TRAVIS_REPO_SLUG} | awk F/ '{ print $1 }')

  if [[ "${current}" != "${latest}" ]]; then
    # Update version and push to origin, then create a release
    git checkout -qf ${TRAVIS_BRANCH}
    git pull origin ${TRAVIS_BRANCH}
    sed -i -e "s/${current}/${latest}/" Dockerfile
    git commit -m"AWS CLI ${latest}" .
    git push origin ${TRAVIS_BRANCH}
    # create the tag
    git tag --annotate "${latest}" -m"AWS CLI ${latest}" --force
    git push origin "${latest}" --force
    # create the release
    write_release_json "${latest}" "AWS CLI "${latest}"
    curl --request POST \
      --header "Content-Type: application/json" \
      --user "${user}:${GITHUB_TOKEN}" \
      --data '@release.json' \
      "https://github.com/repos/${TRAVIS_REPO_SLUG}/releases
  fi
}

if [[ "${TRAVIS_BRANCH}" == "automate-update" ]]; then
  update
fi
