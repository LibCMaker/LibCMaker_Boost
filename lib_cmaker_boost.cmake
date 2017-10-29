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

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker modules root")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")

# To find bcm source dir.
set(cmr_LibCMaker_Boost_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${cmr_LibCMaker_Boost_SRC_DIR}/cmake/modules")

include(cmr_lib_cmaker)
include(cmr_print_debug_message)
include(cmr_print_var_value)

# See description for "bcm_boost_cmaker()" for params and vars.
function(lib_cmaker_boost)
  cmake_minimum_required(VERSION 3.2)

  cmake_parse_arguments(boost "" "VERSION" "COMPONENTS" "${ARGV}")
  # -> boost_VERSION
  # -> boost_COMPONENTS


  #-----------------------------------------------------------------------
  # Build dirs
  #-----------------------------------------------------------------------

  set(bcm_bin_dir_name "LibCMaker_Boost")
  set(bcm_bin_dir "${CMAKE_CURRENT_BINARY_DIR}/${bcm_bin_dir_name}")


  #-----------------------------------------------------------------------
  # Build args
  #-----------------------------------------------------------------------

  set(bcm_CMAKE_ARGS)

  # Vars from FindBoost.cmake
  # TODO: add more vars from FindBoost.cmake
  if(Boost_USE_STATIC_LIBS)
    list(APPEND bcm_CMAKE_ARGS
      -DBoost_USE_STATIC_LIBS=${Boost_USE_STATIC_LIBS}
    )
  endif()
  if(Boost_USE_MULTITHREADED)
    list(APPEND bcm_CMAKE_ARGS
      -DBoost_USE_MULTITHREADED=${Boost_USE_MULTITHREADED}
    )
  endif()
  
  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------
  cmr_lib_cmaker(
    PROJECT_DIR ${cmr_LibCMaker_Boost_SRC_DIR}
    BUILD_DIR ${bcm_BUILD_DIR}
    VERSION ${boost_VERSION}
    DOWNLOAD_DIR ${bcm_DOWNLOAD_DIR}
    UNPACKED_SRC_DIR ${bcm_SRC_DIR}
    COMPONENTS ${boost_COMPONENTS}
    CMAKE_ARGS ${bcm_CMAKE_ARGS}
  )

endfunction()
