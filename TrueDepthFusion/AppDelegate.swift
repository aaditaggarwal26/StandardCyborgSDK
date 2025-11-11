//
//  AppDelegate.swift
//  TrueDepthFusion
//
//  Created by Aaron Thompson on 8/12/18.
//  Copyright © 2018 Standard Cyborg. All rights reserved.
//

import ARKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        reloadScans()
        
        return true
    }
    
    private(set) var scans: [Scan] = []
    
    private var _scansContainerURL: URL {
        return URL(fileURLWithPath: NSHomeDirectory().appending("/Documents"))
    }
    
    func reloadScans() {
        let urls = try! FileManager.default.contentsOfDirectory(at: _scansContainerURL, includingPropertiesForKeys: nil, options: [])
        let plyURLs = urls
            .filter { $0.pathExtension == "ply" }
            .filter { !$0.lastPathComponent.contains("-mesh") }
        
        scans = plyURLs.map { url in Scan(plyPath: url.path) }
                .sorted { $0.dateCreated.compare($1.dateCreated) == .orderedDescending }
    }
    
    func add(_ scan: Scan) {
        if scan.plyPath == nil {
            do {
                try scan.write(toContainerPath: _scansContainerURL.path)
                scans.insert(scan, at: 0)
                
                // Automatically backup scan to user-accessible location
                backupScanToDocuments(scan)
            } catch {
                print("Error saving scan: \(error)")
            }
        }
    }
    
    private func backupScanToDocuments(_ scan: Scan) {
        // Create a "RHL Scans" folder in Documents that's accessible via Files app
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let backupFolderURL = documentsURL.appendingPathComponent("RHL Scans")
        
        // Create the folder if it doesn't exist
        if !fileManager.fileExists(atPath: backupFolderURL.path) {
            try? fileManager.createDirectory(at: backupFolderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Export the scan with a timestamped filename
        DispatchQueue.global(qos: .background).async {
            let compressedURL = scan.writeCompressedPLY()
            let destinationURL = backupFolderURL.appendingPathComponent(compressedURL.lastPathComponent)
            
            // Copy the file
            try? fileManager.copyItem(at: compressedURL, to: destinationURL)
            
            print("✓ Scan automatically backed up to: \(destinationURL.path)")
        }
    }
    
    func remove(_ scan: Scan) {
        if let index = scans.firstIndex(of: scan) {
            do {
                try scan.deleteFiles()
                scans.remove(at: index)
            } catch {
                print("Error deleting files: \(error)")
            }
        }
    }
    
    func createBPLYScanDirectory() -> String {
        let directoryName = Scan.string(from: Date())
        let absoluteDirectory = _scansContainerURL.appendingPathComponent(directoryName)
        
        try? FileManager.default.createDirectory(at: absoluteDirectory, withIntermediateDirectories: false, attributes: nil)
        
        return absoluteDirectory.path
    }
    
}
