import SwiftUI
import UIKit

/// Thin UIKit bridge so SwiftUI can present the standard iOS share sheet.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Drop this into ScanPreviewViewController (single scan, via UIHostingController)
/// or ScansViewController (multi-select export) — same component either way.
struct ExportScansButton: View {
    let scans: [Scan]

    @State private var exportedZipURL: URL?
    @State private var showShareSheet = false
    @State private var exportError: String?

    var body: some View {
        Button {
            export()
        } label: {
            Label(
                "Export \(scans.count) scan\(scans.count == 1 ? "" : "s")",
                systemImage: "square.and.arrow.up"
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let exportedZipURL {
                ShareSheet(items: [exportedZipURL])
            }
        }
        .alert(
            "Export failed",
            isPresented: Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })
        ) {
            Button("OK") { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
    }

    private func export() {
        do {
            let zipURL = try ScanExporter.exportZip(for: scans)
            exportedZipURL = zipURL
            showShareSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}
