#!/bin/bash

git diff -s --exit-code
if [[ $? != 0 ]]; then
    echo "The repository isn't clean. We won't proceed, as we don't know if we should commit those changes or not."
    exit 1
fi

BASE_TAG=${BASE_TAG:-$(git describe --tags)}
OPERATOR_VERSION=${OPERATOR_VERSION:-${BASE_TAG}}
OPERATOR_VERSION=$(echo ${OPERATOR_VERSION} | grep -Po "([\d\.]+)")
TAG=${TAG:-"v${OPERATOR_VERSION}"}
CREATED_AT=$(date -u -Isecond)

if [[ ${BASE_TAG} =~ ^release/v.[[:digit:].]+(\-.*)?$ ]]; then
    echo "Releasing ${OPERATOR_VERSION} from ${BASE_TAG}"
else
    echo "The release tag does not match the expected format: ${BASE_TAG}"
    exit 1
fi

if [ "${GH_WRITE_TOKEN}x" == "x" ]; then
    echo "The GitHub write token isn't set. Skipping release process."
    exit 1
fi

# bump the release file
echo ${OPERATOR_VERSION} > experiment.version

git diff -s --exit-code
if [[ $? == 0 ]]; then
    echo "No changes detected. Skipping."
else
    git add experiment.version

    git config user.email "juraci.experiment@kroehling.de"
    git config user.name "Experiment Release"

    git commit -qm "Release ${TAG}"
    git tag ${TAG}
    git push --repo=https://${GH_WRITE_TOKEN}@github.com/jpkrohling/experiment-github-actions-release.git --tags
    git push https://${GH_WRITE_TOKEN}@github.com/jpkrohling/experiment-github-actions-release.git refs/tags/${TAG}:master
fi
