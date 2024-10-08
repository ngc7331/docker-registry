# docker-registry

An unofficial docker registry image based on s6-overlay.

## Default version

Just a registry.

Uses cron task to do garbage-collection everyday (also removes all untagged images).

## Skopeo version

A registry with built-in skopeo, see their repo [here](https://github.com/containers/skopeo).

Uses cron task to run `skopeo sync` hourly.

## Usage
```sh
docker run -d --name docker-registry \
           -p 5000:5000 \
           -v your/path/to/data:/data \
           -v your/path/to/config:/config \
           -e AUTH_USER=username \
           -e AUTH_PASS=password \
           ngc7331/registry:<tag>
```
Notes:
- Replace `your/path/to/xxx` with your actual path
- Replace `username` and `password` with some hard-to-guess string, this will be used for client's `docker login`
- Replace `<tag>` with latest or any valid tag, checkout [tags](https://hub.docker.com/r/ngc7331/registry/tags) on Docker Hub

## Configuration file
The first time the container is run, the following files and directories are generated in `/config`:
```
/config
├── auth
│   └── htpasswd
├── registry
│   └── config.yml
└── skopeo
    └── config.yml
```
### `auth/htpasswd`

This is generated from environment variable `AUTH_USER` and `AUTH_PASS`, which was set by `docker run -e`.

**DO NOT MODIFY THIS FILE DIRECTLY**.

If you want to change the username or password, just recreate the container with new env.

### `registry/config.yml`

Defines the registry.

See [official docs](https://docs.docker.com/registry/configuration/).

### `skopeo/config.yml`

(skopeo version only)

Defines the images that will be synchronized.

See [official docs](https://github.com/containers/skopeo/blob/main/docs/skopeo-sync.1.md#yaml-file-content-used-source-for---src-yaml).
