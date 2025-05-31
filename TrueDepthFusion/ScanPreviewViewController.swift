//
//  ScanPreviewViewController.swift
//  DepthRenderer
//
//  Created by Aaron Thompson on 5/11/18.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

import Foundation
import ModelIO
import QuickLook
import StandardCyborgFusion
import SceneKit
import UIKit
import MessageUI
import SwiftUI

class ScanPreviewViewController: UIViewController, QLPreviewControllerDataSource {
    
    // MARK: - IB Outlets and Actions
    
    @IBOutlet private weak var sceneView: SCNView!
    @IBOutlet private weak var meshButton: UIButton!
    @IBOutlet private weak var meshingProgressContainer: UIView!
    @IBOutlet private weak var meshingProgressView: UIProgressView!
    private var _quickLookOBJURL: URL?
    
    @IBAction private func _export(_ sender: AnyObject) {
        if let scan = scan {
            // Skip meshing entirely, this just exports the point cloud directly .
            let shareURL = scan.writeCompressedPLY()
            
            _quickLookOBJURL = shareURL
            
            // Send directly to email with the point cloud data
            let emailView = SendEmailController(zipFileURL: shareURL)
            let emailController = UIHostingController(rootView: emailView)
            self.present(emailController, animated: true, completion: nil)
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return _quickLookOBJURL! as QLPreviewItem
    }
    
    @IBAction private func _delete(_ sender: Any) {
        deletionHandler?()
    }
    
    @IBAction private func _done(_ sender: Any) {
        doneHandler?()
    }
    
    // Removed the meshing functionality
    @IBAction private func _runMeshing(_ sender: Any) {
        // Just trigger export directly since we're skipping meshing
        _export(sender as AnyObject)
    }
    
    @IBAction private func cancelMeshing(_ sender: Any) {
        // No longer needed but keeping for storyboard compatibility
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        _initialPointOfView = sceneView.pointOfView!.transform
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sceneView.pointOfView!.transform = _initialPointOfView
        // Hide meshing button since we're not using it anymore
        meshButton.isHidden = true
        // Hide meshing progress container since we won't need it
        meshingProgressContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let scan = scan, scan.thumbnail == nil {
            let snapshot = sceneView.snapshot()
            scan.thumbnail = snapshot.resized(toWidth: 640)
        }
    }
    
    // MARK: - Public
    
    var scan: Scan? {
        didSet {
            _pointCloudNode = scan?.pointCloud.buildNode()
        }
    }
    
    var deletionHandler: (() -> Void)?
    var doneHandler: (() -> Void)?
    
    // MARK: - Private
    
    private let _appDelegate = UIApplication.shared.delegate! as! AppDelegate
    private var _initialPointOfView = SCNMatrix4Identity
    private var _pointCloudNode: SCNNode? {
        willSet {
            _pointCloudNode?.removeFromParentNode()
        }
        didSet {
            _pointCloudNode?.name = "point cloud"
            
            // Make sure the view is loaded first
            _ = self.view
            
            if let node = _pointCloudNode {
                sceneView.scene!.rootNode.addChildNode(node)
            }
        }
    }
}