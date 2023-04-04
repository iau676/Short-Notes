//
//  SettingsViewController.swift
//  short note
//
//  Created by ibrahim uysal on 21.02.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "settingCell"

protocol SettingsControllerDelegate : AnyObject {
    func updateTableView()
}

final class SettingsController: UIViewController {
    
    //MARK: - Properties
    
    private let textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
    private let backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
    
    private lazy var firstTF = makeTextField(backgroundColor: backgroundColor)
    private lazy var secondTF = makeTextField(backgroundColor: backgroundColor)
    private lazy var thirdTF = makeTextField(backgroundColor: backgroundColor)
    private lazy var fourthTF = makeTextField(backgroundColor: backgroundColor)
    private lazy var fifthTF = makeTextField(backgroundColor: backgroundColor)
    
    private lazy var editCancelButton = makeButton(title: "Edit")
    private lazy var defaultApplyButton = makeButton(title: "Default")
    
    private lazy var startLabel = makePaddingLabel(withText: "Start with New Note",
                                                   backgroundColor: backgroundColor, textColor: textColor)
    private let startSwitch = makeSwitch(isOn: true)
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = backgroundColor
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = 50
        tableView.layer.cornerRadius = 8
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    weak var delegate: SettingsControllerDelegate?
    private var sn = ShortNote()
    
    private var segmentIndexForUpdateHour = 0
    private var segmentNumber = 0
    private var goEdit = 0
    private var editIndex = 0
    private var labelName = ""
    private var isOpen = false
    private var buttonState = 0
    
    private var textSize : CGFloat = 0.0
    private var segmentAt1 : String = ""
    private var segmentAt2 : String = ""
    private var segmentAt3 : String = ""
    private var segmentAt4 : String = ""
    private var segmentAt5 : String = ""
    
    private let buttonImageSize: CGFloat = 18
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        assignUserDefaults()
        updateTextSize()
        
