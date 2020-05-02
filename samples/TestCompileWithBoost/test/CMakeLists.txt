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

# Testing with Google Test.
if(BUILD_TESTING)
  find_package(GTest REQUIRED)

  set(test_NAME "Examle_test")
  add_executable(${test_NAME} "")

  if(NOT BOOST_WITHOUT_ICU)
    target_sources(${test_NAME}
      PRIVATE
        ${test_src_DIR}/example_test_regex_with_icu.cpp
    )
  else()
    target_sources(${test_NAME}
      PRIVATE
      ${test_src_DIR}/example_test_regex.cpp
    )
  endif()

  set_target_properties(${test_NAME} PROPERTIES
    CXX_STANDARD 11
    C_STANDARD 11
  )
  if(NOT ANDROID AND NOT APPLE AND NOT MINGW)
    set_target_properties(${test_NAME} PROPERTIES
      # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
      LINK_WHAT_YOU_USE ON
    )
  endif()

  # Boost
  # About 'Boost::disable_autolinking' see 'FindBoost.cmake'.
  target_link_libraries(${test_NAME} PRIVATE
    Boost::disable_autolinking Boost::regex
  )

  if(NOT BOOST_WITHOUT_ICU)
    # ICU
    if(NOT BUILD_SHARED_LIBS)
      target_compile_definitions(${test_NAME} PRIVATE U_STATIC_IMPLEMENTATION)
    endif()
    target_link_libraries(${test_NAME} PRIVATE ICU::i18n ICU::uc ICU::data)
  endif()

  target_link_libraries(${test_NAME} PRIVATE
    GTest::GTest GTest::Main
  )

  if(NOT ANDROID AND NOT IOS)  # Linux, Windows, macOS
    add_test(NAME ${test_NAME} COMMAND ${test_NAME})
  endif()

  if(ANDROID)
    find_program(adb_exec adb)
    if(NOT adb_exec)
      message(FATAL_ERROR "Could not find 'adb'")
    endif()

    set(TEST_WORK_DIR "/data/local/tmp/LibCMaker_test")

    add_test(NAME rm_work_dir
      COMMAND ${adb_exec} shell "if [ -d \"${TEST_WORK_DIR}\" ] ; then rm -r \"${TEST_WORK_DIR}\" ; fi"
    )

    add_test(NAME push_icu_data
      COMMAND ${adb_exec} push
        "${cmr_INSTALL_DIR}/share/icu"
        "${TEST_WORK_DIR}/share/icu"
    )

    if(BUILD_SHARED_LIBS)
      # Fix for the adb error on the arm devices if use the adb push
      # for the directory with the soft symlinks:
      # adb: error: failed to copy '<soft symlink>' to '/data/local/tmp/<soft symlink>': remote symlink failed: Permission denied
      # Instead of the direct using of the adb push use tar.
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar cf
          "${CMAKE_CURRENT_BINARY_DIR}/lib.tar"
          "${cmr_INSTALL_DIR}/lib"
        WORKING_DIRECTORY "${cmr_INSTALL_DIR}"
      )
      add_test(NAME push_libs_tar
        COMMAND ${adb_exec} push
          "${CMAKE_CURRENT_BINARY_DIR}/lib.tar"
          "${TEST_WORK_DIR}/lib.tar"
      )
      add_test(NAME extract_libs_tar
        COMMAND ${adb_exec} shell tar --no-same-owner
          -xf "${TEST_WORK_DIR}/lib.tar"
          -C "${TEST_WORK_DIR}"
      )

      find_library(cpp_shared_LIB "c++_shared")
      if(NOT cpp_shared_LIB)
        message(FATAL_ERROR "The library 'c++_shared' can not be found.")
      endif()

      get_filename_component(cpp_shared_LIB_FILE_NAME ${cpp_shared_LIB} NAME)

      add_test(NAME push_cpp_shared
        COMMAND ${adb_exec} push
          "${cpp_shared_LIB}"
          "${TEST_WORK_DIR}/lib/${cpp_shared_LIB_FILE_NAME}"
      )
    endif()

    add_test(NAME push_${test_NAME}
      COMMAND ${adb_exec} push ${test_NAME} "${TEST_WORK_DIR}/${test_NAME}"
    )
    add_test(NAME chmod_${test_NAME}
      COMMAND ${adb_exec} shell chmod 775 "${TEST_WORK_DIR}/${test_NAME}"
    )
    add_test(NAME cd_to_work_dir COMMAND ${adb_exec} shell
      cd "${TEST_WORK_DIR}"
    )
    add_test(NAME ${test_NAME} COMMAND ${adb_exec} shell
      "cd ${TEST_WORK_DIR} && "
      "LD_LIBRARY_PATH=${TEST_WORK_DIR}/lib ${TEST_WORK_DIR}/${test_NAME}"
      # :${LD_LIBRARY_PATH} || :/vendor/lib64:/system/lib64
    )
    set_tests_properties(${test_NAME} PROPERTIES
      PASS_REGULAR_EXPRESSION "PASSED"
    )
    set_tests_properties(${test_NAME} PROPERTIES
      FAIL_REGULAR_EXPRESSION "FAILED"
    )
  endif()
endif()


# For running test, 1st build all:
#   cmake .. -DBUILD_TESTING=ON
#   cmake --build .
# Then run test with this command:
#   cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target test
# Or with this command:
#   ctest --verbose
# Env var CTEST_OUTPUT_ON_FAILURE or key --verbose are for show test outputs,
# see
# https://stackoverflow.com/a/37123943
# https://stackoverflow.com/a/38386596

# For Visual Studio:
# https://stackoverflow.com/a/31124523
# https://stackoverflow.com/a/37123943
# cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target RUN_TESTS
