#!/bin/sh
#
# Add this to your .travis.yml:
#
#     script: curl -sSf https://yatr.rgm.io/run.sh | bash
#

set -e

do_sha512sum() {
    case "$(uname -s)" in
        Darwin)
            gsha512sum "$@"
            ;;
        *)
            sha512sum "$@"
            ;;
    esac
}

I() {
    local arch="amd64"
    local os="$(uname -s | tr '[:upper:]' '[:lower:]')"

    local index="$(curl --silent https://distfiles.rgm.io/yatr/LATEST/)"
    local archive="$(echo "${index}" | sed -n "s/.*\"\(yatr-${os}-${arch}.*\)\.sha512\".*/\1/p")"
    local folder="$(echo "${index}" | sed -n "s/.*\"\(yatr-${os}-${arch}-.*\)\.tar.*\.sha512\".*/\1/p")"
    local p="$(echo "${folder}" | sed "s/yatr-${os}-${arch}-\(.*\)/yatr-\1/")"

    curl --fail --silent --output "${archive}" "https://distfiles.rgm.io/yatr/${p}/${archive}"
    curl --fail --silent --output "${archive}.sha512" "https://distfiles.rgm.io/yatr/${p}/${archive}.sha512"

    do_sha512sum --check --status "${archive}.sha512"
    tar --extract --file="${archive}"

    exec "${folder}/yatr"
}

I
