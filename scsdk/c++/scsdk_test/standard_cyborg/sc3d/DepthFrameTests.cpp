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


/*
 #import <XCTest/XCTest.h>
 #include <iostream>
 
 #include <RHLwoundcareData/DebugHelpers.hpp>
 #include <RHLwoundcareData/DepthImage.hpp>
 
 using namespace RHLwoundcare;
 
 @interface DepthImageTests : XCTestCase
 
 @end
 
 @implementation DepthImageTests
 */

#include <gtest/gtest.h>

#include "rhl_woundcare/sc3d/DepthImage.hpp"

using namespace rhl_woundcare::sc3d;

TEST(DepthImageTests, testConstructor) {
    rhl_woundcare::sc3d::DepthImage frame;
    EXPECT_EQ(frame.getWidth(), 0);
    EXPECT_EQ(frame.getHeight(), 0);
    EXPECT_EQ(frame.getData().size(), 0);
}

TEST(DepthImageTests, testConstructorWithSize) {
    rhl_woundcare::sc3d::DepthImage frame (2, 2);
    EXPECT_EQ(frame.getWidth(), 2);
    EXPECT_EQ(frame.getHeight(), 2);
    EXPECT_EQ(frame.getData().size(), 4);
}

TEST(DepthImageTests, testConstructorWithSizeAndData) {
    rhl_woundcare::sc3d::DepthImage frame (1, 1, {1});
    EXPECT_EQ(frame.getWidth(), 1);
    EXPECT_EQ(frame.getHeight(), 1);
    //EXPECT_TRUE(Vec4::almostEqual(frame.getData()[0], {1, 0, 1, 0}));
}

TEST(DepthImageTests, testGetPixel) {
    rhl_woundcare::sc3d::DepthImage frame (2, 3, {0.0, 0.5, 0.75, 1.0, 0.0, 0.5});
    
    EXPECT_EQ(frame.getPixelAtColRow(0, 0), 0.0);
    EXPECT_EQ(frame.getPixelAtColRow(1, 0), 0.5);
    
    EXPECT_EQ(frame.getPixelAtColRow(0, 1), 0.75);
    EXPECT_EQ(frame.getPixelAtColRow(1, 1), 1.0);
    
    EXPECT_EQ(frame.getPixelAtColRow(0, 2), 0.0);
    EXPECT_EQ(frame.getPixelAtColRow(1, 2), 0.5);
}

TEST(DepthImageTests, testGetPixelConst) {
    const rhl_woundcare::sc3d::DepthImage frame (2, 3, {0.0, 0.5, 0.75, 1.0, 0.0, 0.5});
    
    EXPECT_EQ(frame.getPixelAtColRow(0, 0), 0.0);
    EXPECT_EQ(frame.getPixelAtColRow(1, 0), 0.5);
    
    EXPECT_EQ(frame.getPixelAtColRow(0, 1), 0.75);
    EXPECT_EQ(frame.getPixelAtColRow(1, 1), 1.0);
    
    EXPECT_EQ(frame.getPixelAtColRow(0, 2), 0.0);
    EXPECT_EQ(frame.getPixelAtColRow(1, 2), 0.5);
}

TEST(DepthImageTests, testGetTexCoordAtColRow) {
    rhl_woundcare::sc3d::DepthImage frame (2, 4);
    
    EXPECT_TRUE(frame.getTexCoordAtColRow(1, 3) == rhl_woundcare::math::Vec2((1.5f) / 2.0f, 3.5f / 4.0f));
}

TEST(DepthImageTests, testSetPixel) {
    rhl_woundcare::sc3d::DepthImage frame (2, 3);
    
    frame.setPixelAtColRow(0, 0, 1);
    frame.setPixelAtColRow(1, 0, 2);
    
    frame.setPixelAtColRow(0, 1, 3);
    frame.setPixelAtColRow(1, 1, 4);
    
    frame.setPixelAtColRow(0, 2, 5);
    frame.setPixelAtColRow(1, 2, 6);
    
    
    std::vector<float> expectedPixels {1, 2, 3, 4, 5, 6};
    
    for (int i = 0; i < frame.getWidth() * frame.getHeight(); i++) {
        EXPECT_EQ(frame.getData()[i], expectedPixels[i]);
    }
}

