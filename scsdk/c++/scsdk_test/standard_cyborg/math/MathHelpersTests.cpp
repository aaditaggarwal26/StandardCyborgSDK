/*
 Copyright 2020 RHL Woundcare
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


#include <gtest/gtest.h>

#include "rhl_woundcare/math/MathHelpers.hpp"

using namespace rhl_woundcare::math;

TEST(MathHelpersTests, testAlmostEquals) {
    EXPECT_FALSE(rhl_woundcare::math::AlmostEqual(100.0, 100.0 + 1e-4));
    EXPECT_TRUE(rhl_woundcare::math::AlmostEqual(100.0, 100.0 + 1e-5));
    EXPECT_TRUE(rhl_woundcare::math::AlmostEqual(100.0, 100.0 + 1e-4, 1e-6, 1e-6));
}
