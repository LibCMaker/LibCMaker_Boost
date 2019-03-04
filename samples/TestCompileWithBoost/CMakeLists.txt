# ****************************************************************************
#  Project:  LibCMaker_Boost
#  Purpose:  A CMake build script for Boost Libraries
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

cmake_minimum_required(VERSION 3.4)

project(LibCMaker_Boost_Compile_Test CXX)

option(CMAKE_VERBOSE_MAKEFILE "CMAKE_VERBOSE_MAKEFILE" OFF)
option(cmr_PRINT_DEBUG "cmr_PRINT_DEBUG" OFF)

# Used by LibCMaker_Boost for Boost building.
set(CMAKE_CXX_STANDARD 11)  # 20 17 14 11 98
if(MSVC)
  set(CMAKE_CXX_STANDARD 14)
endif()


#-----------------------------------------------------------------------
# Compiler flags
#-----------------------------------------------------------------------

option(cmr_USE_MSVC_STATIC_RUNTIME "cmr_USE_MSVC_STATIC_RUNTIME" ON)

if(cmr_USE_MSVC_STATIC_RUNTIME AND MSVC AND NOT BUILD_SHARED_LIBS)
  # Set MSVC static runtime flags for all configurations.
  # See:
  # https://stackoverflow.com/a/20804336
  # https://stackoverflow.com/a/14172871
  foreach(cfg "" ${CMAKE_CONFIGURATION_TYPES})
    set(c_flag_var   CMAKE_C_FLAGS)
    set(cxx_flag_var CMAKE_CXX_FLAGS)
    if(cfg)
      string(TOUPPER ${cfg} cfg_upper)
      set(c_flag_var   "${c_flag_var}_${cfg_upper}")
      set(cxx_flag_var "${cxx_flag_var}_${cfg_upper}")
    endif()
    if(${c_flag_var} MATCHES "/MD")
      string(REPLACE "/MD" "/MT" ${c_flag_var} "${${c_flag_var}}")
      set(${c_flag_var} ${${c_flag_var}} CACHE STRING
        "Flags used by the C compiler during ${cfg_upper} builds." FORCE
      )
    endif()
    if(${cxx_flag_var} MATCHES "/MD")
      string(REPLACE "/MD" "/MT" ${cxx_flag_var} "${${cxx_flag_var}}")
      set(${cxx_flag_var} ${${cxx_flag_var}} CACHE STRING
        "Flags used by the CXX compiler during ${cfg_upper} builds." FORCE
      )
    endif()
  endforeach()
endif()


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path vars
#-----------------------------------------------------------------------

set(LibCMaker_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/libs")
set(cmr_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}")

if(NOT cmr_UNPACKED_DIR)
  set(cmr_UNPACKED_DIR "${PROJECT_BINARY_DIR}/download/unpacked")
endif()


#-----------------------------------------------------------------------
# LibCMaker settings
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")
list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")
include(cmr_find_package)


#-----------------------------------------------------------------------
# Download, configure, build, install and find the required libraries
#-----------------------------------------------------------------------

option(BUILD_TESTING "Build the testing tree." OFF)
if(BUILD_TESTING)
  enable_testing()
  include(${LibCMaker_LIB_DIR}/LibCMaker_GoogleTest/cmr_build_googletest.cmake)
endif()

if(NOT BOOST_WITHOUT_ICU)
  include(${LibCMaker_LIB_DIR}/LibCMaker_ICU/cmr_build_icu.cmake)
endif()
include(${LibCMaker_LIB_DIR}/LibCMaker_Boost/cmr_build_boost.cmake)


#-----------------------------------------------------------------------
# Build the executable of the example
#-----------------------------------------------------------------------

# To run it on Linux with the shared libs
# which are built with non standard path in CMAKE_INSTALL_PREFIX use:
# LD_LIBRARY_PATH="<${CMAKE_INSTALL_PREFIX}>/lib:.:$LD_LIBRARY_PATH" ./LibCMaker_ICU_Compile_Test
# where <${CMAKE_INSTALL_PREFIX}> is path which is used
# as value for CMAKE_INSTALL_PREFIX.

set(example_src_DIR "${CMAKE_CURRENT_LIST_DIR}/src")

# Example #1, with compiled Boost regex ...
if(NOT BOOST_WITHOUT_ICU)
  # ... and with ICU
  add_executable(${PROJECT_NAME}
    ${example_src_DIR}/example_regex_with_icu.cpp
  )
else()
  # ... and without ICU
  add_executable(${PROJECT_NAME}
    ${example_src_DIR}/example_regex.cpp
  )
endif()
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

# Example #2, only with Boost headers
add_executable(${PROJECT_NAME}_2
  ${example_src_DIR}/test_boost_headers.cpp
)
set_property(TARGET ${PROJECT_NAME}_2 PROPERTY CXX_STANDARD 11)

# Example #3, with compiled Boost filesystem
add_executable(${PROJECT_NAME}_3
  ${example_src_DIR}/test_boost_compiled.cpp
)
set_property(TARGET ${PROJECT_NAME}_3 PROPERTY CXX_STANDARD 11)


#-----------------------------------------------------------------------
# Link to the libraries
#-----------------------------------------------------------------------

# Boost
# 'Boost::boost' is target for header-only dependencies.
# About 'Boost::disable_autolinking' see 'FindBoost.cmake'.
target_link_libraries(${PROJECT_NAME} PRIVATE
  Boost::disable_autolinking Boost::regex
)
target_link_libraries(${PROJECT_NAME}_2 PRIVATE
  Boost::disable_autolinking Boost::boost
)
# 'system' will also be added as IMPORT library.
# NOTE: this autodetection from 'FindBoost.cmake' is broken for Boost 1.69.0
# for Android shared arm64-v8a build with link error:
# libboost_system.so.1.69.0, needed by install/lib/libboost_filesystem.so, not found
target_link_libraries(${PROJECT_NAME}_3 PRIVATE
#  Boost::disable_autolinking Boost::filesystem
  Boost::disable_autolinking Boost::filesystem Boost::system
)

#target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(${PROJECT_NAME} PRIVATE ${Boost_LIBRARIES})
#target_include_directories(${PROJECT_NAME}_2 PRIVATE ${Boost_INCLUDE_DIRS})
#target_include_directories(${PROJECT_NAME}_3 PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(${PROJECT_NAME}_3 PRIVATE ${Boost_LIBRARIES})

if(NOT BOOST_WITHOUT_ICU)
  # ICU
  if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(${PROJECT_NAME} PRIVATE U_STATIC_IMPLEMENTATION)
  endif()
  target_link_libraries(${PROJECT_NAME} PRIVATE ICU::i18n ICU::uc ICU::data)
endif()


#-----------------------------------------------------------------------
# Testing
#-----------------------------------------------------------------------

set(test_src_DIR "${CMAKE_CURRENT_LIST_DIR}/src")
add_subdirectory(test)
