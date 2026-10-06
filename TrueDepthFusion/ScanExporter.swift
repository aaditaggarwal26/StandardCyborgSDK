import Foundation

/// Bundles one or more scans — their .ply, .jpeg thumbnail, measurements
/// sidecar, and classification sidecar — into a single zip a clinician can
/// AirDrop, email, or save to Files.
///
/// Layout produced:
///   manifest.json                        <- summary across all scans in this export
///   <ScanBaseName>/<ScanBaseName>.ply
///   <ScanBaseName>/<ScanBaseName>.jpeg    <- only if a thumbnail was ever saved
///   <ScanBaseName>/measurements.json      <- only if measurements exist
///   <ScanBaseName>/classification.json    <- only if a classification was run/reviewed
enum ScanExporter {

    struct ExportError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    static func exportZip(for scans: [Scan], fileManager: FileManager = .default) throws -> URL {
        let exportRoot = fileManager.temporaryDirectory
            .appendingPathComponent("wound_export_\(Int(Date().timeIntervalSince1970))", isDirectory: true)
        try fileManager.createDirectory(at: exportRoot, withIntermediateDirectories: true)

        var manifestEntries: [[String: Any]] = []

        for scan in scans {
            // An unsaved scan (plyPath == nil) has nothing on disk to export yet.
            guard let plyPath = scan.plyPath else { continue }

            let baseName = (plyPath as NSString).lastPathComponent.replacingOccurrences(of: ".ply", with: "")
            let scanDir = exportRoot.appendingPathComponent(baseName, isDirectory: true)
            try fileManager.createDirectory(at: scanDir, withIntermediateDirectories: true)

            copyIfExists(fileManager, from: plyPath, to: scanDir.appendingPathComponent("\(baseName).ply").path)

            let jpegPath = plyPath.replacingOccurrences(of: ".ply", with: ".jpeg")
            copyIfExists(fileManager, from: jpegPath, to: scanDir.appendingPathComponent("\(baseName).jpeg").path)

            let measurements = scan.loadMeasurements()
            if !measurements.isEmpty {
                let data = try JSONEncoder.sidecarEncoder.encode(measurements)
                try data.write(to: scanDir.appendingPathComponent("measurements.json"))
            }

            let classification = scan.loadClassification()
            if let classification {
                let data = try JSONEncoder.sidecarEncoder.encode(classification)
                try data.write(to: scanDir.appendingPathComponent("classification.json"))
            }

            manifestEntries.append([
                "scan": baseName,
                "dateCreated": ISO8601DateFormatter().string(from: scan.dateCreated),
                "finalWoundType": classification?.finalWoundType as Any,
                "wasReviewed": classification?.wasReviewed ?? false,
                "reviewedBy": classification?.reviewedBy as Any,
                "measurementCount": measurements.count,
                "measurementsCm": measurements.map { $0.distanceCentimeters }
            ])
        }

        let manifest: [String: Any] = [
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
            "scanCount": manifestEntries.count,
            "scans": manifestEntries
        ]
        let manifestData = try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
        try manifestData.write(to: exportRoot.appendingPathComponent("manifest.json"))

        return try zipDirectory(at: exportRoot, fileManager: fileManager)
    }

    private static func copyIfExists(_ fileManager: FileManager, from sourcePath: String, to destinationPath: String) {
        guard fileManager.fileExists(atPath: sourcePath) else { return }
        try? fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
    }

    /// Zips a directory with no third-party dependency, using the
    /// NSFileCoordinator "upload" trick: coordinating a read with
    /// `.forUploading` hands back a temporary zip of the item.
    private static func zipDirectory(at directoryURL: URL, fileManager: FileManager) throws -> URL {
        var coordinatorError: NSError?
        var resultURL: URL?
        var thrownError: Error?

        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: directoryURL, options: [.forUploading], error: &coordinatorError) { zippedURL in
            do {
                let destination = fileManager.temporaryDirectory
                    .appendingPathComponent("\(directoryURL.lastPathComponent).zip")
                if fileManager.fileExists(atPath: destination.path) {
                    try fileManager.removeItem(at: destination)
                }
                try fileManager.copyItem(at: zippedURL, to: destination)
                resultURL = destination
            } catch {
                thrownError = error
            }
        }

        if let coordinatorError { throw coordinatorError }
        if let thrownError { throw thrownError }
        guard let resultURL else { throw ExportError(message: "Failed to create export zip.") }
        return resultURL
    }
}

extension JSONEncoder {
    static var sidecarEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
