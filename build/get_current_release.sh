#!/usr/bin/env bash

set -e

CWD="$(dirname $0)"
cd "${CWD}"

force_success() {
    echo -n ""
}

JENKINS_FILE="./Jenkinsfile"
JENKINS_URI="https://dev-jenkins.instana.io/job/ingress-nginx-tracing"

CURR_RELEASE="$(git ls-remote --heads git@github.com:instana/backend.git 2>/dev/null \
    | grep -o "release-[0-9]\+" | cut -d '-' -f2 | sort -n | tail -n1)"

if [ -z "${CURR_RELEASE}" ]; then
    echo "Cannot determine the current Instana SaaS release." >&2
    exit 1
fi

PREV_RELEASE_LINE="$(grep "releaseNumber =.*" ${JENKINS_FILE})"
PREV_RELEASE="$(cut -d '"' -f2 <<< ${PREV_RELEASE_LINE})"

if [ "${PREV_RELEASE}" != "${CURR_RELEASE}" ]; then
    echo "Release update from ${PREV_RELEASE} to ${CURR_RELEASE} detected."
    echo "Updating release in ${JENKINS_FILE}."
    RELEASE_LINE=$(sed "s@${PREV_RELEASE}@${CURR_RELEASE}@g" <<< ${PREV_RELEASE_LINE})
    sed -i "s@${PREV_RELEASE_LINE}@${RELEASE_LINE}@g" ${JENKINS_FILE}
    echo "Go to ${JENKINS_URI}, get the latest build number," \
        "and set it in ${JENKINS_FILE} as well."
else
    echo "${CURR_RELEASE} is still latest."
fi

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab :
