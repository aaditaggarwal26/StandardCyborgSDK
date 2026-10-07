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
import simd

class ScanPreviewViewController: UIViewController, QLPreviewControllerDataSource, SCNSceneRendererDelegate {

    // MARK: - IB Outlets and Actions

    @IBOutlet private weak var sceneView: SCNView!
    @IBOutlet private weak var meshButton: UIButton!
    @IBOutlet private weak var meshingProgressContainer: UIView!
    @IBOutlet private weak var meshingProgressView: UIProgressView!
    private var _quickLookOBJURL: URL?

    @IBAction private func _export(_ sender: AnyObject) {
        if let scan = scan {
            // Export the point cloud directly
            let shareURL = scan.writeCompressedPLY()

            _quickLookOBJURL = shareURL

            // Show share sheet for exporting
            let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                if completed {
                    let alert = UIAlertController(
                        title: "Scan Exported",
                        message: "Your scan has been exported successfully.\n\n• All scans are automatically saved to 'RHL Scans' folder in Files app\n• You can also access them via iTunes/Finder file sharing\n• Share via AirDrop, email, or save to iCloud Drive",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }

            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            self.present(activityVC, animated: true, completion: nil)
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
        // Classification UI is set up first so the measurement buttons can anchor
        // horizontally to the classify button — both now live on the left, leaving
        // the top-right corner clear for the Share button.
        _setupClassificationUI()
        _setupMeasurementUI()
        _setupMeasurementGesture()
        _setupReviewButton()

        // Drives _updatePointSize(forZoom:) every rendered frame so the dots can grow
        // as the user pinch-zooms in.
        sceneView.delegate = self
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
            _cachedPositions = []
            _pendingFirstPoint = nil
            _completedMeasurements = scan?.loadMeasurements() ?? []
            _redrawAllMeasurements()
            _updateSummaryLabel()

            if let pointCloud = scan?.pointCloud {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let positions = pointCloud.extractPositions()
                    DispatchQueue.main.async {
                        self?._cachedPositions = positions
                        self?._updateSummaryLabel()
                    }
                }
            }
        }
    }

    var deletionHandler: (() -> Void)?
    var doneHandler: (() -> Void)?

    /// Call this right after the scan has been written to disk for the first time
    /// (i.e. right after AppDelegate.add(_:) succeeds). Measurements taken before that
    /// point have no plyPath to save alongside yet, so they're held in memory until now.
    func flushMeasurementsToDiskIfNeeded() {
        _persistMeasurements()
    }

    // MARK: - Private

    private let _appDelegate = UIApplication.shared.delegate! as! AppDelegate
    private var _initialPointOfView = SCNMatrix4Identity
    private var _pointCloudNode: SCNNode? {
        willSet {
            _pointCloudNode?.removeFromParentNode()
        }
        didSet {
            _pointCloudNode?.name = "point cloud"

            // Hold onto the point geometry element (and its default sizing) so we can
            // enlarge the dots as the user zooms in. See the "Zoom-adaptive point size"
            // section. The default values captured here are what "regular zoom" uses.
            _pointElement = _pointCloudNode?.geometry?.elements.first(where: { $0.primitiveType == .point })
                ?? _pointCloudNode?.geometry?.elements.first
            if let element = _pointElement {
                _basePointSize = element.pointSize
                _baseMaxPointRadius = element.maximumPointScreenSpaceRadius
            }
            _referenceZoomMetric = nil

            // No display flip here any more. The reconstruction now mirrors the depth
            // and color input at the source, so the point cloud already matches what
            // was on screen during the scan. Scaling by -1 as well would mirror it
            // back and put this screen out of step with both the scan and the PLY.

            // Make sure the view is loaded first
            _ = self.view

            if let node = _pointCloudNode {
                sceneView.scene!.rootNode.addChildNode(node)
            }
        }
    }

    // MARK: - Measurement (Beta)

    private var _measureButton: UIButton?
    private var _measurementLabel: UILabel?
    private var _resetMeasurementButton: UIButton?

    private var _cachedPositions: [SIMD3<Float>] = []
    private var _measurementModeEnabled = false
    private var _pendingFirstPoint: SIMD3<Float>?
    private var _completedMeasurements: [WoundMeasurement] = []
    private var _pendingClassification: ClassificationRecord?
    private var _measurementNodes: [SCNNode] = []

