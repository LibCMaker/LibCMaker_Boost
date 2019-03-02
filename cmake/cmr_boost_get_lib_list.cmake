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

# Based on the build-boost.sh from CrystaX NDK:
# https://www.crystax.net/
# https://github.com/crystax/android-platform-ndk/blob/master/build/tools/build-boost.sh
# Based on the hunter:
# https://github.com/ruslo/hunter

# The complete list of libraries provided by Boost can be found by
# running the bootstrap.sh script supplied with Boost as:
#   ./bootstrap.sh --with-libraries=all --show-libraries

include(CMakeParseArguments) # cmake_parse_arguments

include(cmr_print_error)

function(cmr_boost_get_lib_list out_LIB_LIST)

  # --without-<library>   Do not build, stage, or install the specified
  #                       <library>. By default, all libraries are built.
  #
  # --with-<library>      Build and install the specified <library>.
  #                       If this option is used, only libraries specified
  #                       using this option will be built.

  set(options
  )
  set(oneValueArgs
    VERSION
  )
  set(multiValueArgs
    COMPONENTS
  )
  cmake_parse_arguments(bgll
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> bgll_VERSION
  # -> bgll_COMPONENTS

  macro(boost_component_list name version)
    list(APPEND BOOST_COMPONENT_NAMES ${name})
    set(BOOST_COMPONENT_${name}_VERSION ${version})
  endmacro()

  boost_component_list(atomic 1.53.0)
  boost_component_list(chrono 1.47.0)
  boost_component_list(container 1.48.0)
  boost_component_list(context 1.51.0)
  boost_component_list(contract 1.67.0)
  boost_component_list(coroutine 1.53.0)
#  boost_component_list(coroutine2 1.59.0)  # Header only lib.
  boost_component_list(date_time 1.29.0)
  boost_component_list(exception 1.36.0)
  boost_component_list(fiber 1.62.0)
  boost_component_list(filesystem 1.30.0)
  boost_component_list(graph 1.18.0)
  boost_component_list(graph_parallel 1.40.0)
  boost_component_list(iostreams 1.33.0)
  boost_component_list(locale 1.48.0)
  boost_component_list(log 1.54.0)
  boost_component_list(math 1.23.0)
#  boost_component_list(metaparse 1.61.0)  # Header only lib.
  boost_component_list(mpi 1.35.0)
  boost_component_list(program_options 1.32.0)
  boost_component_list(python 1.19.0)
  boost_component_list(random 1.15.0)
  boost_component_list(regex 1.18.0)
  boost_component_list(serialization 1.32.0)
  boost_component_list(signals 1.29.0)
  boost_component_list(stacktrace 1.65.0)
  boost_component_list(system 1.35.0)
  boost_component_list(test 1.21.0)
  boost_component_list(thread 1.25.0)
  boost_component_list(timer 1.9.0)
  boost_component_list(type_erasure 1.54.0)
  boost_component_list(wave 1.33.0)


  if(NOT BOOST_BUILD_ALL_COMPONENTS AND NOT bgll_COMPONENTS)
    set(build_only_headers ON)
  endif()

  if(build_only_headers)
    foreach(name IN LISTS BOOST_COMPONENT_NAMES)
      if(NOT ${bgll_VERSION} VERSION_LESS BOOST_COMPONENT_${name}_VERSION)
        # Add the <library> to the 'without'-list.
        list(APPEND without_args "--without-${name}")
      endif()
    endforeach()
    if(without_args)
      set(${out_LIB_LIST} ${without_args} PARENT_SCOPE)
    endif()
    return()  # if only headers.
  endif()


  if(BOOST_BUILD_ALL_COMPONENTS)
    foreach(name IN LISTS BOOST_COMPONENT_NAMES)
      if(${bgll_VERSION} VERSION_LESS BOOST_COMPONENT_${name}_VERSION)
        continue()
      endif()

      if(ANDROID)
        string(COMPARE EQUAL "${name}" "python" without_component)
        if(without_component)
          # TODO: CrystaX NDK has Python.
          list(APPEND without_args "--without-${name}")
          continue()
        endif()

        # Boost.Context in 1.57.0 and earlier don't support arm64.
        # Boost.Context in 1.61.0 and earlier don't support mips64.
        # Boost.Coroutine depends on Boost.Context.
        if((ANDROID_SYSROOT_ABI STREQUAL "arm64"
                AND NOT bgll_VERSION VERSION_GREATER "1.57.0")
            OR (ANDROID_SYSROOT_ABI STREQUAL "mips64"
                AND NOT bgll_VERSION VERSION_GREATER "1.61.0"))
          string(COMPARE EQUAL "${name}" "context" without_component)
          if(without_component)
            list(APPEND without_args "--without-${name}")
            continue()
          endif()

          string(COMPARE EQUAL "${name}" "coroutine" without_component)
          if(without_component)
            list(APPEND without_args "--without-${name}")
            continue()
          endif()
        endif()

        # Starting from 1.59.0, there is Boost.Coroutine2 library,
        # which depends on Boost.Context too.
        if(ANDROID_SYSROOT_ABI STREQUAL "mips64"
                AND NOT bgll_VERSION VERSION_GREATER "1.61.0")
          string(COMPARE EQUAL "${name}" "coroutine2" without_component)
          if(without_component)
            list(APPEND without_args "--without-${name}")
            continue()
          endif()
        endif()
      endif()  # if(ANDROID)

      if(MINGW AND "${name}" STREQUAL "python")
        add_definitions("-D_hypot=hypot" "-DMS_WIN64")
      endif()
    endforeach()

    if(without_args)
      set(${out_LIB_LIST} ${without_args} PARENT_SCOPE)
    endif()

    return()  # if build all components.
  endif()


  foreach(name IN LISTS bgll_COMPONENTS)
    # First, make the required checks.
    if(${bgll_VERSION} VERSION_LESS BOOST_COMPONENT_${name}_VERSION)
      cmr_print_error(
        "Boost of version ${bgll_VERSION} don't have the component '${name}'."
      )
    endif()

    if(ANDROID)
      string(COMPARE EQUAL "${name}" "python" bad_component)
      if(bad_component)
        # TODO: CrystaX NDK has Python.
        cmr_print_error("Android NDK don't have Python for Boost.Python.")
      endif()

      # Boost.Context in 1.57.0 and earlier don't support arm64.
      # Boost.Context in 1.61.0 and earlier don't support mips64.
      # Boost.Coroutine depends on Boost.Context.
      if((ANDROID_SYSROOT_ABI STREQUAL "arm64"
              AND NOT bgll_VERSION VERSION_GREATER "1.57.0")
          OR (ANDROID_SYSROOT_ABI STREQUAL "mips64"
              AND NOT bgll_VERSION VERSION_GREATER "1.61.0"))
        string(COMPARE EQUAL "${name}" "context" bad_component)
        if(bad_component)
          cmr_print_error(
            "Boost.Context in boost of version ${bgll_VERSION} don't support ${ANDROID_SYSROOT_ABI}."
          )
        endif()

        string(COMPARE EQUAL "${name}" "coroutine" bad_component)
        if(bad_component)
          cmr_print_error(
            "Boost.Coroutine in boost of version ${bgll_VERSION} don't support ${ANDROID_SYSROOT_ABI}."
          )
        endif()
      endif()

      # Starting from 1.59.0, there is Boost.Coroutine2 library,
      # which depends on Boost.Context too.
      if(ANDROID_SYSROOT_ABI STREQUAL "mips64"
              AND NOT bgll_VERSION VERSION_GREATER "1.61.0")
        string(COMPARE EQUAL "${name}" "coroutine2" bad_component)
        if(bad_component)
          cmr_print_error(
            "Boost.Coroutine2 in boost of version ${bgll_VERSION} don't support ${ANDROID_SYSROOT_ABI}."
          )
        endif()
      endif()
    endif()  # if(ANDROID)

    if(MINGW AND "${name}" STREQUAL "python")
      add_definitions("-D_hypot=hypot" "-DMS_WIN64")
    endif()

    # Second, add the <library> to the 'with'-list.
    list(APPEND with_args "--with-${name}")
  endforeach()

  if(with_args)
    set(${out_LIB_LIST} ${with_args} PARENT_SCOPE)
  endif()
endfunction()