        style()
        layout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateTableView()
    }

    //MARK: - Selectors

    @objc private func startNoteChanged(_ sender: UISwitch) {
        print(sender.isOn)
        if sender.isOn {
            UDM.switchNote.set(1)
        } else {
            UDM.switchNote.set(0)
        }
    }
    
    @objc private func leftButtonPressed(_ sender: UIButton) {
        if buttonState == 0 {
            buttonState = 1
            startEditing()
            
            editCancelButton.setTitle("Cancel", for: UIControl.State.normal)
            defaultApplyButton.setTitle("Apply", for: UIControl.State.normal)
            defaultApplyButton.isHidden = false
        } else {
            buttonState = 0
            stopEditing()
            editCancelButton.setTitle("Edit", for: UIControl.State.normal)
            defaultApplyButton.setTitle("Default", for: UIControl.State.normal)
            defaultApplyButton.isHidden = UDM.isDefault.getInt() == 1
            
            firstTF.text = segmentAt1
            secondTF.text = segmentAt2
            thirdTF.text = segmentAt3
            fourthTF.text = segmentAt4
            fifthTF.text = segmentAt5
        }
    }
    
    @objc private func rightButtonPressed(_ sender: UIButton) {
        guard let firstText = firstTF.text else { return }
        guard let secondText = secondTF.text else { return }
        guard let thirdText = thirdTF.text else { return }
        guard let fourthText = fourthTF.text else { return }
        guard let fifthText = fifthTF.text else { return }
        
        if buttonState == 1 {
            if firstText.isEmpty || secondText.isEmpty || thirdText.isEmpty || fourthText.isEmpty || fifthText.isEmpty {
                showAlert(title: "Tag can not be empty.", message: "")
            } else {
                //text is different from before
                if firstText != segmentAt1 || secondText != segmentAt2 || thirdText != segmentAt3 ||
                    fourthText != segmentAt4 ||
                    fifthText != segmentAt5 {
                    
                    let message = "\(firstText)  \(secondText)  \(thirdText)  \(fourthText)  \(fifthText)"
                    showAlertWithCancel(title: "Tags will change like this", message: message) { OK in
                        self.updateEmojies()
                    }
                } else {
                    self.cancelEdit()
                }
            }
        } else {
            showAlertWithCancel(title: "All tags will be default", message: "⭐️  📚  🥰  🌸  🐼") { OK in
                self.returnDefaultEmojies()
            }
        }
    }
        
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)?.darker()
        
        firstTF.text = segmentAt1
        secondTF.text = segmentAt2
        thirdTF.text = segmentAt3
        fourthTF.text = segmentAt4
        fifthTF.text = segmentAt5
        
        editCancelButton.addTarget(self, action: #selector(leftButtonPressed(_:)), for: .touchUpInside)
        defaultApplyButton.addTarget(self, action: #selector(rightButtonPressed(_:)), for: .touchUpInside)
        defaultApplyButton.isHidden = UDM.isDefault.getInt() == 1
        
        startSwitch.isOn = UDM.switchNote.getInt() == 1
        startSwitch.addTarget(self, action: #selector(startNoteChanged), for: .valueChanged)
    }
    
    private func layout() {
        
        let tfStack = UIStackView(arrangedSubviews: [firstTF, secondTF, thirdTF, fourthTF, fifthTF])
        tfStack.axis = .horizontal
        tfStack.distribution = .fillEqually
        tfStack.spacing = 16
        tfStack.setHeight(height: 50)
        
        let editButtonStack = UIStackView(arrangedSubviews: [editCancelButton, defaultApplyButton])
        editButtonStack.axis = .horizontal
        editButtonStack.distribution = .fillEqually
        editButtonStack.spacing = 16
        editButtonStack.setHeight(height: 35)
        
        let emojiStack = UIStackView(arrangedSubviews: [tfStack, editButtonStack])
        emojiStack.axis = .vertical
        emojiStack.spacing = 16
        
        view.addSubview(emojiStack)
        emojiStack.anchor(top: view.topAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 32,
                          paddingLeft: 32, paddingRight: 32)
        emojiStack.addBackground(color: backgroundColor)
        
        view.addSubview(startLabel)
        startLabel.anchor(top: emojiStack.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 8,
                     paddingLeft: 32, paddingRight: 32, height: 50)
        
        view.addSubview(tableView)
        tableView.anchor(top: startLabel.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 8,
                         paddingLeft: 32, paddingRight: 32,
                         height: CGFloat(SettingViewModel.allCases.count)*50)
        
        view.addSubview(startSwitch)
        startSwitch.centerY(inView: startLabel)
        startSwitch.anchor(right: startLabel.rightAnchor, paddingRight: 16)
        
    }
    
    private func makeTextField(backgroundColor: UIColor? = .lightGray) -> UITextField {
        let tf = UITextField()
        tf.backgroundColor = backgroundColor
        tf.textAlignment = .center
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 0.5
        tf.layer.cornerRadius = 4
        tf.layer.borderColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)?.darker()?.cgColor
        tf.isEnabled = false
        tf.delegate = self
        return tf
    }
    
    private func makeButton(title: String, backgroundColor: UIColor? = .darkGray,
                            titleColor: UIColor? = .white) -> UIButton {
        let button = UIButton()
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }
    
    private func returnDefaultEmojies() {
        UDM.segmentAt1.set(sn.defaultEmojies[0])
        UDM.segmentAt2.set(sn.defaultEmojies[1])
        UDM.segmentAt3.set(sn.defaultEmojies[2])
        UDM.segmentAt4.set(sn.defaultEmojies[3])
        UDM.segmentAt5.set(sn.defaultEmojies[4])
        UDM.isDefault.set(1)
        defaultApplyButton.isHidden = true
        assignUserDefaults()
        firstTF.text = segmentAt1
        secondTF.text = segmentAt2
        thirdTF.text = segmentAt3
        fourthTF.text = segmentAt4
        fifthTF.text = segmentAt5
    }
    
    private func updateEmojies() {
        UDM.segmentAt1.set(firstTF.text!)
        UDM.segmentAt2.set(secondTF.text!)
        UDM.segmentAt3.set(thirdTF.text!)
        UDM.segmentAt4.set(fourthTF.text!)
        UDM.segmentAt5.set(fifthTF.text!)

        assignUserDefaults()

        defaultApplyButton.isHidden = false
        stopEditing()

        buttonState = 0
        editCancelButton.setTitle("Edit", for: UIControl.State.normal)
        defaultApplyButton.setTitle("Default", for: UIControl.State.normal)
        UDM.isDefault.set(0)
    }
    
    private func cancelEdit() {
        buttonState = 0
        stopEditing()
        defaultApplyButton.isHidden = true
        editCancelButton.setTitle("Edit", for: UIControl.State.normal)
        defaultApplyButton.setTitle("Default", for: UIControl.State.normal)
        defaultApplyButton.isHidden = UDM.isDefault.getInt() == 1
    }
    
    private func startEditing() {
        firstTF.isEnabled = true
        secondTF.isEnabled = true
        thirdTF.isEnabled = true
        fourthTF.isEnabled = true
        fifthTF.isEnabled = true
        firstTF.becomeFirstResponder()
    }
    
    private func stopEditing() {
        firstTF.isEnabled = false
        secondTF.isEnabled = false
        thirdTF.isEnabled = false
        fourthTF.isEnabled = false
        fifthTF.isEnabled = false
    }
    
    private func assignUserDefaults() {
        textSize = UDM.textSize.getCGFloat()
        segmentAt1 = UDM.segmentAt1.getString()
        segmentAt2 = UDM.segmentAt2.getString()
        segmentAt3 = UDM.segmentAt3.getString()
        segmentAt4 = UDM.segmentAt4.getString()
        segmentAt5 = UDM.segmentAt5.getString()
    }

    private func updateTextSize() {
        textSize = UDM.textSize.getCGFloat()
        
        startLabel.font = UIFont.systemFont(ofSize: textSize)
        
        editCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        defaultApplyButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
    }
}

//MARK: - UITextFieldDelegate

extension SettingsController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstTF: secondTF.becomeFirstResponder()
        case secondTF: thirdTF.becomeFirstResponder()
        case thirdTF: fourthTF.becomeFirstResponder()
        case fourthTF: fifthTF.becomeFirstResponder()
        default: firstTF.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return self.textLimit(existingText: textField.text,
                              newText: string,
                              limit: 1)
    }
    
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
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
