//
//  SettingsViewController.swift
//  short note
//
//  Created by ibrahim uysal on 21.02.2022.
//
import UIKit
import CoreData

protocol SettingsControllerDelegate : AnyObject {
    func updateTableView()
}

class SettingsController: UIViewController {
    
    //MARK: - Properties
    
    private let textColor = Colors.cellDark
    private let backgroundColor = Colors.cellLight
    
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
    
    private lazy var hiddenButton = makeButton(title: "Hidden",
                                               backgroundColor: backgroundColor,
                                               titleColor: textColor)
    
    private lazy var recentlyDeletedButton = makeButton(title: "Recently Deleted",
                                                        backgroundColor: backgroundColor,
                                                        titleColor: textColor)
    
    private lazy var noteSettingsButton = makeButton(title: "Note Settings",
                                                     backgroundColor: backgroundColor,
                                                     titleColor: textColor)
    
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
            UDM.setValue(1, UDM.switchNote)
        } else {
            UDM.setValue(0, UDM.switchNote)
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
            defaultApplyButton.isHidden = UDM.getIntValue(UDM.isDefault) == 1
            
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
    
    @objc private func hiddenButtonPressed() {
        let controller = HiddenController()
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
    
    @objc private func recentlyDeletedButtonPressed() {
        let controller = RecentlyDeletedController()
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
    
    @objc private func noteSettingsButtonPressed() {
        let controller = NoteSettingsController()
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
        
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = .white
        
        firstTF.text = segmentAt1
        secondTF.text = segmentAt2
        thirdTF.text = segmentAt3
        fourthTF.text = segmentAt4
        fifthTF.text = segmentAt5
        
        editCancelButton.addTarget(self, action: #selector(leftButtonPressed(_:)), for: .touchUpInside)
        defaultApplyButton.addTarget(self, action: #selector(rightButtonPressed(_:)), for: .touchUpInside)
        defaultApplyButton.isHidden = UDM.getIntValue(UDM.isDefault) == 1
        
        startSwitch.isOn = UDM.getIntValue(UDM.switchNote) == 1
        startSwitch.addTarget(self, action: #selector(startNoteChanged), for: .valueChanged)
        
        hiddenButton.setImage(image: Images.hideBlack, width: buttonImageSize, height: buttonImageSize)
        recentlyDeletedButton.setImage(image: Images.thrashBlack, width: buttonImageSize, height: buttonImageSize)
        noteSettingsButton.setImage(image: Images.settingsBlack, width: buttonImageSize, height: buttonImageSize)
        
        hiddenButton.addTarget(self, action: #selector(hiddenButtonPressed), for: .touchUpInside)
        recentlyDeletedButton.addTarget(self, action: #selector(recentlyDeletedButtonPressed), for: .touchUpInside)
        noteSettingsButton.addTarget(self, action: #selector(noteSettingsButtonPressed), for: .touchUpInside)
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
        
        
        startLabel.setHeight(height: 50)
        hiddenButton.setHeight(height: 50)
        recentlyDeletedButton.setHeight(height: 50)
        noteSettingsButton.setHeight(height: 50)
        let stack = UIStackView(arrangedSubviews: [startLabel, hiddenButton,
                                                   recentlyDeletedButton, noteSettingsButton])
        stack.axis = .vertical
        stack.spacing = 8
        
        view.addSubview(stack)
        stack.anchor(top: emojiStack.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 8,
                     paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(startSwitch)
        startSwitch.centerY(inView: startLabel)
        startSwitch.anchor(right: startLabel.rightAnchor, paddingRight: 16)
        
        hiddenButton.moveImageLeftTextCenter()
        recentlyDeletedButton.moveImageLeftTextCenter()
        noteSettingsButton.moveImageLeftTextCenter()
    }
    
    private func makeTextField(backgroundColor: UIColor? = .lightGray) -> UITextField {
        let tf = UITextField()
        tf.backgroundColor = backgroundColor
        tf.textAlignment = .center
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 0.5
        tf.layer.cornerRadius = 4
        tf.layer.borderColor = Colors.d6d6d6?.cgColor
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
        button.layer.cornerRadius = 4
        return button
    }
    
    private func returnDefaultEmojies() {
        UDM.setValue(sn.defaultEmojies[0], UDM.segmentAt1)
        UDM.setValue(sn.defaultEmojies[1], UDM.segmentAt2)
        UDM.setValue(sn.defaultEmojies[2], UDM.segmentAt3)
        UDM.setValue(sn.defaultEmojies[3], UDM.segmentAt4)
        UDM.setValue(sn.defaultEmojies[4], UDM.segmentAt5)
        UDM.setValue(1, UDM.isDefault)
        defaultApplyButton.isHidden = true
        assignUserDefaults()
        firstTF.text = segmentAt1
        secondTF.text = segmentAt2
        thirdTF.text = segmentAt3
        fourthTF.text = segmentAt4
        fifthTF.text = segmentAt5
    }
    
    private func updateEmojies() {
        UDM.setValue(firstTF.text!, UDM.segmentAt1)
        UDM.setValue(secondTF.text!, UDM.segmentAt2)
        UDM.setValue(thirdTF.text!, UDM.segmentAt3)
        UDM.setValue(fourthTF.text!, UDM.segmentAt4)
        UDM.setValue(fifthTF.text!, UDM.segmentAt5)

        assignUserDefaults()

        defaultApplyButton.isHidden = false
        stopEditing()

        buttonState = 0
        editCancelButton.setTitle("Edit", for: UIControl.State.normal)
        defaultApplyButton.setTitle("Default", for: UIControl.State.normal)
        UDM.setValue(0, UDM.isDefault)
    }
    
    private func cancelEdit() {
        buttonState = 0
        stopEditing()
        defaultApplyButton.isHidden = true
        editCancelButton.setTitle("Edit", for: UIControl.State.normal)
        defaultApplyButton.setTitle("Default", for: UIControl.State.normal)
        defaultApplyButton.isHidden = UDM.getIntValue(UDM.isDefault) == 1
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
    
    private func assignUserDefaults(){
        textSize = UDM.getCGFloatValue(UDM.textSize)
        segmentAt1 = UDM.getStringValue(UDM.segmentAt1)
        segmentAt2 = UDM.getStringValue(UDM.segmentAt2)
        segmentAt3 = UDM.getStringValue(UDM.segmentAt3)
        segmentAt4 = UDM.getStringValue(UDM.segmentAt4)
        segmentAt5 = UDM.getStringValue(UDM.segmentAt5)
    }

    private func updateTextSize() {
        textSize = UDM.getCGFloatValue(UDM.textSize)
        
        startLabel.font = UIFont.systemFont(ofSize: textSize)
        
        editCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        defaultApplyButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        
        hiddenButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        recentlyDeletedButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        noteSettingsButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
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
