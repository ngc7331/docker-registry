DOCKER_USER ?= ngc7331
DOCKER_REPO ?= registry

PLATFORMS ?= linux/amd64 linux/arm64
COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
PLATFORMS_COMMA := $(subst $(SPACE),$(COMMA),$(PLATFORMS))

REG_VERSION ?= 2.8.3
SKOPEO_VERSION ?= $(shell sed -n -r 's/const Version = "(.*)"/\1/p' skopeo/version/version.go)

all: build build-skopeo

update:
	NEW_VERSION=$(subst v,,$(shell curl -s https://api.github.com/repos/distribution/distribution/releases/latest | jq '.name')) && \
	sed -i "s/^REG_VERSION := .*$$/REG_VERSION := $$NEW_VERSION/" Makefile && \
	sed -i "s/^ENV REG_VERSION=.*$$/ENV REG_VERSION=$$NEW_VERSION/" Dockerfile*

build:
	docker buildx build \
		--build-arg REG_VERSION=$(REG_VERSION) \
		--platform $(PLATFORMS_COMMA) \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):latest \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):$(REG_VERSION) \
		--push .


BINARIES = $(addprefix skopeo/bin/skopeo.,$(subst /,.,$(PLATFORMS)))
build-skopeo: $(BINARIES)
	docker buildx build \
		--build-arg REG_VERSION=$(REG_VERSION) \
		--platform $(PLATFORMS_COMMA) \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):latest-skopeo \
		-t $(DOCKER_USER)/$(DOCKER_REPO)$(TARGET):$(REG_VERSION)-skopeo$(SKOPEO_VERSION) \
		-f Dockerfile-skopeo \
		--push .

skopeo/bin/skopeo.%: skopeo/version/version.go
	cd skopeo && \
	git am ../hack/skopeo-binary.patch || { echo "patch failed" && git am --abort; } && \
	$(MAKE) binary.$(word 2,$(subst ., ,$@)).$(word 3,$(subst ., ,$@)) || echo "build failed" && \
	git reset --hard HEAD^
