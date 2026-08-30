//
//  InAppSettingsViewController.swift
//  TrueDepthFusion
//
//  An in-app version of the Settings.bundle preferences, so they can be changed
//  without leaving the app. Both write the same UserDefaults keys, so the two stay
//  in sync and the Settings.app page keeps working as before.
//
//  Built in code rather than in Main.storyboard purely to keep the storyboard out
//  of it; nothing here depends on being programmatic.
//

import Foundation
import UIKit

/// The preferences this app exposes, in one place, so the in-app panel and the
/// Settings bundle cannot drift apart.
enum AppSetting {

    static let tapToStartStop = "tap_to_start_stop"
    static let fullResolutionDepthFrames = "full_resolution_depth_frames"
    static let dumpRawFramesToBPLY = "dump_raw_frames_to_bply"
    static let stopScanningOnReconstructionFailure = "stop_scanning_on_reconstruction_failure"
    static let icpMaxIterationCount = "icp_max_iteration_count"
    static let icpTolerance = "icp_tolerance"
    static let pointCloudOverlayOpacity = "pointcloud_overlay_opacity"

    /// Settings-bundle defaults are only registered once the user visits that page,
    /// so an untouched key reads back as absent rather than as its default. Every
    /// read goes through here so a fresh install behaves the same either way.
    static func float(_ key: String, _ fallback: Float) -> Float {
        guard let value = UserDefaults.standard.object(forKey: key) as? NSNumber else { return fallback }

        return value.floatValue
    }

    static func int(_ key: String, _ fallback: Int) -> Int {
        guard let value = UserDefaults.standard.object(forKey: key) as? NSNumber else { return fallback }

        return value.intValue
    }

    static func bool(_ key: String, _ fallback: Bool) -> Bool {
        guard let value = UserDefaults.standard.object(forKey: key) as? NSNumber else { return fallback }

        return value.boolValue
    }
}

extension UIViewController {

    /// Shared by every entry point into the settings panel, so the presentation
    /// style stays consistent and each button is a one-line hookup.
    @objc func presentInAppSettings() {
        let settings = InAppSettingsViewController()
        settings.modalPresentationStyle = .formSheet

        present(settings, animated: true, completion: nil)
    }

    /// The gear used on every screen that offers settings.
    static func inAppSettingsIcon() -> UIImage? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)

        return UIImage(systemName: "gearshape", withConfiguration: configuration)
    }
}

class InAppSettingsViewController: UIViewController {

    // MARK: - UIViewController

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground

