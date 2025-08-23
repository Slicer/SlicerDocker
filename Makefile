
#
# Parameters
#

# Name of the docker-equivalent executable for building images.
# OCI: open container interface.
# Common values: docker, podman
DOCKER := $(or $(OCI_EXE), docker)
BUILD_DOCKER := $(or $(BUILD_DOCKER), $(DOCKER))

# The build sub-command. Use:
#
#   export "BUILD_CMD=buildx build --platform linux/amd64,linux/arm64"
#
# to generate multi-platform images.
BUILD_CMD := $(or $(BUILD_CMD), build)

# Docker organization to pull the images from
ORG = slicer

# Images
ALL_IMAGES = slicer-base slicer-build slicer-dependencies slicer-notebook slicer-test

# Generated Dockerfiles.
GEN_IMAGES := $(ALL_IMAGES)

GEN_IMAGE_DOCKERFILES = $(addsuffix /Dockerfile,$(GEN_IMAGES))

#
# Name of images: The name is expected to have the following form: imagename[_imagetag]
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
define build
	$(eval REPO := $(1))
	$(eval TAG := $(2))
	$(eval DIR := $(3))
	$(eval IMAGEID := $(shell $(BUILD_DOCKER) images -q $(ORG)/$(REPO):$(TAG)))
	$(eval BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ"))
	$(eval BUILD_ARG_BUILD_DATE := $(shell if [ $(REPO) != "slicer-base" ]; then echo "--build-arg BUILD_DATE=$(BUILD_DATE)"; fi))
	$(BUILD_DOCKER) $(BUILD_CMD) --pull -t $(ORG)/$(REPO):$(TAG) \
		--build-arg IMAGE=$(ORG)/$(REPO)                         \
		--build-arg VERSION=$(TAG)                               \
		--build-arg VCS_REF=`git rev-parse --short HEAD`         \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		$(BUILD_ARG_BUILD_DATE)                                  \
		$(DIR);
	CURRENT_IMAGEID=$$($(BUILD_DOCKER) images -q $(ORG)/$(REPO):$(TAG)) &&  \
	if [ -n "$(IMAGEID)" ] && [ "$(IMAGEID)" != "$$CURRENT_IMAGEID" ]; then $(BUILD_DOCKER) rmi "$(IMAGEID)" || true; fi
endef


#
# build-all: This target builds all IMAGES (because it is the first one, it is built by default)
#
build-all: $(ALL_IMAGES)

#
# Dockerfile configuration implicit rules
#
$(GEN_IMAGE_DOCKERFILES): %Dockerfile: %Dockerfile.in $(DOCKER_COMPOSITE_PATH)
	cp $< $@

.PHONY: $(GEN_IMAGE_DOCKERFILES)

#
# build implicit rule
#
$(ALL_IMAGES): %: %/Dockerfile
	$(eval TAG := latest)
	$(call build,$@,$(TAG),$@)

slicer-build: slicer-base
slicer-dependencies: slicer-base
slicer-test: slicer-base

.SECONDEXPANSION:
$(addsuffix .push,$(ALL_IMAGES)):
	$(eval REPO := $(basename $@))
	$(eval TAG := latest)
	$(BUILD_DOCKER) push $(ORG)/$(REPO):$(TAG)

push-all: $(addsuffix .push,$(ALL_IMAGES))

slicer-test_opengl: slicer-test/opengl/Dockerfile
	$(eval TAG := opengl)
	$(call build,slicer-test,$(TAG),slicer-test/opengl)

slicer-test_opengl.push: slicer-test_opengl
	$(BUILD_DOCKER) push $(ORG)/$(subst _,:,$@)

.PHONY: build-all $(ALL_IMAGES) slicer-build slicer-dependencies slicer-test $(addsuffix .push,$(ALL_IMAGES)) push-all slicer-test_opengl

#
# clean rule
#
clean:
	for d in $(GEN_IMAGE_DOCKERFILES) ; do rm -f $$d ; done

.PHONY: clean
