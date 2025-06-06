//
//  DepthProcessor.hpp
//  RHLwoundcare
//
//  Created by Aaron Thompson on 8/14/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#pragma once

#include "ProcessedFrame.hpp"
#include <RHLwoundcare/RawFrame.hpp>

class DepthProcessor {
public:
    virtual void computeFrameValues(ProcessedFrame &frameOut,
                                    const RawFrame &rawFrame,
                                    bool smoothPoints = false) = 0;
};
