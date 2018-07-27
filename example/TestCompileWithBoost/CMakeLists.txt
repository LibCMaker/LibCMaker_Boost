# ****************************************************************************
#  Project:  LibCMaker_Boost
#  Purpose:  A CMake build script for Boost Libraries
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
#
#    This file is part of the LibCMaker_Boost project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

# TODO: Android builds (shared, static).
# TODO: add deps lib list.
# TODO: work with ICU.


cmake_minimum_required(VERSION 3.2)

project(LibCMaker_Boost_Compile_Test CXX)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(cmr_PRINT_DEBUG ON)


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()

# To use our FindBoost.cmake.
list(APPEND CMAKE_MODULE_PATH
  "${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Boost/cmake"
)


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LIBCMAKER_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Set vars to LibCMaker_Boost and FindBoost
#-----------------------------------------------------------------------

# Standard CMake vars.
#set(BUILD_SHARED_LIBS ON)

# Set required compiler language standards.
set(CMAKE_C_STANDARD 99)    # 11 99 90
set(CMAKE_CXX_STANDARD 11)  # 17 14 11 98

# Vars to lib_cmaker_boost().
set(BOOST_lib_VERSION     "1.64.0")
set(BOOST_lib_COMPONENTS  filesystem system)
#set(BOOST_lib_COMPONENTS  all)
set(BOOST_DOWNLOAD_DIR    "${PROJECT_BINARY_DIR}")
set(BOOST_UNPACKED_DIR    "${PROJECT_BINARY_DIR}")
set(BOOST_BUILD_DIR       "${PROJECT_BINARY_DIR}/build_boost")

#set(PRINT_BOOST_DEBUG OFF)  # Extra debug info from 'b2' tool.

# Library specific vars.
#set(B2_PROGRAM_PATH "/bin/b2")  # Use 'b2' in specified path.
set(BUILD_BCP_TOOL OFF)  # Build 'bcp' program.
set(Boost_USE_MULTITHREADED ON)  # Use to build lib and for find_project().
# Build and install only compiled library files to the stage directory.
set(BOOST_BUILD_STAGE OFF)
# Install library files here.
set(BOOST_BUILD_STAGE_DIR "${CMAKE_INSTALL_PREFIX}/stage")


#-----------------------------------------------------------------------
# Build and install the Boost
#-----------------------------------------------------------------------

include(${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Boost/lib_cmaker_boost.cmake)

# Make compile, build and install the library at a config CMake phase.
# For specified boost components dependence components will builded too.

# Install specified library version and components.
lib_cmaker_boost(
  VERSION       ${BOOST_lib_VERSION}
  COMPONENTS    ${BOOST_lib_COMPONENTS}
  DOWNLOAD_DIR  ${BOOST_DOWNLOAD_DIR}
  UNPACKED_DIR  ${BOOST_UNPACKED_DIR}
  BUILD_DIR     ${BOOST_BUILD_DIR}
)

# Install specified library version and only headers.
#lib_cmaker_boost(
#  VERSION       ${BOOST_lib_VERSION}
#  DOWNLOAD_DIR  ${BOOST_DOWNLOAD_DIR}
#  UNPACKED_DIR  ${BOOST_UNPACKED_DIR}
#  BUILD_DIR     ${BOOST_BUILD_DIR}
#)

# Install specified library version and all libs.
#lib_cmaker_boost(
#  VERSION       ${BOOST_lib_VERSION}
#  COMPONENTS    all
#  DOWNLOAD_DIR  ${BOOST_DOWNLOAD_DIR}
#  UNPACKED_DIR  ${BOOST_UNPACKED_DIR}
#  BUILD_DIR     ${BOOST_BUILD_DIR}
#)


#-----------------------------------------------------------------------
# find_package()
#-----------------------------------------------------------------------

# Vars to find_project() only. Use to select installed Boost configuration.
#set(Boost_USE_MULTITHREADED ON)  # Set above.
#set(Boost_USE_STATIC_LIBS OFF)
# Here we depend to BUILD_SHARED_LIBS for Boost_USE_STATIC_LIBS.
if(BUILD_SHARED_LIBS)
  set(Boost_USE_STATIC_LIBS OFF)
else()
  set(Boost_USE_STATIC_LIBS ON)
endif()

# Use newly got boost library.
find_package(
  Boost ${lib_VERSION} REQUIRED COMPONENTS ${BOOST_lib_COMPONENTS} CONFIG)

# QUIET suppresses the big warning issued, and allows fallback
#find_package(Boost 1.63 QUIET CONFIG COMPONENTS filesystem system)
#if(NOT Boost_FOUND)
#  # Do warn about falling back to system, but can make message more
#  # explicit/informative
#  message(STATUS
#    "No BoostConfig.cmake config file found, falling back to FindBoost...")
#  # Use REQUIRED flag to fail if not found
#  find_package(Boost 1.63 REQUIRED COMPONENTS filesystem system)
#endif()


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Build test executables.

# To run it on Linux with the shared libs
# which are built with non standard path in CMAKE_INSTALL_PREFIX use:
# LD_LIBRARY_PATH="<${CMAKE_INSTALL_PREFIX}>/lib:.:$LD_LIBRARY_PATH" ./LibCMaker_Boost_Compile_Test_2
# where <${CMAKE_INSTALL_PREFIX}> is path which is used
# as value for CMAKE_INSTALL_PREFIX.

# Get an example sources from the lib sources.
set(BOOST_version_underscore "1_64_0")
set(lib_SRC_DIR
  "${BOOST_UNPACKED_DIR}/boost-${BOOST_lib_VERSION}/boost_${BOOST_version_underscore}/"
)
set(lib_EXAMPLES_SRC_DIR ${lib_SRC_DIR}/libs/filesystem/example)

# Example #1
add_executable(${PROJECT_NAME} test_header.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

# Boost
#target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} Boost::boost)

# Example #2
add_executable(${PROJECT_NAME}_2 test_compiled.cpp)
set_property(TARGET ${PROJECT_NAME}_2 PROPERTY CXX_STANDARD 11)

# Boost
#target_include_directories(${PROJECT_NAME}_2 PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(${PROJECT_NAME}_2 ${Boost_LIBRARIES})
target_link_libraries(${PROJECT_NAME}_2
  Boost::boost Boost::filesystem Boost::system
)
