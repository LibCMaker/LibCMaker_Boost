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

# Based on the BoostBuilder:
# https://github.com/drbenmorgan/BoostBuilder

# The structure of the libdeps file is as follows:
# BUILD_SHARED_LIBS (if on use shared libs)
# Boost_USE_MULTITHREADED (if on use -mt libs)
#
# The setting of these would need to make the top level config fall over
# if the given model isn't supported.
#
# So the config file needs to load:
#
# include(
#  "${CMAKE_CURRENT_LIST_DIR}/BoostTargetss-<libtype>-<threadingmodel>.cmake
# )
#
# That file in turn needs to load
# BoostTargets-<libtype>-<threadingmodel>-*.cmake
#
# So here we'd have the release and debug files.
#
# So a full build would have
# the following main libdeps files, and their nested loads based on mode:
# BoostTargets-shared-singlethread.cmake
#    BoostTargets-shared-singlethread-Release.cmake
#    BoostTargets-shared-singlethread-Debug.cmake
# BoostTargets-shared-multithread.cmake
#    BoostTargets-shared-multithread-Release.cmake
#    BoostTargets-shared-multithread-Debug.cmake
# BoostTargets-static-singlethread.cmake
#    BoostTargets-static-singlethread-Release.cmake
#    BoostTargets-static-singlethread-Debug.cmake
# BoostTargets-static-multithread.cmake
#    BoostTargets-static-multithread-Release.cmake
#    BoostTargets-static-multithread-Debug.cmake
#
# That's a lot of files, but the structure is fairly easy to configure
# on the fly.


#-----------------------------------------------------------------------
# Template for import target properties.
#
function(make_import_target var target lib_file_name variant)
  string(TOUPPER "${variant}" variant)
  set(${var}
    ### Begin of string.
"
# Import target \"${target}\" for configuration \"${variant}\".
set_property(TARGET Boost::${target} APPEND PROPERTY
  IMPORTED_CONFIGURATIONS ${variant}
)
set_target_properties(Boost::${target} PROPERTIES
  IMPORTED_LOCATION_${variant}
  \"\${Boost_LIBRARY_DIR}/${lib_file_name}\"
)

list(APPEND _IMPORT_CHECK_TARGETS ${target})
list(APPEND _IMPORT_CHECK_FILES_FOR_${target}
  \"\${Boost_LIBRARY_DIR}/${lib_file_name}\"
)
"
    ### End of string.
    PARENT_SCOPE
  )
endfunction()


#-----------------------------------------------------------------------
# Boost lib deps file writer
#
function(write_boost_libdepfile _dir _link _thread _variant)
  set(_filename "BoostTargets-${_link}-${_thread}-${_variant}.cmake")
  message(STATUS "Writing ${_filename}")

  set(_libprefix_shared "${CMAKE_SHARED_LIBRARY_PREFIX}boost_")
  set(_libsuffix_shared "${CMAKE_SHARED_LIBRARY_SUFFIX}")

  set(_libprefix_static "${CMAKE_STATIC_LIBRARY_PREFIX}boost_")
  set(_libsuffix_static "${CMAKE_STATIC_LIBRARY_SUFFIX}")

  if("${_link}" STREQUAL "shared")
    set(_libprefix "${_libprefix_shared}")
    set(_libsuffix "${_libsuffix_shared}")
  else()
    set(_libprefix "${_libprefix_static}")
    set(_libsuffix "${_libsuffix_static}")
  endif()

  if("${_thread}" STREQUAL "multithread")
    set(_libmttag "-mt")
  endif()

  if("${_variant}" STREQUAL "debug")
    set(_libvrtag "-d")
  endif()

  # Write the import target properties.
  set(_addimports)
  foreach(_comp ${ARGN})
    set(lib_file_name
      "${_libprefix}${_comp}${_libmttag}${_libvrtag}${_libsuffix}"
    )
    if(_comp STREQUAL "thread" AND NOT _libmttag)
      # Handle the weird case of boost_thread, which is always '-mt'.
      set(lib_file_name
        "${_libprefix}${_comp}-mt${_libvrtag}${_libsuffix}"
      )
    endif()
    if(_comp STREQUAL "exception")
      set(lib_file_name
        "${_libprefix_static}${_comp}${_libmttag}${_libvrtag}${_libsuffix_static}"
      )
    endif()
    make_import_target(_text ${_comp} "${lib_file_name}" ${_variant})
    set(_addimports "${_addimports}${_text}")
  endforeach()

# TODO: if shared add IMPORTED_LOCATION for all static libs.
#  set(static_imports 
#    "chrono"
#    "exception"
#    "system"
#    "test_exec_monitor"
#    "timer"
#    "unit_test_framework"
#  )

  # Write the file.
  file(WRITE "${_dir}/${_filename}" "${_addimports}")
endfunction()


#-----------------------------------------------------------------------
# Processing
#-----------------------------------------------------------------------

# Use:
#   templates_DIR
#   generate_DIR
#   BUILD_SHARED_LIBS
#   Boost_USE_MULTITHREADED
#   Boost_BUILD_VARIANT
#   Boost_COMPONENTS

#-----------------------------------------------------------------------
# Configure the various options.
#
if(BUILD_SHARED_LIBS)
  set(_linking shared)
else()
  set(_linking static)
endif()

if(Boost_USE_MULTITHREADED)
  set(_threading multithread)
else()
  set(_threading singlethread)
endif()

# release or debug
string(TOLOWER ${Boost_BUILD_VARIANT} _variant)

string(REPLACE " " ";" Boost_COMPONENTS "${Boost_COMPONENTS}")


#-----------------------------------------------------------------------
# Create the tree of BoostTargets files
#
# Used in BoostTargets.in.cmake
#   Boost_LINK_MODEL
#   Boost_LINK_MODEL_TAG
#   Boost_THREAD_MODEL_TAG
#   Boost_COMPONENTS

set(Boost_LINK_MODEL_TAG ${_linking})
set(Boost_THREAD_MODEL_TAG ${_threading})
string(TOUPPER ${_linking} Boost_LINK_MODEL)

# Configure the front end lib depends file for the link+thread model.
configure_file(${templates_DIR}/BoostTargets.in.cmake
  ${generate_DIR}/BoostTargets-${_linking}-${_threading}.cmake
  @ONLY
)

# Write file for the join of link+thread+variant models.
write_boost_libdepfile(
  ${generate_DIR}
  ${_linking} ${_threading} ${_variant}
  ${Boost_COMPONENTS}
)
