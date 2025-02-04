DOCKER_USER ?= ngc7331
DOCKER_REPO ?= registry

PLATFORMS ?= linux/amd64 linux/arm64
COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
PLATFORMS_COMMA := $(subst $(SPACE),$(COMMA),$(PLATFORMS))

REG_VERSION ?= 3.0.0-rc.2
SKOPEO_VERSION ?= 1.16.1
SKOPEO_REL ?= -r1

all: build build-skopeo

update:
	@echo registry update is disabled on beta branch

	@TMP=$(shell curl -s https://git.alpinelinux.org/aports/plain/community/skopeo/APKBUILD?h=3.21-stable | sed -n 's/pkgver=\([0-9.]*\)/\1/p') && \
	sed -i "s/^SKOPEO_VERSION ?= .*$$/SKOPEO_VERSION ?= $$TMP/" Makefile && \
	echo "SKOPEO_VERSION updated to $$TMP"

	@TMP=$(shell curl -s https://git.alpinelinux.org/aports/plain/community/skopeo/APKBUILD?h=3.21-stable | sed -n 's/pkgrel=\([0-9]*\)/\1/p') && \
	sed -i "s/^SKOPEO_REL ?= .*$$/SKOPEO_REL ?= -r$$TMP/" Makefile && \
	echo "SKOPEO_REL updated to -r$$TMP"

build:
	docker buildx build \
		--build-arg REG_VERSION=$(REG_VERSION) \
		--platform $(PLATFORMS_COMMA) \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):nightly \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):$(REG_VERSION) \
		--push .

build-skopeo:
	docker buildx build \
		--build-arg REG_VERSION=$(REG_VERSION) \
		--build-arg SKOPEO_VERSION=$(SKOPEO_VERSION) \
		--build-arg SKOPEO_REL=$(SKOPEO_REL) \
		--platform $(PLATFORMS_COMMA) \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):nightly-skopeo \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):$(REG_VERSION)-skopeo$(SKOPEO_VERSION) \
		-f Dockerfile.skopeo \
		--push .
