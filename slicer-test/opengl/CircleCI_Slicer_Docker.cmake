##############################################################################
#
# Library:   Slicer
#
# Copyright 2010 Kitware Inc. 28 Corporate Drive,
# Clifton Park, NY, 12065, USA.
#
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
##############################################################################

set( Slicer_SOURCE_DIR "/usr/src/Slicer" )
set( Slicer_BINARY_DIR "/usr/src/Slicer-build" )

set( CTEST_SOURCE_DIRECTORY "${Slicer_SOURCE_DIR}" )
set( CTEST_BINARY_DIRECTORY "${Slicer_BINARY_DIR}/Slicer-build" )

######### Options for CDash #########

set( SITE_CTEST_MODE "Experimental" ) # Experimental, Continuous, or Nightly

set( CTEST_CMAKE_GENERATOR "Unix Makefiles" ) # Ninja or Unix Makefiles

set( Slicer_GIT_REPOSITORY "https://github.com/Slicer/Slicer.git" )

# Follow format for caps and components as given on Slicer dashboard
set( CTEST_SITE "CircleCI_Slicer" )

# Follow format for caps and components as given on Slicer dashboard
set( SITE_PLATFORM "CentOS5" )

# Use SITE_BUILD_TYPE specified by slicer-build-with-test
execute_process (
    COMMAND bash -c "grep BUILD_TYPE /usr/src/Slicer-build/Slicer-build/CMakeCache.txt | cut -d '=' -f2"
    OUTPUT_VARIABLE SITE_BUILD_TYPE
)
message( "\nCMAKE_BUILD_TYPE: ${SITE_BUILD_TYPE}" )

# Named SITE_BUILD_NAME
string( SUBSTRING $ENV{CIRCLE_SHA1} 0 7 commit )
set( what $ENV{CIRCLE_BRANCH} )
set( SITE_BUILD_NAME_SUFFIX _${commit}_${what} )

set( SITE_BUILD_NAME "CircleCI-${SITE_PLATFORM}-${SITE_BUILD_TYPE}${SITE_BUILD_NAME_SUFFIX}" )

set( CTEST_BUILD_NAME "${SITE_BUILD_NAME}-BuildTest-${SITE_CTEST_MODE}" )

######### Config ##########

#set( CTEST_CONFIGURATION_TYPE "${SITE_BUILD_TYPE}" )
#set( CMAKE_BUILD_TYPE "${SITE_BUILD_TYPE}" )
set( BUILD_TESTING ON )

#set( BUILD_TOOL_FLAGS "-j8" )

set( EXCLUDE_RUN_TEST "vtkMRMLVolumeRenderingDisplayableManagerTest1|py_StandaloneEditorWidgetTest|py_CLIEventTest" )

######### Submit Config ##########

set(CTEST_PROJECT_NAME "Slicer")
set(CTEST_NIGHTLY_START_TIME "3:00:00 UTC")

set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "slicer.cdash.org")
set(CTEST_DROP_LOCATION "/submit.php?project=Slicer4")
set(CTEST_DROP_SITE_CDASH TRUE)

########## Run ctest #########

ctest_start( "${SITE_CTEST_MODE}" )

#ctest_configure( BUILD ${CTEST_BINARY_DIR}
#    SOURCE "${Slicer_SOURCE_DIR}" )

#ctest_build( BUILD ${CTEST_BINARY_DIR} )
#    TARGET "${TEST_GUI}" )

ctest_test( BUILD "${CTEST_BINARY_DIRECTORY}"
    RETURN_VALUE ctest_return_value
    EXCLUDE "${EXCLUDE_RUN_TEST}")

ctest_submit()

if(NOT ctest_return_value EQUAL 0)
  message( "\n" )
  message( SEND_ERROR "Some tests have failed. Exit status ${ctest_return_value}" )
endif()
