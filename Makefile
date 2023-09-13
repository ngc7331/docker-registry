default: build

DOCKER_USER := ngc7331
DOCKER_IMAGE := registry

REG_VERSION := 2.8.2
SKOPEO_VERSION := $(shell sed -n -r 's/const Version = "(.*)"/\1/p' skopeo/version/version.go)

all: update build build-skopeo push push-skopeo

update:
	NEW_VERSION=$(subst v,,$(shell curl -s https://api.github.com/repos/distribution/distribution/releases/latest | jq '.name')) && \
	sed -i "s/^REG_VERSION := .*$$/REG_VERSION := $$NEW_VERSION/" Makefile && \
	sed -i "s/^ENV REG_VERSION=.*$$/ENV REG_VERSION=$$NEW_VERSION/" Dockerfile*

build:
	docker build . -t $(DOCKER_USER)/$(DOCKER_IMAGE):latest
	docker tag $(DOCKER_USER)/$(DOCKER_IMAGE):latest $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)

build-skopeo: skopeo/bin/skopeo
	docker build -f Dockerfile-skopeo . -t $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo
	docker tag $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)-skopeo$(SKOPEO_VERSION)

skopeo/bin/skopeo: skopeo/version/version.go
	cd skopeo && $(MAKE) binary && cd ..

push:
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):latest
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)

push-skopeo:
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)-skopeo$(SKOPEO_VERSION)