TEST(DepthImageTests, testCopy) {
    rhl_woundcare::sc3d::DepthImage i1 (2, 3, {1, 2, 3, 4, 5, 6});
    
    rhl_woundcare::sc3d::DepthImage i2;
    i2.copy(i1);
    
    EXPECT_EQ(i2.getWidth(), 2);
    EXPECT_EQ(i2.getHeight(), 3);
    
    for (int i = 0; i < i1.getWidth() * i1.getHeight(); i++) {
        EXPECT_EQ(i1.getData()[i], i2.getData()[i]);
    }
}

TEST(DepthImageTests, testGetSizeInBytes) {
    rhl_woundcare::sc3d::DepthImage i1 (2, 3, {1, 2, 3, 4, 5, 6});
    
    EXPECT_EQ(i1.getSizeInBytes(), 2 * 3 * sizeof(int));
}

TEST(DepthImageTests, testFlipYOddSize) {
    rhl_woundcare::sc3d::DepthImage frame (2, 3, {
        1, 2,
        3, 4,
        5, 6
    });
    
    frame.flipY();
    
    rhl_woundcare::sc3d::DepthImage expectedImage (2, 3, {
        5, 6,
        3, 4,
        1, 2
    });
    
    EXPECT_TRUE(frame == expectedImage);
}

TEST(DepthImageTests, testFlipYEvenSize) {
    rhl_woundcare::sc3d::DepthImage frame (2, 4, {
        1, 2,
        3, 4,
        5, 6,
        7, 8
    });
    
    frame.flipY();
    
    rhl_woundcare::sc3d::DepthImage expectedImage (2, 4, {
        7, 8,
        5, 6,
        3, 4,
        1, 2
    });
    
    EXPECT_TRUE(frame == expectedImage);
}

TEST(DepthImageTests, testFlipXEvenSize) {
    rhl_woundcare::sc3d::DepthImage frame (2, 3, {
        1, 2,
        3, 4,
        5, 6
    });
    
    frame.flipX();
    
    rhl_woundcare::sc3d::DepthImage expectedImage (2, 3, {
        2, 1,
        4, 3,
        6, 5
    });
    
    EXPECT_TRUE(frame == expectedImage);
}

TEST(DepthImageTests, testFlipXOddSize) {
    rhl_woundcare::sc3d::DepthImage frame (3, 1, {
        1, 2, 3
    });
    
    frame.flipX();
    
    rhl_woundcare::sc3d::DepthImage expectedImage (3, 1, {
        3, 2, 1
    });
    
    EXPECT_TRUE(frame == expectedImage);
}

TEST(DepthImageTests, testResetSize) {
    rhl_woundcare::sc3d::DepthImage frame;
    
    frame.resetSize(3, 4);
    
    EXPECT_EQ(frame.getWidth(), 3);
    EXPECT_EQ(frame.getHeight(), 4);
}

TEST(DepthImageTests, testForEachPixel) {
    rhl_woundcare::sc3d::DepthImage frame (2, 4, {
        1, 2,
        3, 4,
        5, 6,
        7, 8
    });
    
    float sum = 0.0;
    
    frame.forEachPixelAtColRow([&](int col, int row, float depth) {
        sum += depth;
    });
    EXPECT_EQ(sum, 36);
}

TEST(DepthImageTests, testMutatePixelsByColRow) {
    rhl_woundcare::sc3d::DepthImage frame (2, 3, {
        1, 2,
        3, 4,
        5, 6,
    });
    
    frame.mutatePixelsByColRow([&](int col, int row, float depth) {
        return depth + col + row;
    });
    
    rhl_woundcare::sc3d::DepthImage expectedImage (2, 3, {
        1, 3,
        4, 6,
        7, 9,
    });
    
    EXPECT_TRUE(expectedImage == frame);
}
