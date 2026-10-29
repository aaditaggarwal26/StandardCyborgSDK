import SwiftUI

/// Presented after a classification run (or from a scan's detail view) so a
/// clinician can review the model's prediction, see the measurements already
/// tapped out on this scan, override the wound type, and leave notes.
///
/// Reads/writes directly through the Scan sidecar files
/// (classificationPath / measurementsPath) — there's no separate app-wide
/// store. State lives next to the scan's .ply file, same as everything else
/// in TrueDepthFusion.
struct ScanReviewView: View {
    let scan: Scan
    /// Current in-memory state from an active ScanPreviewViewController session,
    /// for a scan not yet written to disk (no plyPath, so nothing in the
    /// sidecars yet). When nil, falls back to whatever is already on disk --
    /// the normal case when reviewing a previously-saved scan.
    var liveClassification: ClassificationRecord? = nil
    var liveMeasurements: [WoundMeasurement]? = nil

    @State private var classification: ClassificationRecord?
    @State private var measurements: [WoundMeasurement] = []

    @State private var woundType: String = WoundTypeCatalog.knownTypes[0]
    @State private var notes: String = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                clinicianReviewSection
                measurementsSection
            }
            .navigationTitle("Review Scan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveReview() }
                }
            }
            .onAppear(perform: loadExistingState)
        }
    }

    private var clinicianReviewSection: some View {
        Section("Clinician review") {
            Picker("Final wound type", selection: $woundType) {
                ForEach(WoundTypeCatalog.knownTypes, id: \.self) { Text($0) }
            }
            TextEditor(text: $notes)
                .frame(minHeight: 100)
        }
    }

    @ViewBuilder
    private var measurementsSection: some View {
        Section("Measurements (\(measurements.count))") {
            if measurements.isEmpty {
                Text("No measurements taken yet. Use Measure (Beta) on the scan to tap two points.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(measurements.enumerated()), id: \.offset) { _, measurement in
                    HStack {
                        Text(String(format: "%.1f cm", measurement.distanceCentimeters))
                        Spacer()
                        Text(measurement.dateCreated, style: .time)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deleteMeasurements)
            }
        }
    }

    private func loadExistingState() {
        measurements = liveMeasurements ?? scan.loadMeasurements()
        if let existing = liveClassification ?? scan.loadClassification() {
            classification = existing
            woundType = existing.clinicianWoundType ?? existing.topModelPrediction?.label ?? WoundTypeCatalog.knownTypes[0]
            notes = existing.clinicianNotes ?? ""
        }
    }

    private func deleteMeasurements(at offsets: IndexSet) {
        measurements.remove(atOffsets: offsets)
        scan.saveMeasurements(measurements)
    }

    private func saveReview() {
        // If classification hasn't run yet, still let the clinician record a
        // manual wound type + notes rather than blocking on a model run.
        var record = classification ?? ClassificationRecord(modelPredictions: [])
        record.clinicianWoundType = woundType
        record.clinicianNotes = notes.isEmpty ? nil : notes
        record.reviewedAt = Date()
        scan.saveClassification(record)
        dismiss()
    }
}
