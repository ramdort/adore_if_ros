# This Makefile contains useful targets that can be included in downstream projects.

ifeq ($(filter adore_if_ros.mk, $(notdir $(MAKEFILE_LIST))), adore_if_ros.mk)

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
ADORE_IF_ROS_PROJECT=adore_if_ros

ADORE_IF_ROS_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
ifeq ($(SUBMODULES_PATH),)
    ADORE_IF_ROS_SUBMODULES_PATH:=${ADORE_IF_ROS_MAKEFILE_PATH}
else
    ADORE_IF_ROS_SUBMODULES_PATH:=$(shell realpath ${SUBMODULES_PATH})
endif
MAKE_GADGETS_PATH:=${ADORE_IF_ROS_SUBMODULES_PATH}/make_gadgets
ifeq ($(wildcard $(MAKE_GADGETS_PATH)/*),)
    $(info INFO: To clone submodules use: 'git submodule update --init --recursive')
    $(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
    $(info INFO: Default submodule path is: ${ADORE_IF_ROS_MAKEFILE_PATH}')
    $(error "ERROR: ${MAKE_GADGETS_PATH} does not exist. Did you clone the submodules?")
endif

ADORE_IF_ROS_TAG:=$(shell cd ${MAKE_GADGETS_PATH} && make get_sanitized_branch_name REPO_DIRECTORY=${ADORE_IF_ROS_MAKEFILE_PATH})
ADORE_IF_ROS_IMAGE=${ADORE_IF_ROS_PROJECT}:${ADORE_IF_ROS_TAG}

ADORE_IF_ROS_CMAKE_BUILD_PATH="${ADORE_IF_ROS_PROJECT}/build"
ADORE_IF_ROS_CMAKE_INSTALL_PATH="${ADORE_IF_ROS_CMAKE_BUILD_PATH}/install"

LIBADORE_MAKEFILE=libadore.mk
LIBADORE_PATH:=$(shell (find "${ADORE_IF_ROS_SUBMODULES_PATH}" -name ${LIBADORE_MAKEFILE} | xargs realpath | sed "s|/${LIBADORE_MAKEFILE}||g") 2>/dev/null || true )


include ${MAKE_GADGETS_PATH}/make_gadgets.mk
include ${MAKE_GADGETS_PATH}/docker/docker-tools.mk

include ${ADORE_IF_ROS_SUBMODULES_PATH}/adore_if_ros_msg/adore_if_ros_msg.mk 
include ${ADORE_IF_ROS_SUBMODULES_PATH}/plotlablib/plotlablib.mk 
include ${ADORE_IF_ROS_SUBMODULES_PATH}/adore_scheduling/adore_scheduling.mk
include ${ADORE_IF_ROS_SUBMODULES_PATH}/libadore/libadore.mk

include ${ADORE_IF_ROS_SUBMODULES_PATH}/cppcheck_docker/cppcheck_docker.mk
include ${ADORE_IF_ROS_SUBMODULES_PATH}/cpplint_docker/cpplint_docker.mk
include ${ADORE_IF_ROS_SUBMODULES_PATH}/lizard_docker/lizard_docker.mk

CPP_PROJECT_DIRECTORY:=${ADORE_IF_ROS_MAKEFILE_PATH}/${ADORE_IF_ROS_PROJECT}
REPO_DIRECTORY:=${ADORE_IF_ROS_MAKEFILE_PATH}

.PHONY: build_fast_adore_if_ros
build_fast_adore_if_ros: # Build adore_if_ros if it does not already exist in the docker repository. If it does exist this is a noop.
	@if [ -n "$$(docker images -q ${ADORE_IF_ROS_PROJECT}:${ADORE_IF_ROS_TAG})" ]; then \
        echo "Docker image: ${ADORE_IF_ROS_PROJECT}:${ADORE_IF_ROS_TAG} already build, skipping build."; \
        cd "${ADORE_IF_ROS_MAKEFILE_PATH}" && make docker_cp;\
    else \
        cd "${ADORE_IF_ROS_MAKEFILE_PATH}" && make build;\
    fi

.PHONY: build_adore_if_ros 
build_adore_if_ros: ## Build adore_if_ros
	cd "${ADORE_IF_ROS_MAKEFILE_PATH}" && make build

.PHONY: test_adore_if_ros 
test_adore_if_ros: ## run adore_if_ros unit tests 
	cd "${ADORE_IF_ROS_MAKEFILE_PATH}" && make test

.PHONY: clean_adore_if_ros
clean_adore_if_ros: ## Clean adore_if_ros build artifacts
	cd "${ADORE_IF_ROS_MAKEFILE_PATH}" && make clean

.PHONY: branch_adore_if_ros
branch_adore_if_ros: ## Returns the current docker safe/sanitized branch for adore_if_ros
	@printf "%s\n" ${ADORE_IF_ROS_TAG}

.PHONY: image_adore_if_ros
image_adore_if_ros: ## Returns the current docker image name for adore_if_ros
	@printf "%s\n" ${ADORE_IF_ROS_IMAGE}

.PHONY: update_adore_if_ros
update_adore_if_ros:
	cd "${ADORE_IF_ROS_MAKEFILE_PATH}" && git pull
endif
