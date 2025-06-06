//
//  PerspectiveCamera+AVFoundation.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 12/19/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <rhl_woundcare/sc3d/PerspectiveCamera.hpp>

@class AVCameraCalibrationData;

extern rhl_woundcare::sc3d::PerspectiveCamera PerspectiveCameraFromAVCameraCalibrationData(AVCameraCalibrationData *calibrationData, size_t pixelsWide, size_t pixelsHigh);
