//
//  SceneKit+Lines.h
//  RHLwoundcareSDK
//
//  Created by Eric Arnebäck on 5/20/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <rhl_woundcare/sc3d/Line.hpp>

using namespace rhl_woundcare;

NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (RHLwoundcareDataLines)

+ (instancetype)nodeFromLines:(const std::vector<sc3d::Line>&)lines withColors:(const std::vector<math::Vec3>&)colors;

@end

NS_ASSUME_NONNULL_END

