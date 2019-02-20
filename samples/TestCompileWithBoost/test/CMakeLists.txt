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

  add_test(NAME ${test_NAME} COMMAND ${test_NAME})
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
