//
//  TrashViewController.swift
//  TrueDepthFusion
//
//  Deleted scans, kept until they are emptied out. Deleting from View Scans moves
//  the files into a Trash subfolder rather than removing them, so this screen is
//  just a listing of that folder with the two actions that get a scan out of it.
//
//  Built in code rather than in Main.storyboard so the scan list's prototype cell
//  and segues are left alone; the rows here are plain subtitle cells.
//

import Foundation
import UIKit

class TrashViewController: UITableViewController {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Trash"

        tableView.register(TrashedScanCell.self, forCellReuseIdentifier: _cellIdentifier)
        tableView.rowHeight = 88

        _emptyItem = UIBarButtonItem(title: "Empty",
                                     style: .plain,
                                     target: self,
                                     action: #selector(_emptyPressed))
        _emptyItem?.tintColor = UIColor.systemRed
        navigationItem.rightBarButtonItem = _emptyItem

        tableView.backgroundView = _emptyLabel
        _emptyLabel.text = "Trash is Empty"
        _emptyLabel.textAlignment = .center
        _emptyLabel.textColor = UIColor.gray
        _emptyLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        _reload()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _scans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scan = _scans[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellIdentifier, for: indexPath)

        cell.textLabel?.text = TrashViewController._dateFormatter.string(from: scan.dateCreated)
        cell.detailTextLabel?.text = TrashViewController._timeFormatter.string(from: scan.dateCreated)
        cell.detailTextLabel?.textColor = UIColor.gray

        // The classic cell image view sizes itself to the image, so the thumbnail is
        // scaled down rather than constrained. `contentConfiguration` would do this
        // for us but is iOS 14, and this project deploys to 13.
        cell.imageView?.image = scan.thumbnail?.resized(toWidth: 64)

        cell.selectionStyle = .none

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, completion in
            self._confirmPermanentDelete(at: indexPath)
            completion(true)
        }

        let restore = UIContextualAction(style: .normal, title: "Restore") { [unowned self] _, _, completion in
            self._restore(at: indexPath)
            completion(true)
        }
        restore.backgroundColor = UIColor.systemBlue

        return UISwipeActionsConfiguration(actions: [delete, restore])
    }

    // MARK: - Private

    private static let _dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let _timeFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private let _cellIdentifier = "TrashedScanCell"
    private let _appDelegate = UIApplication.shared.delegate! as! AppDelegate
    private let _emptyLabel = UILabel()
    private var _emptyItem: UIBarButtonItem?
    private var _scans: [Scan] = []

    private func _reload() {
        _scans = _appDelegate.trashedScans()

        _emptyLabel.isHidden = _scans.count > 0
        _emptyItem?.isEnabled = _scans.count > 0

        tableView.reloadData()
    }

    private func _restore(at indexPath: IndexPath) {
        _appDelegate.restoreFromTrash(_scans[indexPath.row])

        _scans.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        _emptyLabel.isHidden = _scans.count > 0
        _emptyItem?.isEnabled = _scans.count > 0
    }

    /// Both destructive paths ask first. Everything here has already been deleted
    /// once, so this is the point where the files actually stop existing.
    private func _confirmPermanentDelete(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Scan?",
                                      message: "This permanently deletes the scan and cannot be undone.",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self._appDelegate.deletePermanently(self._scans[indexPath.row])

            self._scans.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

            self._emptyLabel.isHidden = self._scans.count > 0
            self._emptyItem?.isEnabled = self._scans.count > 0
        })

        present(alert, animated: true)
    }

    @objc private func _emptyPressed() {
        let count = _scans.count
        let alert = UIAlertController(title: "Empty Trash?",
                                      message: "This permanently deletes \(count) scan\(count == 1 ? "" : "s") and cannot be undone.",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Empty Trash", style: .destructive) { [unowned self] _ in
            self._appDelegate.emptyTrash()
            self._reload()
        })

        present(alert, animated: true)
    }
}

/// Exists only to force the subtitle style, which a cell registered by class cannot
/// otherwise get — `register(_:forCellReuseIdentifier:)` always builds it with
/// `.default`, and `.default` has no `detailTextLabel` to put the time in.
private class TrashedScanCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
