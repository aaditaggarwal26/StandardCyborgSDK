//
//  NodeToNodeLineNode.h
//  RHLwoundcareGeometryTestbed
//
//  Created by Aaron Thompson on 4/6/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeToNodeLineNode : SCNNode

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStartNode:(SCNNode *)startNode
                          endNode:(SCNNode *)endNode
                        thickness:(CGFloat)thickness
                            color:(UIColor *)color
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
