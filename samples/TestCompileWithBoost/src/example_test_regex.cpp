/*****************************************************************************
 * Project:  LibCMaker_Boost
 * Purpose:  A CMake build script for Boost library
 * Author:   NikitaFeodonit, nfeodonit@yandex.com
 *****************************************************************************
 *   Copyright (c) 2017-2019 NikitaFeodonit
 *
 *    This file is part of the LibCMaker_Boost project.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published
 *    by the Free Software Foundation, either version 3 of the License,
 *    or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *    See the GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program. If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/

// The code is based on the code from
// <boost>/libs/regex/example/snippets/credit_card_example.cpp

#include <boost/regex.hpp>
#include <string>

#include "gtest/gtest.h"

bool validate_card_format(const std::string& s)
{
  static const boost::regex e("(\\d{4}[- ]){3}\\d{4}");
  return boost::regex_match(s, e);
}

const boost::regex e("\\A(\\d{3,4})[- ]?(\\d{4})[- ]?(\\d{4})[- ]?(\\d{4})\\z");
const std::string machine_format("\\1\\2\\3\\4");
const std::string human_format("\\1-\\2-\\3-\\4");

std::string machine_readable_card_number(const std::string& s)
{
  return boost::regex_replace(s, e, machine_format, boost::match_default | boost::format_sed);
}

std::string human_readable_card_number(const std::string& s)
{
  return boost::regex_replace(s, e, human_format, boost::match_default | boost::format_sed);
}

#include <iostream>
using namespace std;

TEST(Examle, test)
{
  string s[4] = { "0000111122223333", "0000 1111 2222 3333",
      "0000-1111-2222-3333", "000-1111-2222-3333", };
  int i;
  for(i = 0; i < 4; ++i)
  {
    cout << "validate_card_format(\"" << s[i] << "\") returned " << validate_card_format(s[i]) << endl;
  }
  for(i = 0; i < 4; ++i)
  {
    cout << "machine_readable_card_number(\"" << s[i] << "\") returned " << machine_readable_card_number(s[i]) << endl;
  }
  for(i = 0; i < 4; ++i)
  {
    cout << "human_readable_card_number(\"" << s[i] << "\") returned " << human_readable_card_number(s[i]) << endl;
  }
  EXPECT_TRUE(true);
}
