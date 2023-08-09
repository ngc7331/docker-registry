#!/bin/bash -e

check_skopeo() {
    if [ -f /usr/bin/skopeo ]; then
        return 0
    else
        echo "skopeo not available, please recreate the container using docker image with built-in skopeo"
        echo "See https://hub.docker.com/r/ngc7331/registry/tags?page=1&name=skopeo"
        return 1
    fi
}

case "$1" in
    gc|garbage-collect|registry-gc)
        /app/registry-gc ;;
    registry)
        registry "${@:2}" ;;
    sync|skopeo-sync)
        check_skopeo && /app/skopeo-sync ;;
    skopeo)
        check_skopeo && skopeo "${@:2}" ;;
    *)
        bash -c "$*" ;;
esac
