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
        var summaryBlocks: [String] = []

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

            let session = scan.loadSession()
            if let session {
                let data = try JSONEncoder.sidecarEncoder.encode(session)
                try data.write(to: scanDir.appendingPathComponent("session.json"))
            }

            summaryBlocks.append(summaryBlock(baseName: baseName,
                                              dateCreated: scan.dateCreated,
                                              session: session,
                                              classification: classification,
                                              measurementsCm: measurements.map { $0.distanceCentimeters }))

            manifestEntries.append([
                "scan": baseName,
                "dateCreated": ISO8601DateFormatter().string(from: scan.dateCreated),
                "finalWoundType": classification?.finalWoundType as Any,
                "wasReviewed": classification?.wasReviewed ?? false,
                "clinicianOverrodeModel": didClinicianOverride(classification),
                "reviewedBy": classification?.reviewedBy as Any,
                "scanDurationSeconds": session?.durationSeconds as Any,
                "selfieMode": session?.selfieMode as Any,
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

        // A plain-text companion to manifest.json, for reading rather than parsing.
        let summary = ("Wound scan export\n"
                       + "Exported: \(readableFormatter.string(from: Date()))\n"
                       + "Scans: \(summaryBlocks.count)\n\n"
                       + summaryBlocks.joined(separator: "\n"))
        try summary.write(to: exportRoot.appendingPathComponent("summary.txt"),
                          atomically: true,
                          encoding: .utf8)

        return try zipDirectory(at: exportRoot, fileManager: fileManager)
    }

    // MARK: - Summary text

    /// True only when the clinician recorded a wound type that differs from what
    /// the model predicted. A clinician who reviewed a scan and agreed with the
    /// model has not overridden it, and the summary says so separately — the two
    /// are different facts and collapsing them would hide agreement.
    private static func didClinicianOverride(_ record: ClassificationRecord?) -> Bool {
        guard let clinicianType = record?.clinicianWoundType else { return false }

        return clinicianType != record?.topModelPrediction?.label
    }

    private static func summaryBlock(baseName: String,
                                     dateCreated: Date,
                                     session: ScanSessionRecord?,
                                     classification: ClassificationRecord?,
                                     measurementsCm: [Double]) -> String
    {
        var lines: [String] = []

        lines.append(baseName)
        lines.append("  Captured:      \(readableFormatter.string(from: dateCreated))")

        if let session {
            lines.append("  Scan duration: \(formatDuration(session.durationSeconds))")
            lines.append("  Capture mode:  \(session.selfieMode ? "selfie (mirrored)" : "rear adapter (not mirrored)")")
        } else {
            lines.append("  Scan duration: not recorded")
        }

        if let classification {
            if let top = classification.topModelPrediction {
                lines.append("  Model predicted: \(top.label) (distance \(String(format: "%.3f", top.distance)))")
            } else {
                lines.append("  Model predicted: no prediction recorded")
            }

            if let clinicianType = classification.clinicianWoundType {
                if didClinicianOverride(classification) {
                    lines.append("  CLINICIAN OVERRODE THE MODEL")
                    lines.append("    Clinician's wound type: \(clinicianType)")
                } else {
                    lines.append("  Clinician reviewed and agreed with the model")
                }

                if let reviewedBy = classification.reviewedBy, !reviewedBy.isEmpty {
                    lines.append("    Reviewed by: \(reviewedBy)")
                }
                if let reviewedAt = classification.reviewedAt {
                    lines.append("    Reviewed at: \(readableFormatter.string(from: reviewedAt))")
                }
                if let notes = classification.clinicianNotes, !notes.isEmpty {
                    lines.append("    Notes: \(notes)")
                }
            } else {
                lines.append("  Not reviewed by a clinician")
            }

            lines.append("  Final wound type: \(classification.finalWoundType ?? "none")")
        } else {
            lines.append("  No classification was run")
        }

        if measurementsCm.isEmpty {
            lines.append("  Measurements: none")
        } else {
            let formatted = measurementsCm.map { String(format: "%.2f cm", $0) }.joined(separator: ", ")
            lines.append("  Measurements (\(measurementsCm.count)): \(formatted)")
        }

        return lines.joined(separator: "\n") + "\n"
    }

    private static func formatDuration(_ seconds: Double) -> String {
        if seconds < 60 { return String(format: "%.1f s", seconds) }

        let whole = Int(seconds.rounded())

        return "\(whole / 60) m \(whole % 60) s"
    }

    private static let readableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

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