    private func _setupMeasurementUI() {
        let button = UIButton(type: .system)
        button.setTitle("📏 Measure (Beta)", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(_toggleMeasurementMode), for: .touchUpInside)
        view.addSubview(button)

        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(_resetMeasurement), for: .touchUpInside)
        resetButton.isHidden = true
        view.addSubview(resetButton)

        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        // _classifyButton is guaranteed non-nil here because _setupClassificationUI()
        // runs before _setupMeasurementUI() (see viewDidLoad).
        NSLayoutConstraint.activate([
            // Sit the Measure button just to the right of the Classify button so both
            // live on the left, keeping the top-right corner clear for the Share button.
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: _classifyButton!.trailingAnchor, constant: 8),

            // Reset sits to the right of Measure (only visible in measurement mode).
            resetButton.topAnchor.constraint(equalTo: button.topAnchor),
            resetButton.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8),

            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 220)
        ])

        _measureButton = button
        _measurementLabel = label
        _resetMeasurementButton = resetButton
    }

    private func _setupMeasurementGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(_handleMeasurementTap(_:)))
        sceneView.addGestureRecognizer(tap)
    }

    @objc private func _toggleMeasurementMode() {
        _measurementModeEnabled.toggle()
        _measureButton?.setTitle(_measurementModeEnabled ? "Done" : "📏 Measure (Beta)", for: .normal)
        _measurementLabel?.isHidden = !_measurementModeEnabled
        _resetMeasurementButton?.isHidden = !_measurementModeEnabled
        _updateSummaryLabel()
    }

    @objc private func _handleMeasurementTap(_ gesture: UITapGestureRecognizer) {
        guard _measurementModeEnabled else { return }
        guard !_cachedPositions.isEmpty else {
            _measurementLabel?.text = "Still preparing scan data…"
            return
        }
        guard let pointCloudNode = _pointCloudNode else { return }

        let tapPoint = gesture.location(in: sceneView)
        guard let nearest = _nearestPointCloudPosition(toScreenPoint: tapPoint, pointCloudNode: pointCloudNode) else {
            _measurementLabel?.text = "No point found — try tapping closer to the scan"
            return
        }

        if let first = _pendingFirstPoint {
            let measurement = WoundMeasurement(pointA: first, pointB: nearest)
            _completedMeasurements.append(measurement)
            _pendingFirstPoint = nil
            _persistMeasurements()
            _redrawAllMeasurements()
            _updateSummaryLabel()
        } else {
            _pendingFirstPoint = nearest
            _redrawAllMeasurements()
            _updateSummaryLabel()
        }
    }

    /// Finds the point cloud vertex whose projected screen position is closest to the tap,
    /// within a reasonable pixel radius. Point clouds don't have surfaces, so a standard
    /// SceneKit hit test won't reliably work — we search the raw vertex positions instead.
    private func _nearestPointCloudPosition(toScreenPoint screenPoint: CGPoint, pointCloudNode: SCNNode) -> SIMD3<Float>? {
        var closestPosition: SIMD3<Float>?
        var closestDistanceSquared: CGFloat = .greatestFiniteMagnitude
        let maxScreenDistance: CGFloat = 40 // points; ignore taps too far from any vertex

        for localPosition in _cachedPositions {
            let localVector = SCNVector3(localPosition.x, localPosition.y, localPosition.z)
            let worldVector = pointCloudNode.convertPosition(localVector, to: nil)
            let projected = sceneView.projectPoint(worldVector)

            // projected.z is normalized depth within the view frustum (0...1); outside that
            // range means the point is behind the camera or beyond the clipping planes.
            guard projected.z > 0, projected.z < 1 else { continue }

            let dx = CGFloat(projected.x) - screenPoint.x
            let dy = CGFloat(projected.y) - screenPoint.y
            let distSq = dx * dx + dy * dy

            guard distSq <= maxScreenDistance * maxScreenDistance else { continue }

            if distSq < closestDistanceSquared {
                closestDistanceSquared = distSq
                closestPosition = localPosition
            }
        }

        return closestPosition
    }

    /// Clears and redraws every marker/line currently visible, based on
    /// _completedMeasurements plus any single pending (unpaired) tap.
    private func _redrawAllMeasurements() {
        guard let node = _pointCloudNode else { return }

        _measurementNodes.forEach { $0.removeFromParentNode() }
        _measurementNodes.removeAll()

        for measurement in _completedMeasurements {
            let a = measurement.pointAVector
            let b = measurement.pointBVector

            _measurementNodes.append(_makeMarkerNode(at: a, in: node))
            _measurementNodes.append(_makeMarkerNode(at: b, in: node))
            _measurementNodes.append(_makeLineNode(from: a, to: b, in: node))
        }

        if let pending = _pendingFirstPoint {
            _measurementNodes.append(_makeMarkerNode(at: pending, in: node))
        }
    }

    private func _makeMarkerNode(at localPosition: SIMD3<Float>, in node: SCNNode) -> SCNNode {
        let sphere = SCNSphere(radius: 0.0035)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemYellow
        sphere.firstMaterial?.lightingModel = .constant

        let markerNode = SCNNode(geometry: sphere)
        markerNode.position = SCNVector3(localPosition.x, localPosition.y, localPosition.z)
        node.addChildNode(markerNode)
        return markerNode
    }

    private func _makeLineNode(from a: SIMD3<Float>, to b: SIMD3<Float>, in node: SCNNode) -> SCNNode {
        let vertices: [SCNVector3] = [
            SCNVector3(a.x, a.y, a.z),
            SCNVector3(b.x, b.y, b.z)
        ]
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [0, 1]
        let indexData = indices.withUnsafeBufferPointer { Data(buffer: $0) }
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .line,
            primitiveCount: 1,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = UIColor.systemYellow
        geometry.firstMaterial?.lightingModel = .constant

        let lineNode = SCNNode(geometry: geometry)
        node.addChildNode(lineNode)
        return lineNode
    }

    /// The running tally shown in the top-right corner: one line per saved measurement,
    /// referencing point numbers in tap order (no in-scene text needed).
    private func _updateSummaryLabel() {
        guard _measurementModeEnabled else { return }

        var lines: [String] = []

        if _completedMeasurements.isEmpty && _pendingFirstPoint == nil {
            lines.append(_cachedPositions.isEmpty ? "Preparing scan data…" : "Tap two points to measure")
        } else {
            for (index, measurement) in _completedMeasurements.enumerated() {
                let pointA = index * 2 + 1
                let pointB = index * 2 + 2
                lines.append(String(format: "%d–%d:  %.1f cm", pointA, pointB, measurement.distanceCentimeters))
            }
            if _pendingFirstPoint != nil {
                let nextNumber = _completedMeasurements.count * 2 + 1
                lines.append("Point \(nextNumber) placed — tap a second point")
            }
        }

        _measurementLabel?.text = lines.joined(separator: "\n")
    }

    /// Saves _completedMeasurements to disk if the scan has been written already
    /// (has a plyPath). If not, this is a no-op — flushMeasurementsToDiskIfNeeded()
    /// handles the case where measurements were taken before the first save.
    private func _persistMeasurements() {
        guard let scan = scan, scan.plyPath != nil else { return }
        scan.saveMeasurements(_completedMeasurements)
    }

    @objc private func _resetMeasurement() {
        _pendingFirstPoint = nil
        _completedMeasurements.removeAll()
        _persistMeasurements()
        _redrawAllMeasurements()
        _updateSummaryLabel()
    }

    // MARK: - Wound Classification (Beta)

    private var _classifyButton: UIButton?
    private var _woundClassifier: WoundClassifier?
    private var _classifierLoadError: String?
    private var _reviewButton: UIButton?

    private func _setupClassificationUI() {
        let button = UIButton(type: .system)
        button.setTitle("🔬 Classify (Beta)", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(_classifyTapped), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        _classifyButton = button

        // Load the model once, up front, so a load failure surfaces immediately
        // rather than on first tap.
        do {
            _woundClassifier = try WoundClassifier()
        } catch {
            _classifierLoadError = error.localizedDescription
            button.setTitle("🔬 Classify (unavailable)", for: .normal)
        }
    }
    private func _setupReviewButton() {
        let button = UIButton(type: .system)
        button.setTitle("📋 Review", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(_reviewTapped), for: .touchUpInside)
        view.addSubview(button)

        // Second row, left-aligned under Classify -- the first row (Classify,
        // Measure, Reset) already fills the left side of the safe area.
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: _classifyButton!.bottomAnchor, constant: 12),
            button.leadingAnchor.constraint(equalTo: _classifyButton!.leadingAnchor)
        ])

        _reviewButton = button
    }

    @objc private func _reviewTapped() {
        guard let scan = scan else { return }
        let review = ScanReviewView(
            scan: scan,
            liveClassification: _pendingClassification,
            liveMeasurements: _completedMeasurements
        )
        let host = UIHostingController(rootView: review)
        present(host, animated: true)
    }

    @objc private func _classifyTapped() {
        if let loadError = _classifierLoadError {
            _presentClassificationAlert(title: "Classifier Unavailable", message: loadError)
            return
        }

        guard let classifier = _woundClassifier else { return }
        guard let image = scan?.thumbnail else {
            _presentClassificationAlert(title: "No Image Available", message: "This scan doesn't have a thumbnail to classify yet.")
            return
        }

        _classifyButton?.isEnabled = false
        _classifyButton?.setTitle("Classifying…", for: .normal)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let predictions = try classifier.classify(image)
                DispatchQueue.main.async {
                    self?._handleClassificationResult(.success(predictions))
                }
            } catch {
                DispatchQueue.main.async {
                    self?._handleClassificationResult(.failure(error))
                }
            }
        }
    }

    private func _handleClassificationResult(_ result: Result<[WoundClassifier.Prediction], Error>) {
        _classifyButton?.isEnabled = true
        _classifyButton?.setTitle("🔬 Classify (Beta)", for: .normal)

        switch result {
        case .failure(let error):
            _presentClassificationAlert(title: "Classification Failed", message: error.localizedDescription)

        case .success(let predictions):
            let top3 = predictions.prefix(3)
            let lines = top3.enumerated().map { index, prediction in
                String(format: "%d. %@ — distance %.2f", index + 1, prediction.label, prediction.distance)
            }
            let message = lines.joined(separator: "\n")
                + "\n\nLower distance = closer match. This is a research prototype, not a diagnostic tool."
            _presentClassificationAlert(title: "Wound Classification (Beta)", message: message)

            // Held in memory first, same pattern as _completedMeasurements --
            // the scan may not have a plyPath yet (not written to disk until
            // "Done" is tapped), so _persistClassification() below is a no-op
            // until then, same as _persistMeasurements().
            let record = ClassificationRecord(
                modelPredictions: predictions.map {
                    ClassificationRecord.ModelPrediction(label: $0.label, distance: $0.distance)
                }
            )
            _pendingClassification = record
            _persistClassification()
        }
    }

    /// Saves _pendingClassification to disk if the scan has been written already
    /// (has a plyPath). If not, this is a no-op -- flushClassificationToDiskIfNeeded()
    /// handles the case where classification ran before the first save.
    private func _persistClassification() {
        guard let scan = scan, scan.plyPath != nil, let record = _pendingClassification else { return }
        scan.saveClassification(record)
    }

    /// Call this right after the scan has been written to disk for the first time
    /// (i.e. right after AppDelegate.add(_:) succeeds), alongside
    /// flushMeasurementsToDiskIfNeeded(). Classification run before that point has
    /// no plyPath to save alongside yet, so it's held in memory until now.
    func flushClassificationToDiskIfNeeded() {
        _persistClassification()
    }

    private func _presentClassificationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Zoom-adaptive point size

    // SceneKit draws each point clamped to maximumPointScreenSpaceRadius on screen, so
    // zooming in spreads the points apart without enlarging them and the cloud looks
    // sparse. We scale the point size up with the zoom level, anchored so that at the
    // default (regular) zoom the values are exactly what buildNode() set — only zooming
    // in past that baseline makes the dots grow.

    private var _pointElement: SCNGeometryElement?
    private var _basePointSize: CGFloat = 4
    private var _baseMaxPointRadius: CGFloat = 5
    private var _referenceZoomMetric: CGFloat?
    /// Upper bound on the on-screen dot radius so extreme zoom doesn't produce huge blobs.
    private let _maxPointRadiusCap: CGFloat = 40

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let element = _pointElement,
              let metric = _currentZoomMetric(using: renderer) else { return }

        // The first frame at the default camera position establishes the "regular zoom"
        // baseline; from there a larger metric means the user has zoomed in.
        guard let reference = _referenceZoomMetric else {
            _referenceZoomMetric = metric
            return
        }

        // Clamped to >= 1 so regular zoom and zooming back out stay at the original size.
        let zoomFactor = max(1.0, metric / reference)
        let newPointSize = _basePointSize * zoomFactor
        let newMaxRadius = min(_baseMaxPointRadius * zoomFactor, _maxPointRadiusCap)

        // Only write when something actually changed, to avoid churning every frame.
        if abs(element.pointSize - newPointSize) > 0.05 {
            element.pointSize = newPointSize
        }
        if abs(element.maximumPointScreenSpaceRadius - newMaxRadius) > 0.05 {
            element.maximumPointScreenSpaceRadius = newMaxRadius
        }
    }

    /// A scalar proportional to how large the scan appears on screen, from the camera's
    /// distance and field of view (both enlarge the apparent size when zooming in).
    /// Returns nil if the camera or point cloud isn't ready yet.
    private func _currentZoomMetric(using renderer: SCNSceneRenderer) -> CGFloat? {
        guard let pov = renderer.pointOfView,
              let camera = pov.camera,
              let cloud = _pointCloudNode else { return nil }

        let cameraPosition = pov.presentation.simdWorldPosition
        let target = cloud.presentation.simdWorldPosition
        let distance = simd_distance(cameraPosition, target)
        guard distance > 1e-5 else { return nil }

        let halfFOVRadians = Float(camera.fieldOfView) * .pi / 180 / 2
        let tangent = tan(halfFOVRadians)
        guard tangent > 1e-5 else { return nil }

        // Apparent size is proportional to 1 / (distance · tan(halfFOV)).
        return CGFloat(1 / (distance * tangent))
    }
}
