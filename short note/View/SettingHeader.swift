//
//  SettingHeader.swift
//  short note
//
//  Created by ibrahim uysal on 5.04.2023.
//

import UIKit

protocol SettingHeaderDelegate: AnyObject {
    func showAlertMessage(title: String, message: String)
    func showAlertMessageWithCancel(title: String, message: String, completion: @escaping(Bool)-> Void)
}

final class SettingHeader: UIView {

    private var sn = ShortNote()
    weak var delegate: SettingHeaderDelegate?
    
    private let bColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
    private let textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
    
    private lazy var firstTF = makeTextField(backgroundColor: bColor, textColor: textColor)
    private lazy var secondTF = makeTextField(backgroundColor: bColor, textColor: textColor)
    private lazy var thirdTF = makeTextField(backgroundColor: bColor, textColor: textColor)
    private lazy var fourthTF = makeTextField(backgroundColor: bColor, textColor: textColor)
    private lazy var fifthTF = makeTextField(backgroundColor: bColor, textColor: textColor)
    
    private lazy var editCancelButton: UIButton = {
        let button = makeButton(title: "Edit")
        button.addTarget(self, action: #selector(leftButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var defaultApplyButton: UIButton = {
        let button =  makeButton(title: "Default")
        button.addTarget(self, action: #selector(rightButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = UDM.isDefault.getInt() == 1
        return button
    }()

    private var isEditMode = false
    private var segmentAt1 : String = ""
    private var segmentAt2 : String = ""
    private var segmentAt3 : String = ""
    private var segmentAt4 : String = ""
    private var segmentAt5 : String = ""
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
 
    
    @objc private func leftButtonPressed(_ sender: UIButton) {
        if isEditMode {
            stopEditing()
            editCancelButton.setTitle("Edit", for: .normal)
            defaultApplyButton.setTitle("Default", for: .normal)
            defaultApplyButton.isHidden = UDM.isDefault.getInt() == 1
            
            firstTF.text = segmentAt1
            secondTF.text = segmentAt2
            thirdTF.text = segmentAt3
            fourthTF.text = segmentAt4
            fifthTF.text = segmentAt5
        } else {
            startEditing()
            editCancelButton.setTitle("Cancel", for: .normal)
            defaultApplyButton.setTitle("Apply", for: .normal)
            defaultApplyButton.isHidden = false
        }
        isEditMode.toggle()
    }
    
    @objc private func rightButtonPressed(_ sender: UIButton) {
            guard let firstText = firstTF.text else { return }
            guard let secondText = secondTF.text else { return }
            guard let thirdText = thirdTF.text else { return }
            guard let fourthText = fourthTF.text else { return }
            guard let fifthText = fifthTF.text else { return }
            
            if isEditMode {
                if firstText.isEmpty || secondText.isEmpty || thirdText.isEmpty || fourthText.isEmpty || fifthText.isEmpty {
                    delegate?.showAlertMessage(title: "Tag can not be empty", message: "")
                } else {
                    //text is different from before
                    if firstText != segmentAt1 || secondText != segmentAt2 || thirdText != segmentAt3 ||
                        fourthText != segmentAt4 ||
                        fifthText != segmentAt5 {
                        
                        let message = "\(firstText)  \(secondText)  \(thirdText)  \(fourthText)  \(fifthText)"
                        delegate?.showAlertMessageWithCancel(title: "Tags will change like this",
                                                             message: message,
                                                             completion: { OK in
                            self.updateEmojies()
                        })
                        
                    } else {
                        self.cancelEdit()
                    }
                }
            } else {
                delegate?.showAlertMessageWithCancel(title: "All tags will be default",
                                                     message: sn.defaultEmojies.joined(separator: " "),
                                                     completion: { OK in
                    self.returnDefaultEmojies()
                })
            }
        }
    //MARK: - Helpers
    
    func configureUI() {
        backgroundColor = bColor
        layer.cornerRadius = 8
        
        assignUserDefaults()
        
        firstTF.text = segmentAt1
        secondTF.text = segmentAt2
        thirdTF.text = segmentAt3
        fourthTF.text = segmentAt4
        fifthTF.text = segmentAt5
        
        let tfStack = UIStackView(arrangedSubviews: [firstTF, secondTF, thirdTF, fourthTF, fifthTF])
        tfStack.axis = .horizontal
        tfStack.distribution = .fillEqually
        tfStack.spacing = 8
        tfStack.setHeight(height: 50)
        
        let editButtonStack = UIStackView(arrangedSubviews: [editCancelButton, defaultApplyButton])
        editButtonStack.axis = .horizontal
        editButtonStack.distribution = .fillEqually
        editButtonStack.spacing = 8
        editButtonStack.setHeight(height: 30)
        
        let stack = UIStackView(arrangedSubviews: [tfStack, editButtonStack])
        stack.axis = .vertical
        stack.spacing = 8
        
        addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: leftAnchor, right: rightAnchor)
        stack.addBackground(color: bColor)
        
        setHeight(height: 50+30+40)
    }
    
    private func assignUserDefaults() {
        segmentAt1 = UDM.segmentAt1.getString()
        segmentAt2 = UDM.segmentAt2.getString()
        segmentAt3 = UDM.segmentAt3.getString()
        segmentAt4 = UDM.segmentAt4.getString()
        segmentAt5 = UDM.segmentAt5.getString()
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
    
    private func cancelEdit() {
        isEditMode.toggle()
        stopEditing()
        defaultApplyButton.isHidden = true
        editCancelButton.setTitle("Edit", for: .normal)
        defaultApplyButton.setTitle("Default", for: .normal)
        defaultApplyButton.isHidden = UDM.isDefault.getInt() == 1
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

        isEditMode.toggle()
        editCancelButton.setTitle("Edit", for: .normal)
        defaultApplyButton.setTitle("Default", for: .normal)
        UDM.isDefault.set(0)
    }
    
    private func makeTextField(backgroundColor: UIColor? = .lightGray, textColor: UIColor? = .black) -> UITextField {
        let tf = UITextField()
        tf.backgroundColor = backgroundColor
        tf.textColor = textColor
        tf.textAlignment = .center
        tf.layer.cornerRadius = 4
        tf.layer.borderWidth = 0.5
        tf.layer.cornerRadius = 4
        tf.layer.borderColor = backgroundColor?.darker()?.cgColor
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
        button.titleLabel?.font = UIFont(name: Fonts.AvenirNextRegular, size: UDM.textSize.getCGFloat())
        return button
    }
    
}

//MARK: - UITextFieldDelegate

extension SettingHeader: UITextFieldDelegate {
    
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
