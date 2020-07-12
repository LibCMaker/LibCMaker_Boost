# ****************************************************************************
#  Project:  LibCMaker_Boost
#  Purpose:  A CMake build script for Boost Libraries
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2020 NikitaFeodonit
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

set(LibCMaker_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/libs")
set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")

include(${LibCMaker_DIR}/samples/cmr_get_cmake_min_ver.cmake NO_POLICY_SCOPE)
cmr_get_cmake_min_ver()
cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})

project(LibCMaker_Boost_Compile_Test CXX)

include(${LibCMaker_DIR}/samples/cmr_samples_common_macros.cmake)

# Used by LibCMaker_Boost for Boost building.
set(CMAKE_CXX_STANDARD 11)  # 20 17 14 11 98
if(MSVC)
  set(CMAKE_CXX_STANDARD 14)
endif()


#-----------------------------------------------------------------------
# Common sample 1st part
#-----------------------------------------------------------------------

cmr_common_sample_1st_part()


#-----------------------------------------------------------------------
# Download, configure, build, install and find the required libraries
#-----------------------------------------------------------------------

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

# NOTE: Common settings for Example #1 see in cmr_1st_part() and cmr_2nd_part().

# Example #1, with compiled Boost regex ...
if(NOT BOOST_WITHOUT_ICU)
  # ... and with ICU
  target_sources(${PROJECT_NAME}
    PRIVATE
      ${example_src_DIR}/example_regex_with_icu.cpp
  )
else()
  # ... and without ICU
  target_sources(${PROJECT_NAME}
    PRIVATE
      ${example_src_DIR}/example_regex.cpp
  )
endif()
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

# Example #2, only with Boost headers
add_executable(${PROJECT_NAME}_2
  ${example_src_DIR}/test_boost_headers.cpp
)
set_property(TARGET ${PROJECT_NAME}_2 PROPERTY CXX_STANDARD 11)
if(NOT MINGW AND NOT ANDROID AND NOT IOS
    AND NOT (APPLE AND CMAKE_GENERATOR MATCHES "Unix Makefiles"))
  set_target_properties(${PROJECT_NAME}_2 PROPERTIES
    # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
    LINK_WHAT_YOU_USE ON
  )
endif()

# Example #3, with compiled Boost filesystem
add_executable(${PROJECT_NAME}_3
  ${example_src_DIR}/test_boost_compiled.cpp
)
set_property(TARGET ${PROJECT_NAME}_3 PROPERTY CXX_STANDARD 11)
if(NOT MINGW AND NOT ANDROID AND NOT IOS
    AND NOT (APPLE AND CMAKE_GENERATOR MATCHES "Unix Makefiles"))
  set_target_properties(${PROJECT_NAME}_3 PROPERTIES
    # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
    LINK_WHAT_YOU_USE ON
  )
endif()

if(NOT BOOST_WITHOUT_ICU)
  # Example #4, with compiled Boost locale and with ICU
  add_executable(${PROJECT_NAME}_4
    ${example_src_DIR}/example_locale_with_icu.cpp
  )
  set_property(TARGET ${PROJECT_NAME}_4 PROPERTY CXX_STANDARD 11)
  if(NOT MINGW AND NOT ANDROID AND NOT IOS
      AND NOT (APPLE AND CMAKE_GENERATOR MATCHES "Unix Makefiles"))
    set_target_properties(${PROJECT_NAME}_4 PROPERTIES
      # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
      LINK_WHAT_YOU_USE ON
    )
  endif()
endif()


#-----------------------------------------------------------------------
# Link to the libraries
#-----------------------------------------------------------------------

# Boost
# 'Boost::boost' is target for header-only dependencies.
# About 'Boost::disable_autolinking' see 'FindBoost.cmake'.
target_link_libraries(${PROJECT_NAME} PRIVATE
  Boost::disable_autolinking Boost::regex Boost::thread Boost::chrono
  Boost::date_time Boost::atomic Boost::system
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
if(NOT BOOST_WITHOUT_ICU)
  target_link_libraries(${PROJECT_NAME}_4 PRIVATE
    Boost::disable_autolinking Boost::locale Boost::thread Boost::chrono
    Boost::date_time Boost::atomic Boost::system
  )
endif()

#target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(${PROJECT_NAME} PRIVATE ${Boost_LIBRARIES})
#target_include_directories(${PROJECT_NAME}_2 PRIVATE ${Boost_INCLUDE_DIRS})
#target_include_directories(${PROJECT_NAME}_3 PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(${PROJECT_NAME}_3 PRIVATE ${Boost_LIBRARIES})

if(NOT BOOST_WITHOUT_ICU)
  # ICU
  if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(${PROJECT_NAME} PRIVATE U_STATIC_IMPLEMENTATION)
    target_compile_definitions(${PROJECT_NAME}_4 PRIVATE U_STATIC_IMPLEMENTATION)
  else()
    target_compile_definitions(${PROJECT_NAME}_4 PRIVATE BOOST_LOCALE_DYN_LINK=1)
  endif()
  target_link_libraries(${PROJECT_NAME} PRIVATE ICU::i18n ICU::uc ICU::data)
  target_link_libraries(${PROJECT_NAME}_4 PRIVATE ICU::i18n ICU::uc ICU::data)
endif()


#-----------------------------------------------------------------------
# Common sample 2nd part
#-----------------------------------------------------------------------

cmr_common_sample_2nd_part()


#-----------------------------------------------------------------------
# Testing
#-----------------------------------------------------------------------

set(test_src_DIR "${CMAKE_CURRENT_LIST_DIR}/src")
add_subdirectory(test)
