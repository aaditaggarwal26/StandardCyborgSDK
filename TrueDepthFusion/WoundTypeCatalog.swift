import Foundation

/// Wound type labels available for clinician review.
/// `modelTypes` are sourced directly from the top-level keys of
/// `prototypes.json` — the classifier can never predict a label outside this
/// set. If you regenerate prototypes.json with different classes, update
/// this list to match.
/// "Other" is appended for clinician use only — it lets a clinician flag a
/// presentation the classifier's 8 classes don't cover.
enum WoundTypeCatalog {
    static let modelTypes: [String] = [
        "Stage I Pressure Ulcer",
        "Stage II Pressure Ulcer",
        "Stage III Pressure Ulcer",
        "Stage IV Pressure Ulcer",
        "Unstageable Pressure Ulcer",
        "Diabetic/Neuropathic Ulcer",
        "Venous Ulcer",
        "Arterial Ulcer"
    ]

    static let knownTypes: [String] = modelTypes + ["Other"]
}
