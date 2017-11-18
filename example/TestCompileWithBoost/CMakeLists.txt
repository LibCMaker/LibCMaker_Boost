# ****************************************************************************
#  Project:  LibCMaker_Boost
#  Purpose:  A CMake build script for Boost Libraries
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017 NikitaFeodonit
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

cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(LibCMaker_Boost_Compile_Test CXX)


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LIBCMAKER_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Set vars for LibCMaker_Boost and FindBoost.
#-----------------------------------------------------------------------

# Standard CMake vars.
#set(BUILD_SHARED_LIBS ON)

#set(SKIP_INSTALL_HEADERS ON)
#set(SKIP_INSTALL_LIBRARIES ON)
#set(SKIP_INSTALL_ALL ON)

# Set useful vars for lib_cmaker_boost().
set(cmr_PRINT_DEBUG ON)

set(lib_VERSION "1.64.0")
set(lib_COMPONENTS filesystem system)

set(DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(BUILD_DIR "${PROJECT_BINARY_DIR}/build")

# Library specific vars.
set(Boost_USE_STATIC_LIBS ON)
#set(Boost_USE_MULTITHREADED ON)

#-----------------------------------------------------------------------
# Build and install the boost.
#-----------------------------------------------------------------------

include(${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Boost/lib_cmaker_boost.cmake)

# Make compile, build and install the library at a config CMake phase,
# generate the CMake config files.

# For specified boost components dependence components will builded too.

# Install specified library version and components.
lib_cmaker_boost(
  VERSION ${lib_VERSION}
  COMPONENTS ${lib_COMPONENTS}
  DOWNLOAD_DIR ${DOWNLOAD_DIR}
  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
  BUILD_DIR ${BUILD_DIR}
)

# Install specified library version and only headers.
#lib_cmaker_boost(
#  VERSION ${lib_VERSION}
#  DOWNLOAD_DIR ${DOWNLOAD_DIR}
#  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
#  BUILD_DIR ${BUILD_DIR}
#)

# Install specified library version and all libs.
#lib_cmaker_boost(
#  VERSION ${lib_VERSION}
#  COMPONENTS all
#  DOWNLOAD_DIR ${DOWNLOAD_DIR}
#  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
#  BUILD_DIR ${BUILD_DIR}
#)


#-----------------------------------------------------------------------
# Configure for find_package.
#-----------------------------------------------------------------------

# Set CMake's search path for find_package(), find_program(), find_library(),
# find_file(), and find_path() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
  # TODO: fix default CMAKE_CXX_STANDARD to 11 or 14
endif()


#-----------------------------------------------------------------------
# find_package
#-----------------------------------------------------------------------

# Use newly got boost library.
find_package(
  Boost ${lib_VERSION} REQUIRED CONFIG COMPONENTS ${lib_COMPONENTS})

# QUIET suppresses the big warning issued, and allows fallback
#find_package(Boost 1.63 QUIET CONFIG COMPONENTS filesystem system)
#if(NOT Boost_FOUND)
    # Do warn about falling back to system, but can make message more
    # explicit/informative
#    message(STATUS
#      "No BoostConfig.cmake config file found, falling back to FindBoost...")
    # Use REQUIRED flag to fail if not found
#    find_package(Boost 1.63 REQUIRED COMPONENTS filesystem system)
#endif()


#-----------------------------------------------------------------------
# Link to a boost library
#-----------------------------------------------------------------------

# Use/Link it to a boost library, LibCMaker_Boost sets the same variables
# to libs as FindBoost does, but these are imported targets so
# always expand to the exact library used.
#target_include_directories(target_name PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(target_name ${Boost_LIBRARIES})

# Build test executables
add_executable(${PROJECT_NAME} test_header.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

add_executable(${PROJECT_NAME}_2 test_compiled.cpp)
target_include_directories(${PROJECT_NAME}_2 PRIVATE ${Boost_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME}_2 ${Boost_LIBRARIES})
set_property(TARGET ${PROJECT_NAME}_2 PROPERTY CXX_STANDARD 11)
