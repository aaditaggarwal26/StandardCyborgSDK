//
//  ReconstructionHelpers.h
//  RHLwoundcare
//
//  Created by Ricky Reusser on 5/1/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#include "PBFModel.hpp"
#include "ScreenSpaceLandmark.hpp"

#include <functional>
#include <memory>
#include <vector>

#include <vector>

 
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif


std::unique_ptr<PBFModel> assimilatePointCloud(NSString* depthFramesDir,
                                               ICPConfiguration icpConfig,
                                               PBFConfiguration pbfConfig,
                                               SurfelFusionConfiguration surfelFusionConfig);

std::unique_ptr<PBFModel> assimilatePointCloud(NSString* depthFramesDir,
                                               ICPConfiguration icpConfig,
                                               PBFConfiguration pbfConfig,
                                               SurfelFusionConfiguration surfelFusionConfig,
                                               std::function<std::vector<ScreenSpaceLandmark>(int)>getFrameLandmarks);
