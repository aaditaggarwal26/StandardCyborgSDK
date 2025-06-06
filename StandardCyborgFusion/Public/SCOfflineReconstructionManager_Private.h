//
//  SCOfflineReconstructionManager_Private.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 12/18/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

// NOTE: This is Objective-C++. Guarding as such.
#ifdef __cplusplus

#import <RHLwoundcare/SCOfflineReconstructionManager.h>
#import <RHLwoundcare/SCReconstructionManagerParameters_Private.h>
#import <RHLwoundcare/ICP.hpp>
#import <RHLwoundcare/EigenHelpers.hpp>
#import <RHLwoundcare/Surfel.hpp>
#import <RHLwoundcare/RawFrame.hpp>
#import <RHLwoundcare/PBFAssimilatedFrameMetadata.hpp>
#import <memory>
#import <RHLwoundcare/PBFFinalStatistics.h>


@protocol SCOfflineReconstructionManagerDelegate;
@protocol MTLTexture;

NS_ASSUME_NONNULL_BEGIN

@interface SCOfflineReconstructionManager (Private) <SCReconstructionManagerParameters_Private>

@property (nonatomic, weak, nullable) id<SCOfflineReconstructionManagerDelegate> delegate;

/** The most recently processed rawFrame */
- (std::shared_ptr<RawFrame>)lastRawFrame;

- (const Surfels&)surfels;
- (const std::vector<uint32_t>&)surfelIndexMap;
- (id<MTLTexture>)surfelIndexMapTexture;
- (std::unique_ptr<RawFrame>)readBPLYWithPath:(NSString *)filePath;
- (SCAssimilatedFrameMetadata)accumulateFromRawFrame:(const RawFrame&)rawFrame;
- (const std::vector<PBFAssimilatedFrameMetadata>)assimilatedFrameMetadata;

@end


@protocol SCOfflineReconstructionManagerDelegate <NSObject>
@optional

- (void)reconstructionManager:(SCOfflineReconstructionManager *)manager didIterateICPWithResult:(ICPResult)result;

@end

NS_ASSUME_NONNULL_END

#endif
