//
//  RawFrame.hpp
//  RHLwoundcare
//
//  Created by Ricky Reusser on 10/16/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#pragma once

#include <rhl_woundcare/sc3d/PerspectiveCamera.hpp>

using namespace rhl_woundcare;

#define METAL_REQUIRED_ALIGNMENT 4096

struct RawFrame {
    sc3d::PerspectiveCamera camera;
    size_t width, height;
    
    std::vector<float> depths __attribute__((aligned(METAL_REQUIRED_ALIGNMENT)));
    std::vector<math::Vec3> colors __attribute__((aligned(METAL_REQUIRED_ALIGNMENT)));
    
    double timestamp;

    RawFrame(sc3d::PerspectiveCamera cameraIn, size_t widthIn, size_t heightIn) :
        camera(cameraIn),
        width(widthIn),
        height(heightIn),
        depths(widthIn * heightIn, 0.0f),
        colors(widthIn * heightIn, math::Vec3())
    { }
    
    RawFrame(sc3d::PerspectiveCamera cameraIn, size_t widthIn, size_t heightIn, std::vector<float>& depthsIn, std::vector<math::Vec3>& colorsIn, double timestampIn) :
        camera(cameraIn),
        width(widthIn),
        height(heightIn),
        depths(depthsIn),
        colors(colorsIn),
        timestamp(timestampIn)
    { }
    
private:
    // Prohibit copying and assignment
    // But actually allow the copy constructor because it's needed for SCOfflineReconstructionManager
    // RawFrame(const RawFrame&) = delete;
    RawFrame& operator=(const RawFrame&) = delete;
};
