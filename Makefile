default: build

DOCKER_USER := ngc7331
DOCKER_IMAGE := registry

build:
	docker build . -t $(DOCKER_USER)/$(DOCKER_IMAGE):latest

build-skopeo: skopeo/bin/skopeo
	docker build -f Dockerfile-skopeo . -t $(DOCKER_USER)/$(DOCKER_IMAGE):latest-skopeo

skopeo/bin/skopeo:
	cd skopeo && $(MAKE) binary && cd ..
