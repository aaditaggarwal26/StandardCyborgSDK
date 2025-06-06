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

#include "rhl_woundcare/io/ply/RawFrameDataIO_PLY.hpp"

#include "rhl_woundcare/sc3d/ColorImage.hpp"
#include "rhl_woundcare/sc3d/DepthImage.hpp"
#include "rhl_woundcare/sc3d/PerspectiveCamera.hpp"

#include "rhl_woundcare/math/Mat3x3.hpp"

#include "rhl_woundcare/test_helpers/TestHelpers.hpp"

/*
 #import <RHLwoundcareIO/RawFrameDataIO_PLY.hpp>
 
 #import "DebugHelpers.hpp"
 #import "TestHelpers/PathHelpers.h"
 */



using namespace rhl_woundcare::sc3d;
using namespace rhl_woundcare::math;

TEST(BPLYFrameFileIOTests, testReading) {
    std::string testFrame = rhl_woundcare::getTestCasesPath() + std::string("frame-000.ply");
    
    ColorImage image;
    DepthImage depth;
    PerspectiveCamera camera;
    
    bool ok = rhl_woundcare::io::ply::ReadRawFrameDataFromPLYFile(image, depth, camera, testFrame);
    EXPECT_TRUE(ok);
    
    EXPECT_EQ(image.getWidth(), 320);
    EXPECT_EQ(image.getHeight(), 240);
    
    EXPECT_EQ(depth.getWidth(), 320);
    EXPECT_EQ(depth.getHeight(), 240);
    
    EXPECT_TRUE(Mat3x3::almostEqual(
                                    camera.getIntrinsicMatrix(),
                                    Mat3x3{
        2881.16,       0, 1536.59,
        0, 2881.16, 1149.33,
        0,       0,       1
    },
                                    1.0e-5, 1.0e-5
                                    ));
    
    EXPECT_EQ(camera.getIntrinsicMatrixReferenceSize().x, 3088.0);
    EXPECT_EQ(camera.getIntrinsicMatrixReferenceSize().y, 2316.0);
}
