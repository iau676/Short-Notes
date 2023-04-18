//
//  SettingsViewController.swift
//  short note
//
//  Created by ibrahim uysal on 21.02.2022.
//
import UIKit

private let reuseIdentifier = "settingCell"

protocol SettingsControllerDelegate : AnyObject {
    func updateTableView()
}

final class SettingsController: UIViewController {
    
    //MARK: - Properties
    
    private var sn = ShortNote()
    weak var delegate: SettingsControllerDelegate?
    
    private let textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
    private let backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
    
    private let settingHeader = SettingHeader()
    private var startLabel = UILabel()
    private let startSwitch = UISwitch()
    private let tableView = UITableView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        style()
        layout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateTableView()
    }

    //MARK: - Selectors

    @objc private func startNoteChanged(_ sender: UISwitch) {
        if sender.isOn {
            UDM.switchNote.set(1)
        } else {
            UDM.switchNote.set(0)
        }
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)?.darker()
        settingHeader.delegate = self
        
        startLabel = makePaddingLabel(withText: "Start with New Note",
                                      backgroundColor: backgroundColor, textColor: textColor)
        
        startSwitch.isOn = UDM.switchNote.getInt() == 1
        startSwitch.addTarget(self, action: #selector(startNoteChanged), for: .valueChanged)
        
        tableView.backgroundColor = backgroundColor
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = 50
        tableView.layer.cornerRadius = 8
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func layout() {
        view.addSubview(settingHeader)
        settingHeader.centerX(inView: view)
        settingHeader.setHeight(height: 150)
        settingHeader.anchor(top: view.topAnchor, left: view.leftAnchor,
                             right: view.rightAnchor, paddingTop: 32,
                             paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(startLabel)
        startLabel.anchor(top: settingHeader.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 8,
                     paddingLeft: 32, paddingRight: 32, height: 50)
        
        view.addSubview(startSwitch)
        startSwitch.centerY(inView: startLabel)
        startSwitch.anchor(right: startLabel.rightAnchor, paddingRight: 16)
        
        view.addSubview(tableView)
        tableView.anchor(top: startLabel.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 8,
                         paddingLeft: 32, paddingRight: 32,
                         height: CGFloat(SettingViewModel.allCases.count)*50)
    }
}

//MARK: - UITableViewDataSource

extension SettingsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingViewModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        let viewModel = SettingViewModel(rawValue: indexPath.row)
        cell.viewModel = viewModel
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

//MARK: - UITableViewDelegate

extension SettingsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = SettingViewModel(rawValue: indexPath.row) else { return }
        
        switch viewModel {
        case .tags:
            presentController(controller: TagsController())
        case .themes:
            let controller = ThemesController()
            controller.delegate = self
            presentController(controller: controller)
        case .hidden:
            presentController(controller: HiddenController())
        case .createPDF:
            presentController(controller: PDFContoller())
        case .noteSettings:
            presentController(controller: NoteSettingsController())
        case .recentlyDeleted:
            presentController(controller: RecentlyDeletedController())
        }
    }
    
    private func presentController(controller: UIViewController) {
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
}

//MARK: - ThemesControllerDelegate

extension SettingsController: ThemesControllerDelegate {
    func updateTheme() {
        self.dismiss(animated: true)
    }
}

//MARK: - SettingHeaderDelegate

extension SettingsController: SettingHeaderDelegate {
    
    func showAlertMessage(title: String, message: String) {
        showAlert(title: title, message: message)
    }
    
    func showAlertMessageWithCancel(title: String, message: String, completion: @escaping (Bool) -> Void) {
        showAlertWithCancel(title: title, message: message, completion: completion)
    }
}
