//
//  ClassificationRecord.swift
//  TrueDepthFusion
//
//  Model + persistence for a wound classification result, saved as a JSON
//  sidecar next to the scan's .ply file — the same convention WoundMeasurement
//  uses (same base filename, different suffix), so classification results
//  survive past the alert they're currently only shown in.
//

import Foundation

struct ClassificationRecord: Codable {
    /// Mirrors WoundClassifier.Prediction — kept separate so this file has no
    /// dependency on WoundClassifier itself, same as WoundMeasurement has none
    /// on the measurement UI.
    struct ModelPrediction: Codable {
        let label: String
        let distance: Float  // nearest-prototype Euclidean distance; LOWER is closer
    }

    /// Full top-N predictions as shown in the classification alert, sorted
    /// closest-match first.
    let modelPredictions: [ModelPrediction]
    let dateCreated: Date

    // MARK: - Clinician review (nil fields = not yet reviewed)

    var clinicianWoundType: String?
    var clinicianNotes: String?
    var reviewedBy: String?
    var reviewedAt: Date?

    init(modelPredictions: [ModelPrediction], dateCreated: Date = Date()) {
        self.modelPredictions = modelPredictions
        self.dateCreated = dateCreated
    }

    /// The classifier's best guess — first element, since predictions are
    /// already sorted by ascending distance.
    var topModelPrediction: ModelPrediction? { modelPredictions.first }

    /// What should actually be used/displayed/exported: the clinician's
    /// choice if they reviewed it, otherwise the model's top guess.
    var finalWoundType: String? { clinicianWoundType ?? topModelPrediction?.label }

    var wasReviewed: Bool { clinicianWoundType != nil }
}

extension Scan {
    /// Sidecar JSON path for this scan's classification result. Same pattern
    /// as `measurementsPath` — nil until the scan has a plyPath.
    var classificationPath: String? {
        guard let plyPath = plyPath else { return nil }
        return (plyPath as NSString).deletingPathExtension + "-classification.json"
    }

    func loadClassification() -> ClassificationRecord? {
        guard let path = classificationPath,
              let data = FileManager.default.contents(atPath: path) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(ClassificationRecord.self, from: data)
    }

    @discardableResult
    func saveClassification(_ record: ClassificationRecord) -> Bool {
        guard let path = classificationPath else { return false }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(record) else { return false }
        return (try? data.write(to: URL(fileURLWithPath: path), options: .atomic)) != nil
    }

    func deleteClassificationFile() {
        guard let path = classificationPath else { return }
        try? FileManager.default.removeItem(atPath: path)
    }
}
