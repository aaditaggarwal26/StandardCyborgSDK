//
//  SCAssimilatedFrameMetadata_Private.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 12/20/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <RHLwoundcare/PBFAssimilatedFrameMetadata.hpp>
#import <RHLwoundcare/SCAssimilatedFrameMetadata.h>
#import <RHLwoundcare/EigenHelpers.hpp>

static SCAssimilatedFrameMetadata
SCAssimilatedFrameMetadataFromPBFAssimilatedFrameMetadata(PBFAssimilatedFrameMetadata pbfMetadata,
                                                          NSInteger consecutiveFailedFrameCount)
{
    static const float kPoorTrackingQualityThreshold = 0.1;
    static const NSInteger kMaxConsecutiveFailedFrameCount = 8;
    
    SCAssimilatedFrameMetadata metadata;
    metadata.viewMatrix = toSimdFloat4x4(pbfMetadata.viewMatrix);

    metadata.projectionMatrix = toSimdFloat4x4(pbfMetadata.projectionMatrix);
    metadata.colorBuffer = NULL;
    metadata.depthBuffer = NULL;
    
    if (pbfMetadata.isMerged == false && consecutiveFailedFrameCount + 1 >= kMaxConsecutiveFailedFrameCount) {
        metadata.result = SCAssimilatedFrameResultFailed;
    } else if (pbfMetadata.isMerged == false) {
        metadata.result = SCAssimilatedFrameResultLostTracking;
    } else if (pbfMetadata.icpUnusedIterationFraction < kPoorTrackingQualityThreshold) {
        metadata.result = SCAssimilatedFrameResultPoorTracking;
    } else {
        metadata.result = SCAssimilatedFrameResultSucceeded;
    }
    
    return metadata;
}
