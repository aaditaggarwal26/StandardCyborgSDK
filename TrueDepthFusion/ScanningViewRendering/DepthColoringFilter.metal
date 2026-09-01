//
//  DepthColoringFilter.metal
//  TrueDepthFusion
//
//  Created by Aaron Thompson on 8/22/18.
//  Copyright © 2018 Standard Cyborg. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Uniforms
{
    float minDepth;
    float maxDepth;
    // Sits here rather than after the transform so it occupies padding that already
    // existed, leaving every other field at the offset it had before.
    float previewBrightness;
    float3x3 transform;
};

constant float minAlpha = 0.3;
constant float depthFeather = 0.002; // meters

kernel void DepthColoringFilter(texture2d<float, access::sample> colorTexture [[texture(0)]],
                                texture2d<float, access::sample> depthTexture [[texture(1)]],
                                texture2d<float, access::write> resultTexture [[texture(2)]],
                                constant Uniforms *uniforms [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    constexpr sampler colorSampler(coord::normalized, address::clamp_to_edge, filter::linear);
    constexpr sampler depthSampler(coord::normalized, address::clamp_to_edge, filter::nearest);
    
    float2 uv = (uniforms->transform * float3(float2(gid), 1.0)).xy;

    float4 color = colorTexture.sample(colorSampler, uv);
    float  depth = depthTexture.sample(depthSampler, uv).r;

    float alpha = max(smoothstep(uniforms->maxDepth + depthFeather, uniforms->maxDepth, depth),
                      smoothstep(uniforms->minDepth, uniforms->minDepth - depthFeather, depth));
    
    // Constrain the range of alpha adjustment
    color *= mix(minAlpha, 1.0, alpha);
    
    resultTexture.write(color, gid);
}

kernel void DrawColorTexture(texture2d<float, access::sample> colorTexture [[texture(0)]],
                             texture2d<float, access::write> resultTexture [[texture(1)]],
                             constant Uniforms *uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    constexpr sampler colorSampler(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float2 uv = (uniforms->transform * float3(float2(gid), 1.0)).xy;
    
    float4 color = colorTexture.sample(colorSampler, uv);

    // This used to be a flat multiply by minAlpha, which dimmed the whole camera
    // preview to 30% and is why the scanning screen looked so much darker than the
    // system camera. It is now adjustable, defaulting to full brightness.
    color.rgb *= uniforms->previewBrightness;

    resultTexture.write(color, gid);
}
