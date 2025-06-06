//
//  MetalDepthProcessorData.h
//  RHLwoundcare
//
//  Created by Ricky Reusser on 9/24/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <Metal/Metal.h>
#import <rhl_woundcare/util/IncludeEigen.hpp>
#import <rhl_woundcare/math/Vec3.hpp>


struct MetalDepthProcessorData {
    size_t width;
    size_t height;
    
    id<MTLBuffer> pointsBuffer;
    id<MTLBuffer> weightsBuffer;
    id<MTLBuffer> inputConfidencesBuffer;
    id<MTLBuffer> normalsBuffer;
    id<MTLBuffer> surfelSizesBuffer;
    
    id<MTLBuffer> workBuffer;
    
    id<MTLTexture> depthTexture;
    id<MTLTexture> workTexture;
    id<MTLTexture> smoothedDepthTexture;
    
    MetalDepthProcessorData();
    ~MetalDepthProcessorData();
    
    void fill(
        id<MTLDevice> device,
        size_t width,
        size_t height,
        const std::vector<float> &depths,      
        std::vector<rhl_woundcare::math::Vec3> &points,
        std::vector<rhl_woundcare::math::Vec3> &normals,
        std::vector<float> &surfelSizes,
        std::vector<float> &weights,
        std::vector<float> &inputConfidences
    );

private:
    // Prohibit copying and assignment
    MetalDepthProcessorData(const MetalDepthProcessorData&) = delete;
    MetalDepthProcessorData& operator=(const MetalDepthProcessorData&) = delete;
};
