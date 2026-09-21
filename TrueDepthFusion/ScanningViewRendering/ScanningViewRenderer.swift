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

    /// Caps how many frames may be queued to the GPU at once.
    ///
    /// This draw runs on the capture queue, and used to end by blocking on
    /// `waitUntilCompleted`. That made every frame cost CPU time *plus* GPU time
    /// rather than whichever is larger, and because the capture outputs discard
    /// late frames, anything the camera produced while the queue was blocked was
    /// thrown away — which is what the judder was.
    ///
    /// Letting frames overlap fixes that, but an unbounded queue would only trade
    /// judder for latency, so two is the cap: one being drawn, one being prepared.
    private let _inFlightFrames = DispatchSemaphore(value: 2)

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
            _inFlightFrames.wait()

            let commandBuffer = _commandQueue.makeCommandBuffer()!
            commandBuffer.label = "ScanningViewRenderer.commandBuffer"

            guard let drawable = metalLayer.nextDrawable() else {
                commandBuffer.commit()
                _inFlightFrames.signal()
                return
            }
            let outputTexture = drawable.texture

            _pointCloudRenderer.overlayOpacity = AppSetting.float(AppSetting.pointCloudOverlayOpacity, 1.0)
            _depthColoringFilter.previewBrightness = AppSetting.float(AppSetting.previewBrightness, 1.0)
            
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
            
            commandBuffer.addCompletedHandler { [weak self] _ in
                self?._inFlightFrames.signal()
            }

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
