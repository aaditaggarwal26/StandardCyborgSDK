//
//  InitialViewController.swift
//  TrueDepthFusion
//
//  Created by Aaron Thompson on 11/7/18.
//  Copyright © 2018 Standard Cyborg. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var introLabel: UILabel!
    
    override func viewDidLoad() {
        // Text is now set in storyboard
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }

        _installSettingsButton()
    }

    @IBAction private func scan(_ sender: UIButton?) {
        let scanToBPLY = UserDefaults.standard.bool(forKey: "dump_raw_frames_to_bply", defaultValue: false)
        let segueIdentifier = scanToBPLY ? "BPLYScanningViewController" : "ScanningViewController"
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }

    // MARK: - Settings

    /// Added in code so Main.storyboard does not have to change.
    ///
    /// The panel lives here rather than on the scanning screen because most of these
    /// are read when that screen loads: the capture session resolution and the ICP
    /// parameters are both fixed by then, so editing them mid-scan would look like it
    /// did nothing. Overlay opacity is the exception, and also has a live control on
    /// the scanning screen itself.
    private func _installSettingsButton() {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(_settingsPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
        ])
    }

    @objc private func _settingsPressed() {
        let settings = InAppSettingsViewController()
        settings.modalPresentationStyle = .formSheet

        present(settings, animated: true, completion: nil)
    }

}

extension UserDefaults {
    
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if let defaultNumber = object(forKey: key) as? NSNumber {
            return defaultNumber.boolValue
        } else {
            return defaultValue
        }
    }
    
}
