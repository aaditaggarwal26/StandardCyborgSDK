//
//  PBFFinalStatistics.h
//  RHLwoundcareSDK
//
//  Created by eric on 2019-10-24.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

typedef struct {
    int mergedFrameCount;
    double framerate;
    double averageICPIterations;
    int failedFrameCount;
    float averageCorrespondenceError;
} PBFFinalStatistics;
