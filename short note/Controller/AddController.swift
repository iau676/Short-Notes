//
//  AddController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//

import UIKit
import CoreData

protocol AddControllerDelegate: AnyObject {
    func handleNewNote()
}

final class AddController: UIViewController {
    
    //MARK: - Properties
    
    private let centerView = UIView()
    private let noteTextView = UITextView()
    private let selectTagButton = UIButton()
    private let saveButton = UIButton()
    private let checkButton = UIButton()
    
    weak var delegate: AddControllerDelegate?
    private var sn = ShortNote()
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    
    private var tag = ""
    private var isOpen = false
    private var textSize: CGFloat = 0.0
    private var segmentAt1: String = ""
    private var segmentAt2: String = ""
    private var segmentAt3: String = ""
    private var segmentAt4: String = ""
    private var segmentAt5: String = ""
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        assignUserDefaults()
        style()
        layout()
        sn.loadItems()
        configureUI()
        configureGradient()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noteTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.handleNewNote()
    }

    //MARK: - Selectors
    
    @objc private func selectTagButtonPressed() {
        let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)

        let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
            self.setButtonTitle(self.selectTagButton, "segmentAt1")
            self.tag = self.segmentAt1
        }
        let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
            self.setButtonTitle(self.selectTagButton, "segmentAt2")
            self.tag = self.segmentAt2
        }
        let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
            self.setButtonTitle(self.selectTagButton, "segmentAt3")
            self.tag = self.segmentAt3
        }
        let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
            self.setButtonTitle(self.selectTagButton, "segmentAt4")
            self.tag = self.segmentAt4
        }
        let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
            self.setButtonTitle(self.selectTagButton, "segmentAt5")
            self.tag = self.segmentAt5
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }

        if tag != self.segmentAt1 { alert.addAction(first) }
        if tag != self.segmentAt2 { alert.addAction(second) }
        if tag != self.segmentAt3 { alert.addAction(third) }
        if tag != self.segmentAt4 { alert.addAction(fourth) }
        if tag != self.segmentAt5 { alert.addAction(fifth) }
        if tag != "" {
            let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                self.selectTagButton.setTitle("Select a Tag", for: .normal)
                self.tag = ""
            }
            alert.addAction(removeLabel)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func saveButtonPressed() {
        if noteTextView.text!.count > 0 {
            if goEdit == 1 {
                let item = sn.itemArray[editIndex]
                item.isEdited = 1
                item.lastLabel = item.label
                item.lastNote = item.note
                item.note = noteTextView.text!
                item.label = tag
            }

            if returnLastNote == 1 {
                let item = sn.itemArray[editIndex]
                item.lastLabel = item.label
                item.lastNote = item.note
                item.note = noteTextView.text!
                item.label = tag
            }

            if goEdit == 0 && returnLastNote == 0 {
                sn.appendItem(noteTextView.text!, tag)
                noteTextView.text = ""
            }

            delegate?.handleNewNote()

            scheduledTimer(timeInterval: 0.0, #selector(flipCheckButton))
            scheduledTimer(timeInterval: 0.3, #selector(flipCheckButtonSecond))
            scheduledTimer(timeInterval: 0.6, #selector(dismissView))
        }
    }
    
    @objc private func flipCheckButton() {
        checkButton.setBackgroundImage(Images.checkGreen, for: .normal)
        UIView.transition(with: checkButton, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    @objc private func flipCheckButtonSecond() {
        UIView.transition(with: checkButton, duration: 0.4, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    @objc private func dismissView() {
        view.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        
        centerView.layer.cornerRadius = 10
        centerView.backgroundColor = UIColor(hex:  ThemeManager.shared.currentTheme.backgroundColor)
        
        noteTextView.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        noteTextView.textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        noteTextView.layer.cornerRadius = 6
        noteTextView.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        
        selectTagButton.backgroundColor = .clear
        selectTagButton.setTitle("Select a Tag", for: .normal)
        selectTagButton.setTitleColor(.darkGray, for: .normal)
        selectTagButton.titleLabel?.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        selectTagButton.addTarget(self, action: #selector(selectTagButtonPressed), for: .touchUpInside)
        
        saveButton.backgroundColor = .darkGray
        saveButton.layer.cornerRadius = 6
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
        checkButton.setBackgroundImage(nil, for: .normal)
    }
    
    private func layout() {
        view.addSubview(centerView)
        centerView.setHeight(height: 266)
        centerView.centerY(inView: view, constant: -30)
        centerView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                          paddingLeft: 32, paddingRight: 32)
        
        centerView.addSubview(noteTextView)
        noteTextView.setHeight(height: 140)
        noteTextView.anchor(top: centerView.topAnchor, left: centerView.leftAnchor,
                            right: centerView.rightAnchor, paddingTop: 16,
                            paddingLeft: 16, paddingRight: 16)
        
        centerView.addSubview(selectTagButton)
        selectTagButton.setHeight(height: 40)
        selectTagButton.anchor(top: noteTextView.bottomAnchor, left: centerView.leftAnchor,
                               right: centerView.rightAnchor, paddingTop: 8,
                               paddingLeft: 16, paddingRight: 16)
        
        centerView.addSubview(saveButton)
        saveButton.setHeight(height: 40)
        saveButton.anchor(top: selectTagButton.bottomAnchor, left: centerView.leftAnchor,
                          right: centerView.rightAnchor, paddingTop: 8,
                          paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(checkButton)
        checkButton.setDimensions(height: 90, width: 90)
        checkButton.centerX(inView: view)
        checkButton.anchor(bottom: centerView.topAnchor, paddingBottom: 16)
    }
    
    private func configureUI() {
        if goEdit == 1 {
            noteTextView.text = UDM.textEdit.getString()
            tag = sn.itemArray[editIndex].label ?? ""
            updateSelectLabelButton(tag)
        }
        
        if returnLastNote == 1 {
            noteTextView.text = UDM.lastNote.getString()
            tag = sn.itemArray[editIndex].lastLabel ?? ""
            updateSelectLabelButton(tag)
        }
    }
    
    private func configureGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex:  ThemeManager.shared.currentTheme.backgroundColor)!.cgColor,
                                UIColor(hex:  ThemeManager.shared.currentTheme.backgroundColorBottom)!.cgColor]
        gradientLayer.cornerRadius = 10
        gradientLayer.frame = CGRect(x: view.center.x-view.bounds.width/2,
                                     y: view.center.y-view.bounds.height/2,
                                     width: view.bounds.width-64,
                                     height: 266)

        centerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func assignUserDefaults() {
        textSize = UDM.textSize.getCGFloat()
        segmentAt1 = UDM.segmentAt1.getString()
        segmentAt2 = UDM.segmentAt2.getString()
        segmentAt3 = UDM.segmentAt3.getString()
        segmentAt4 = UDM.segmentAt4.getString()
        segmentAt5 = UDM.segmentAt5.getString()
    }
    
    private func setButtonTitle(_ button: UIButton, _ key: String) {
        button.setTitle(UserDefaults.standard.string(forKey: key), for: .normal)
    }
    
    private func updateSelectLabelButton(_ tag: String) {
        switch tag {
        case segmentAt1: setButtonTitle(selectTagButton, "segmentAt1")
        case segmentAt2: setButtonTitle(selectTagButton, "segmentAt2")
        case segmentAt3: setButtonTitle(selectTagButton, "segmentAt3")
        case segmentAt4: setButtonTitle(selectTagButton, "segmentAt4")
        case segmentAt5: setButtonTitle(selectTagButton, "segmentAt5")
        default: selectTagButton.setTitle("Select a Tag", for: .normal)
        }
    }
    
    private func checkAction(){
        if noteTextView.text!.count > 0 {
            if goEdit == 1 {
                //everyting same
                if sn.itemArray[editIndex].note == noteTextView.text! &&
                    sn.itemArray[editIndex].label == tag {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    presentNotSavedAlert()
                }
            } else {
                if returnLastNote == 1 &&  sn.itemArray[editIndex].lastNote != noteTextView.text! || returnLastNote == 0 {
                    presentNotSavedAlert()
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func scheduledTimer(timeInterval: Double, _ selector : Selector) {
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: selector, userInfo: nil, repeats: false)
    }
    
    private func presentNotSavedAlert() {
        let alert = UIAlertController(title: "Your changes could not be saved", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension AddController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == noteTextView {
        } else {
            noteTextView.becomeFirstResponder()
        }
        return true
    }
}

//MARK: - Swipe Gesture

extension AddController {
    private func addGestureRecognizer() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeDownGesture))
        swipeDown.direction = .down
        
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func respondToSwipeDownGesture(gesture: UISwipeGestureRecognizer) {
        checkAction()
    }
}
