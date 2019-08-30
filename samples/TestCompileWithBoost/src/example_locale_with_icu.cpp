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

// The code is from
// <boost>/libs/locale/examples/conversions.cpp

//
//  Copyright (c) 2009-2011 Artyom Beilis (Tonkikh)
//
//  Distributed under the Boost Software License, Version 1.0. (See
//  accompanying file LICENSE_1_0.txt or copy at
//  http://www.boost.org/LICENSE_1_0.txt)
//
#include <boost/locale.hpp>
#include <boost/algorithm/string/case_conv.hpp>
#include <iostream>

#include <ctime>



int main()
{
    using namespace boost::locale;
    using namespace std;
    // Create system default locale
    generator gen;
    locale loc=gen(""); 
    locale::global(loc); 
    cout.imbue(loc);

    
    cout<<"Correct case conversion can't be done by simple, character by character conversion"<<endl;
    cout<<"because case conversion is context sensitive and not 1-to-1 conversion"<<endl;
    cout<<"For example:"<<endl;
    cout<<"   German grüßen correctly converted to "<<to_upper("grüßen")<<", instead of incorrect "
                    <<boost::to_upper_copy(std::string("grüßen"))<<endl;
    cout<<"     where ß is replaced with SS"<<endl;
    cout<<"   Greek ὈΔΥΣΣΕΎΣ is correctly converted to "<<to_lower("ὈΔΥΣΣΕΎΣ")<<", instead of incorrect "
                    <<boost::to_lower_copy(std::string("ὈΔΥΣΣΕΎΣ"))<<endl;
    cout<<"     where Σ is converted to σ or to ς, according to position in the word"<<endl;
    cout<<"Such type of conversion just can't be done using std::toupper that work on character base, also std::toupper is "<<endl;
    cout<<"not even applicable when working with variable character length like in UTF-8 or UTF-16 limiting the correct "<<endl;
    cout<<"behavior to unicode subset BMP or ASCII only"<<endl;
   
}

// vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4

// boostinspect:noascii
