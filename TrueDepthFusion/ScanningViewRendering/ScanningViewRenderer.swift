//
//  ScanningViewRenderer.swift
//  TrueDepthFusion
//
//  Created by Aaron Thompson on 9/23/18.
//  Copyright © 2018 Standard Cyborg. All rights reserved.
//

import AVFoundation
import Foundation
import Metal
import StandardCyborgFusion

class ScanningViewRenderer
{
    private let _device: MTLDevice
    private let _library: MTLLibrary
    private let _commandQueue: MTLCommandQueue
    private let _depthColoringFilter: DepthColoringFilter
    private let _pointCloudRenderer: SCPointCloudRenderer
    
    /// Read straight from the Settings bundle rather than cached, so changing the
    /// slider takes effect as soon as the user returns to the app.
    ///
    /// Settings-bundle defaults are only registered once the user visits the settings
    /// page, so an untouched key is absent rather than 1.0. Reading it as a plain float
    /// would yield 0 and make the overlay invisible on a fresh install, hence the
    /// explicit fallback.
    private static var _overlayOpacitySetting: Float {
        guard let value = UserDefaults.standard.object(forKey: "pointcloud_overlay_opacity") as? NSNumber else {
            return 1.0
        }

        return min(max(value.floatValue, 0.0), 1.0)
    }

    init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        _device = device
        _commandQueue = commandQueue
        _library = device.makeDefaultLibrary()!
        
        _depthColoringFilter = DepthColoringFilter(device: _device, library: _library)
        _pointCloudRenderer = SCPointCloudRenderer(device: _device, library: _library)
    }
    
    func draw(colorBuffer: CVPixelBuffer,
              depthBuffer: CVPixelBuffer?,
              pointCloud: SCPointCloud?,
              depthCameraCalibrationData: AVCameraCalibrationData,
              viewMatrix: matrix_float4x4,
              into metalLayer: CAMetalLayer,
              flipsInputHorizontally: Bool)
    {
        autoreleasepool {
            let commandBuffer = _commandQueue.makeCommandBuffer()!
            commandBuffer.label = "ScanningViewRenderer.commandBuffer"
            
            guard let drawable = metalLayer.nextDrawable() else { return }
            let outputTexture = drawable.texture

            _pointCloudRenderer.overlayOpacity = ScanningViewRenderer._overlayOpacitySetting
            
            _depthColoringFilter.encodeCommands(onto: commandBuffer,
                                                colorBuffer: colorBuffer,
                                                depthBuffer: nil,
                                                outputTexture: outputTexture)
            
            if let depthBuffer = depthBuffer,
               let pointCloud = pointCloud,
               pointCloud.pointCount > 0
            {
                let depthFrameSize = CGSize(width: CVPixelBufferGetWidth(depthBuffer),
                                            height: CVPixelBufferGetHeight(depthBuffer))
                
                _pointCloudRenderer.encodeCommands(onto: commandBuffer,
                                                   pointCloud: pointCloud,
                                                   depthCameraCalibrationData: depthCameraCalibrationData,
                                                   viewMatrix: viewMatrix,
                                                   outputTexture: outputTexture,
                                                   depthFrameSize: depthFrameSize,
                                                   flipsInputHorizontally: flipsInputHorizontally)
            }
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
    }
}
