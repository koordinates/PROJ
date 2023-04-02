#!/usr/bin/env bash
set -eu

if which ggrep 2>/dev/null; then
    # so we can run this locally on MacOS
    # (run `brew install grep` to install this)
    GREP=ggrep
else
    GREP=grep
fi

export TIMEFORMAT='🕑 %1lR'
export DEBEMAIL=support@koordinates.com
export DEBFULLNAME="Koordinates CI Builder"

V_MAJOR="$(${GREP} -Po '(?<=#define PROJ_VERSION_MAJOR )\d' src/proj.h)"
V_MINOR="$(${GREP} -Po '(?<=#define PROJ_VERSION_MINOR )\d' src/proj.h)"
V_PATCH="$(${GREP} -Po '(?<=#define PROJ_VERSION_PATCH )\d' src/proj.h)"

DIST=jammy
DEB_BASE_VERSION="${V_MAJOR}.${V_MINOR}.${V_PATCH}"
DEB_VERSION="${DEB_BASE_VERSION}+kx-ci${BUILDKITE_BUILD_NUMBER}-$(git show -s --date=format:%Y%m%d --format=git%cd.%h)"
echo "Debian Package Version: ${DEB_VERSION}"

if [ -n "${BUILDKITE_AGENT_ACCESS_TOKEN-}" ]; then
    buildkite-agent meta-data set deb-base-version "$DEB_BASE_VERSION"
    buildkite-agent meta-data set deb-version "$DEB_VERSION"
    echo -e ":debian: Package Version: \`${DEB_VERSION}\`" |
        buildkite-agent annotate --style info --context deb-version
fi

time docker run \
    -v "$(pwd):/src" \
    -w "/src" \
    -e DEBEMAIL \
    -e DEBFULLNAME \
    "${ECR}/ci-tools:latest" \
    dch --distribution "${DIST}" --newversion "${DEB_VERSION}" "Koordinates CI build of ${BUILDKITE_COMMIT}: branch=${BUILDKITE_BRANCH} tag=${BUILDKITE_TAG-}"

BUILDS_DIR=$(realpath "./build-${DIST}")
mkdir -p "${BUILDS_DIR}"

SRC_DIR=$(realpath "$(dirname -- "${BASH_SOURCE[0]}")/..")

echo "Building for $DIST"
docker run --rm \
    -v "${SRC_DIR}:/kx/source" \
    --tmpfs /tmp:exec \
    -w /kx/source \
    "${ECR}/jammybuild:master.latest" \
    /kx/buildscripts/build_binary_package.sh -uc -us
