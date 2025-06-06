//
//  DrawRawDepths.hpp
//  VisualTesterMac
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <RHLwoundcare/EigenHelpers.hpp>
#import <RHLwoundcare/RawFrame.hpp>
#import <RHLwoundcare/RHLwoundcare.h>

@protocol CAMetalDrawable;

NS_ASSUME_NONNULL_BEGIN

@interface DrawRawDepths : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device
                  commandQueue:(id<MTLCommandQueue>)commandQueue
                       library:(id<MTLLibrary>)library;

- (void)draw:(const std::shared_ptr<RawFrame>)rawFrame into:(id<CAMetalDrawable>)drawable;

@end

NS_ASSUME_NONNULL_END
