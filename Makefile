
#
# Parameters
#

# Name of the docker executable
DOCKER = docker

# Docker organization to pull the images from
ORG = slicer

#
# Convention
#

#
# Name of target: The name is expected to have the following form: imagename[_imagetag]
#                 where:
#
#                   * imagename and imagetag are alphanumerical strings that can contain dash
#
#                   * "_" is used to delimit the image name and the tag name (e.g 'slicer-test_opengl'
#                     corresponds to 'slicer-test:opengl')
#
#                   * directory "imagename" or "imagename/imagetag" is expected to contain a Dockerfile
#

# Functions
#

build =                                                      \
	$(eval REPO := $(subst _,:,$(1)))                          \
	$(eval TAG := latest)                                      \
	$(eval DIR := $(subst _,/,$(1)))                           \
	$(eval IMAGEID := $(shell $(DOCKER) images -q $(ORG)/$(REPO):$(TAG))) \
	$(DOCKER) build -t $(ORG)/$(REPO):$(TAG)                   \
		--build-arg IMAGE=$(ORG)/$(REPO):$(TAG)                  \
		--build-arg VCS_REF=`git rev-parse --short HEAD`         \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`   \
		$(DIR);                                                  \
	CURRENT_IMAGEID=$$($(DOCKER) images -q $(ORG)/$(REPO):$(TAG)) &&  \
	if [ -n "$(IMAGEID)" ] && [ "$(IMAGEID)" != "$$CURRENT_IMAGEID" ]; then $(DOCKER) rmi "$(IMAGEID)"; fi

#
# Rules
#

build-all: slicer-base slicer-dependencies slicer-build slicer-test

push-all: slicer-base.push slicer-dependencies.push slicer-build.push slicer-test.push

slicer-base: slicer-base/Dockerfile
	$(call build,$@)


slicer-base.push: slicer-base
	$(DOCKER) push $(ORG)/slicer-base

slicer-dependencies: slicer-base/Dockerfile slicer-base
	$(call build,$@)

slicer-dependencies.push: slicer-dependencies
	$(DOCKER) push $(ORG)/slicer-dependencies

slicer-build: slicer-build/Dockerfile slicer-base
	$(call build,$@)

slicer-build.push: slicer-build
	$(DOCKER) push $(ORG)/slicer-build

slicer-test: slicer-test/Dockerfile slicer-base
	$(call build,$@)

slicer-test.push: slicer-test
	$(DOCKER) push $(ORG)/slicer-test

slicer-test_opengl: slicer-test/opengl/Dockerfile
	$(call build,$@)

slicer-test_opengl.push: slicer-test_opengl
	$(DOCKER) push $(ORG)/$(subst _,:,$@)

.PHONY: build-all push-all slicer-base slicer-dependencies slicer-build slicer-test slicer-test_opengl %.push
