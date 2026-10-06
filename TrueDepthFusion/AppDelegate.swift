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

    // MARK: - Trash

    private var _trashContainerURL: URL {
        return _scansContainerURL.appendingPathComponent("Trash")
    }

    /// Scans are plain files in one folder and `reloadScans()` lists that folder
    /// without recursing, so moving a scan into a subfolder is all it takes to take
    /// it out of the list while keeping the files intact.
    func moveToTrash(_ scan: Scan) {
        guard let plyPath = scan.plyPath else { return }

        try? FileManager.default.createDirectory(at: _trashContainerURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)

        if _moveScan(atPLYPath: plyPath, into: _trashContainerURL),
           let index = scans.firstIndex(of: scan)
        {
            scans.remove(at: index)
        }
    }

    func trashedScans() -> [Scan] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: _trashContainerURL,
                                                                      includingPropertiesForKeys: nil,
                                                                      options: [])
        else { return [] }

        return urls
            .filter { $0.pathExtension == "ply" }
            .map { url in Scan(plyPath: url.path) }
            .sorted { $0.dateCreated.compare($1.dateCreated) == .orderedDescending }
    }

    func restoreFromTrash(_ scan: Scan) {
        guard let plyPath = scan.plyPath else { return }

        if _moveScan(atPLYPath: plyPath, into: _scansContainerURL) {
            reloadScans()
        }
    }

    func deletePermanently(_ scan: Scan) {
        do {
            try scan.deleteFiles()
        } catch {
            print("Error deleting files: \(error)")
        }
    }

    func emptyTrash() {
        for scan in trashedScans() {
            deletePermanently(scan)
        }
    }

    /// Moves a scan's PLY and its thumbnail together. The thumbnail is found by
    /// filename rather than stored alongside, so leaving it behind would orphan it
    /// and the restored scan would come back without a preview image.
    ///
    /// Refuses rather than overwriting if the destination name is taken, since the
    /// file being overwritten would be somebody's scan.
    private func _moveScan(atPLYPath plyPath: String, into directory: URL) -> Bool {
        let fileManager = FileManager.default
        let sourcePLY = URL(fileURLWithPath: plyPath)
        let sourceJPEG = sourcePLY.deletingPathExtension().appendingPathExtension("jpeg")
        let destinationPLY = directory.appendingPathComponent(sourcePLY.lastPathComponent)
        let destinationJPEG = directory.appendingPathComponent(sourceJPEG.lastPathComponent)

        guard !fileManager.fileExists(atPath: destinationPLY.path) else {
            print("Not moving \(sourcePLY.lastPathComponent): a file of that name is already there")
            return false
        }

        do {
            try fileManager.moveItem(at: sourcePLY, to: destinationPLY)
        } catch {
            print("Error moving scan: \(error)")
            return false
        }

        // A scan whose thumbnail failed to write should still move.
        if fileManager.fileExists(atPath: sourceJPEG.path) {
            try? fileManager.moveItem(at: sourceJPEG, to: destinationJPEG)
        }

        return true
    }
    
    func createBPLYScanDirectory() -> String {
        let directoryName = Scan.string(from: Date())
        let absoluteDirectory = _scansContainerURL.appendingPathComponent(directoryName)
        
        try? FileManager.default.createDirectory(at: absoluteDirectory, withIntermediateDirectories: false, attributes: nil)
        
        return absoluteDirectory.path
    }
    
}
