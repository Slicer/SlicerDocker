
#
# Parameters
#

# Name of the docker executable
DOCKER = docker

# Docker organization to pull the images from
ORG = slicer

#
# Rules
#

build-all: slicer-base slicer-dependencies slicer-build slicer-test

push-all: slicer-base.push slicer-dependencies.push slicer-build.push slicer-test.push

slicer-base: slicer-base/Dockerfile
	image=$(ORG)/slicer-base
	$(DOCKER) build -t $image \
		--build-arg IMAGE=$image \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		slicer-base

slicer-base.push: slicer-base
	$(DOCKER) push $(ORG)/slicer-base

slicer-dependencies: slicer-base/Dockerfile slicer-base
	image=$(ORG)/slicer-dependencies
	$(DOCKER) build -t $image \
		--build-arg IMAGE=$image \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		slicer-dependencies

slicer-dependencies.push: slicer-dependencies
	$(DOCKER) push $(ORG)/slicer-dependencies

slicer-build: slicer-build/Dockerfile slicer-base
	image=$(ORG)/slicer-build
	$(DOCKER) build -t $image \
		--build-arg IMAGE=$image \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		slicer-build

slicer-build.push: slicer-build
	$(DOCKER) push $(ORG)/slicer-build

slicer-test: slicer-test/Dockerfile slicer-base
	image=$(ORG)/slicer-test
	$(DOCKER) build -t $image \
		--build-arg IMAGE=$image \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		slicer-test

slicer-test.push: slicer-test
	$(DOCKER) push $(ORG)/slicer-test

slicer-test-opengl: slicer-test/opengl/Dockerfile
	image=$(ORG)/slicer-test:opengl
	$(DOCKER) build -t $image \
		--build-arg IMAGE=$image \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		slicer-test/opengl

slicer-test-opengl.push: slicer-test-opengl
	$(DOCKER) push $(ORG)/slicer-test:opengl

.PHONY: build-all push-all slicer-base slicer-dependencies slicer-build slicer-test slicer-test-opengl %.push
