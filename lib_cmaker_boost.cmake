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
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


include(CMakeParseArguments) # cmake_parse_arguments

include(cmr_lib_cmaker)
include(cmr_print_debug_message)
include(cmr_print_var_value)


# To find library CMaker source dir.
set(lcm_LibCMaker_Boost_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${lcm_LibCMaker_Boost_SRC_DIR}/cmake/modules")


# See description for "cmr_boost_cmaker()" for params and vars.
function(lib_cmaker_boost)
  cmake_minimum_required(VERSION 3.2)

  set(options
    # optional args
  )
  
  set(oneValueArgs
    # required args
    VERSION BUILD_DIR
    # optional args
    DOWNLOAD_DIR UNPACKED_SRC_DIR
  )

  set(multiValueArgs
    # optional args
    COMPONENTS
  )

  cmake_parse_arguments(arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> lib_VERSION
  # -> lib_BUILD_DIR
  # -> lib_* ...

  cmr_print_var_value(LIBCMAKER_SRC_DIR)

  cmr_print_var_value(arg_VERSION)
  cmr_print_var_value(arg_BUILD_DIR)

  cmr_print_var_value(arg_DOWNLOAD_DIR)
  cmr_print_var_value(arg_UNPACKED_SRC_DIR)

  cmr_print_var_value(arg_COMPONENTS)

  # Required args
  if(NOT arg_VERSION)
    cmr_print_fatal_error("Argument VERSION is not defined.")
  endif()
  if(NOT arg_BUILD_DIR)
    cmr_print_fatal_error("Argument BUILD_DIR is not defined.")
  endif()
  if(arg_UNPARSED_ARGUMENTS)
    cmr_print_fatal_error(
      "There are unparsed arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()


  #-----------------------------------------------------------------------
  # Build args
  #-----------------------------------------------------------------------

  set(lcm_CMAKE_ARGS)
  # TODO: use standard cmake vars SKIP_INSTALL_*

  # Vars from FindBoost.cmake
  # TODO: add more vars from FindBoost.cmake
  if(DEFINED Boost_USE_STATIC_LIBS)
    list(APPEND lcm_CMAKE_ARGS
      -DBoost_USE_STATIC_LIBS=${Boost_USE_STATIC_LIBS}
    )
  endif()
  if(DEFINED Boost_USE_MULTITHREADED)
    list(APPEND lcm_CMAKE_ARGS
      -DBoost_USE_MULTITHREADED=${Boost_USE_MULTITHREADED}
    )
  endif()
  
  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------

  cmr_lib_cmaker(
    PROJECT_DIR ${lcm_LibCMaker_Boost_SRC_DIR}
    BUILD_DIR ${arg_BUILD_DIR}
    VERSION ${arg_VERSION}
    DOWNLOAD_DIR ${arg_DOWNLOAD_DIR}
    UNPACKED_SRC_DIR ${arg_UNPACKED_SRC_DIR}
    COMPONENTS ${arg_COMPONENTS}
    CMAKE_ARGS ${lcm_CMAKE_ARGS}
  )

endfunction()
