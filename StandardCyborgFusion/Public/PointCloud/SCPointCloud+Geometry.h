//
//  SCPointCloud+Geometry.h
//  RHLwoundcareData
//
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <RHLwoundcare/SCPointCloud.h>

#ifdef __cplusplus
#import <rhl_woundcare/sc3d/Geometry.hpp>

NS_ASSUME_NONNULL_BEGIN

using namespace rhl_woundcare;

@interface SCPointCloud (Geometry)

- (void)toGeometry:(sc3d::Geometry&)geometry;

@end

NS_ASSUME_NONNULL_END

#endif // __cplusplus
