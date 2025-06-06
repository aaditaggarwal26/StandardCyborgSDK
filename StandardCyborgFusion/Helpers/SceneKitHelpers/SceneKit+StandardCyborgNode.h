//
//  SCNNode+RHLwoundcareNode.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 8/6/19.
//  Copyright © 2019 RHLwoundcare. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <rhl_woundcare/scene_graph/SceneGraph.hpp>
#import <memory>

NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (RHLwoundcareNode)

+ (SCNNode * _Nullable)nodeFromRHLwoundcareNode:(std::shared_ptr<rhl_woundcare::scene_graph::Node>)node
                             withDefaultTransform:(BOOL)useDefaultTransform;

@end

NS_ASSUME_NONNULL_END
