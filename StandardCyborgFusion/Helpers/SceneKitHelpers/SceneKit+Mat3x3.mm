//
//  SceneKit+Mat3x4.m
//  RHLwoundcareData
//
//  Created by Eric Arneback on 5/21/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import "SceneKit+Mat3x3.h"
#include <vector>

#include <rhl_woundcare/math/Vec3.hpp>
#include <rhl_woundcare/math/Mat3x4.hpp>

#import "SceneKit+Mat3x4.h"

using namespace rhl_woundcare;

@implementation SCNNode (RHLwoundcareDataMat3x3)

+ (instancetype)nodeFromMat3x3:(const math::Mat3x3&)mat withScale:(float)scale
{
    math::Mat3x4 m = {
        mat.m00, mat.m01, mat.m02, 0.0f,
        mat.m10, mat.m11, mat.m12, 0.0f,
        mat.m20, mat.m21, mat.m22, 0.0f
    };
    
    SCNNode *node = [SCNNode nodeFromMat3x4:m withScale:scale];

    return node;
}

@end
