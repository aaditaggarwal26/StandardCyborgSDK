//
//  ScanSessionRecord.swift
//  TrueDepthFusion
//
//  How a scan was captured — how long it took, and whether the camera was
//  mirrored — saved as a JSON sidecar next to the .ply, the same convention
//  WoundMeasurement and ClassificationRecord use.
//
//  Capture mode is recorded because it determines the handedness of the
//  geometry in the PLY, and that cannot be recovered from the file afterwards:
//  a mirrored scan and an unmirrored one are both perfectly valid point clouds.
//

import Foundation

struct ScanSessionRecord: Codable {

    let startedAt: Date

    /// Wall-clock seconds from the shutter firing to the scan stopping. Measured
    /// at the moment capture ends rather than when reconstruction finishes, so
    /// it reflects how long the clinician held the phone, not how long the maths
    /// took afterwards.
    let durationSeconds: Double

    /// True when captured selfie-style (mirrored), false when captured through
    /// the rear mirror adapter.
    let selfieMode: Bool
}

extension Scan {

    /// Sidecar JSON path for this scan's capture session. Same pattern as
    /// `classificationPath` — nil until the scan has a plyPath.
    var sessionPath: String? {
        guard let plyPath = plyPath else { return nil }

        return (plyPath as NSString).deletingPathExtension + "-session.json"
    }

    func loadSession() -> ScanSessionRecord? {
        guard let path = sessionPath,
              let data = FileManager.default.contents(atPath: path)
        else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(ScanSessionRecord.self, from: data)
    }

    @discardableResult
    func saveSession(_ record: ScanSessionRecord) -> Bool {
        guard let path = sessionPath else { return false }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(record) else { return false }

        return (try? data.write(to: URL(fileURLWithPath: path), options: .atomic)) != nil
    }

    func deleteSessionFile() {
        guard let path = sessionPath else { return }

        try? FileManager.default.removeItem(atPath: path)
    }
}
