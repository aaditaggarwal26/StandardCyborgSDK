//
//  BenchmarkUtils.hpp
//  RHLwoundcare
//
//  Created by eric on 2019-10-24.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <string>

@class SCPointCloud;

std::string benchmarkAll(NSArray *allTestCases, void (^progressHandler)(int frameIndex, SCPointCloud *pointCloud));
