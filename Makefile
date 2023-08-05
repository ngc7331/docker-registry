default: build

DOCKER_USER := ngc7331
DOCKER_IMAGE := registry

REG_VERSION := 2.8.2
SKOPEO_VERSION := $(shell sed -n -r 's/const Version = "(.*)"/\1/p' skopeo/version/version.go)

build:
	docker build . -t $(DOCKER_USER)/$(DOCKER_IMAGE):latest
	docker tag $(DOCKER_USER)/$(DOCKER_IMAGE):latest $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)

build-skopeo: skopeo/bin/skopeo
	docker build -f Dockerfile-skopeo . -t $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo
	docker tag $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)-skopeo$(SKOPEO_VERSION)

skopeo/bin/skopeo:
	cd skopeo && $(MAKE) binary && cd ..

push:
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):latest
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)

push-skopeo:
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo
	docker push $(DOCKER_USER)/$(DOCKER_IMAGE):$(REG_VERSION)-skopeo$(SKOPEO_VERSION)