        _buildHeader()
        _buildContent()
    }

    // MARK: - Layout

    private let _scrollView = UIScrollView()
    private let _stack = UIStackView()

    private func _buildHeader() {
        let title = UILabel()
        title.text = "Settings"
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false

        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        done.addTarget(self, action: #selector(_donePressed), for: .touchUpInside)
        done.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(title)
        view.addSubview(done)

        _scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(_scrollView)

        _stack.axis = .vertical
        _stack.spacing = 18
        _stack.translatesAutoresizingMaskIntoConstraints = false
        _scrollView.addSubview(_stack)

        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),

            done.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            done.centerYAnchor.constraint(equalTo: title.centerYAnchor),

            _scrollView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            _scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            _scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            _scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            _stack.topAnchor.constraint(equalTo: _scrollView.topAnchor, constant: 8),
            _stack.bottomAnchor.constraint(equalTo: _scrollView.bottomAnchor, constant: -24),
            _stack.leadingAnchor.constraint(equalTo: _scrollView.leadingAnchor, constant: 20),
            _stack.trailingAnchor.constraint(equalTo: _scrollView.trailingAnchor, constant: -20),
            _stack.widthAnchor.constraint(equalTo: _scrollView.widthAnchor, constant: -40),
        ])
    }

    private func _buildContent() {
        _addSectionHeader("Applies immediately")

        _addSlider(key: AppSetting.pointCloudOverlayOpacity,
                   title: "Point cloud overlay opacity",
                   minimum: 0, maximum: 1, fallback: 1.0,
                   format: { String(format: "%.2f", $0) })

        _addSwitch(key: AppSetting.stopScanningOnReconstructionFailure,
                   title: "Stop scanning on reconstruction failure",
                   fallback: true)

        _addSectionHeader("Applies to the next scan")
        _addNote("These are read when the scanning screen opens, so changes take effect the next time you start a scan rather than during one.")

        _addSwitch(key: AppSetting.tapToStartStop,
                   title: "Tap to start/stop",
                   fallback: false)

        _addSwitch(key: AppSetting.fullResolutionDepthFrames,
                   title: "Full resolution depth frames",
                   fallback: false)

        _addSwitch(key: AppSetting.dumpRawFramesToBPLY,
                   title: "Dump raw frames to Binary PLY",
                   fallback: false)

        _addSlider(key: AppSetting.icpMaxIterationCount,
                   title: "ICP max iteration count",
                   minimum: 25, maximum: 125, fallback: 80,
                   isInteger: true,
                   format: { String(format: "%.0f", $0) })

        _addSlider(key: AppSetting.icpTolerance,
                   title: "ICP tolerance",
                   minimum: 0.00001, maximum: 0.0001, fallback: 0.00002,
                   format: { String(format: "%.5f", $0) })
    }

    // MARK: - Rows

    private func _addSectionHeader(_ text: String) {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor.secondaryLabel

        _stack.addArrangedSubview(label)
        _stack.setCustomSpacing(10, after: label)
    }

    private func _addNote(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0

        _stack.addArrangedSubview(label)
    }

    private func _addSwitch(key: String, title: String, fallback: Bool) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0

        let toggle = UISwitch()
        toggle.isOn = AppSetting.bool(key, fallback)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        _switchKeys[toggle] = key
        toggle.addTarget(self, action: #selector(_switchChanged(_:)), for: .valueChanged)

        let row = UIStackView(arrangedSubviews: [label, toggle])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        _stack.addArrangedSubview(row)
    }

    private func _addSlider(key: String,
                            title: String,
                            minimum: Float,
                            maximum: Float,
                            fallback: Float,
                            isInteger: Bool = false,
                            format: @escaping (Float) -> String)
    {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17)

        let value = UILabel()
        value.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        value.textColor = UIColor.secondaryLabel
        value.setContentHuggingPriority(.required, for: .horizontal)

        let slider = UISlider()
        slider.minimumValue = minimum
        slider.maximumValue = maximum
        slider.value = AppSetting.float(key, fallback)
        slider.addTarget(self, action: #selector(_sliderChanged(_:)), for: .valueChanged)

        value.text = format(slider.value)

        _sliderKeys[slider] = key
        _sliderIsInteger[slider] = isInteger
        _sliderValueLabels[slider] = value
        _sliderFormats[slider] = format

        let header = UIStackView(arrangedSubviews: [label, value])
        header.axis = .horizontal
        header.spacing = 12

        let row = UIStackView(arrangedSubviews: [header, slider])
        row.axis = .vertical
        row.spacing = 4

        _stack.addArrangedSubview(row)
    }

    // MARK: - State

    private var _switchKeys: [UISwitch: String] = [:]
    private var _sliderKeys: [UISlider: String] = [:]
    private var _sliderIsInteger: [UISlider: Bool] = [:]
    private var _sliderValueLabels: [UISlider: UILabel] = [:]
    private var _sliderFormats: [UISlider: (Float) -> String] = [:]

    // MARK: - Actions

    @objc private func _switchChanged(_ sender: UISwitch) {
        guard let key = _switchKeys[sender] else { return }

        UserDefaults.standard.set(sender.isOn, forKey: key)
    }

    @objc private func _sliderChanged(_ sender: UISlider) {
        guard let key = _sliderKeys[sender] else { return }

        if _sliderIsInteger[sender] == true {
            let rounded = sender.value.rounded()
            sender.value = rounded
            UserDefaults.standard.set(Int(rounded), forKey: key)
        } else {
            UserDefaults.standard.set(sender.value, forKey: key)
        }

        if let label = _sliderValueLabels[sender], let format = _sliderFormats[sender] {
            label.text = format(sender.value)
        }
    }

    @objc private func _donePressed() {
        dismiss(animated: true, completion: nil)
    }
}
