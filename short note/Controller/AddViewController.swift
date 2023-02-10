//
//  AddViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet var firstView: UIView!
    @IBOutlet weak var darkView: UIView!
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var noteTxtField: UITextView!
    @IBOutlet weak var selectLabelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    //MARK: - Variables
    
    var sn = ShortNote()
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var tag = ""
    var isOpen = false
    
    var onViewWillDisappear: (()->())?
    
    //MARK: - UserDefaults
    
    var textSize: CGFloat = 0.0
    var segmentAt1: String = ""
    var segmentAt2: String = ""
    var segmentAt3: String = ""
    var segmentAt4: String = ""
    var segmentAt5: String = ""
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        assignUserDefaults()
        
        sn.loadItems()
        
        if UDM.getIntValue(UDM.darkMode) == 1 { updateColors() }
        
        firstView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        textView.layer.cornerRadius = 12
        addButton.layer.cornerRadius = 6
        noteTxtField.layer.cornerRadius = 6
        
        checkButton.setBackgroundImage(nil, for: .normal)
        checkButton.setTitle("", for: .normal)
        
        if goEdit == 1 {
            noteTxtField.text = UDM.getStringValue(UDM.textEdit)
            tag = sn.itemArray[editIndex].label ?? ""
            updateSelectLabelButton(tag)
        }
        
        if returnLastNote == 1 {
            noteTxtField.text = UDM.getStringValue(UDM.lastNote)
            tag = sn.itemArray[editIndex].lastLabel ?? ""
            updateSelectLabelButton(tag)
        }
        
        noteTxtField.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        selectLabelButton.titleLabel?.font =  selectLabelButton.titleLabel?.font.withSize(textSize)
        addButton.titleLabel?.font =  addButton.titleLabel?.font.withSize(textSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noteTxtField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onViewWillDisappear?()
    }
    
    //MARK: - IBAction
    
    @IBAction func selectLabelPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
        
        let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt1")
            self.tag = self.segmentAt1
        }
        let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt2")
            self.tag = self.segmentAt2
        }
        let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt3")
            self.tag = self.segmentAt3
        }
        let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt4")
            self.tag = self.segmentAt4
        }
        let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt5")
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
                self.selectLabelButton.setTitle("Select a Tag", for: .normal)
                self.tag = ""
            }
            alert.addAction(removeLabel)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if noteTxtField.text!.count > 0 {
            if goEdit == 1 {
                let item = sn.itemArray[editIndex]
                item.isEdited = 1
                item.lastLabel = item.label
                item.lastNote = item.note
                item.note = noteTxtField.text!
                item.label = tag
            }
            
            if returnLastNote == 1 {
                let item = sn.itemArray[editIndex]
                item.lastLabel = item.label
                item.lastNote = item.note
                item.note = noteTxtField.text!
                item.label = tag
            }
            
            if goEdit == 0 && returnLastNote == 0 {
                sn.appendItem(noteTxtField.text!, tag)
                noteTxtField.text = ""
            }

            onViewWillDisappear?()
            
            noteTxtField.becomeFirstResponder()
            
            scheduledTimer(timeInterval: 0.0, #selector(flipCheckButton))
            scheduledTimer(timeInterval: 0.3, #selector(flipCheckButtonSecond))
            scheduledTimer(timeInterval: 0.6, #selector(dismissView))
        }
    }

    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Selectors
    
    @objc func flipCheckButton() {
        checkButton.setBackgroundImage(Images.checkGreen, for: .normal)
        UIView.transition(with: checkButton, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    @objc func flipCheckButtonSecond() {
        UIView.transition(with: checkButton, duration: 0.4, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    @objc func dismissView() {
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    func assignUserDefaults(){
        textSize = UDM.getCGFloatValue(UDM.textSize)
        segmentAt1 = UDM.getStringValue(UDM.segmentAt1)
        segmentAt2 = UDM.getStringValue(UDM.segmentAt2)
        segmentAt3 = UDM.getStringValue(UDM.segmentAt3)
        segmentAt4 = UDM.getStringValue(UDM.segmentAt4)
        segmentAt5 = UDM.getStringValue(UDM.segmentAt5)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == noteTxtField {
        } else {
            noteTxtField.becomeFirstResponder()
        }
        return true
    }
    
    func setButtonTitle(_ button: UIButton, _ key: String) {
        button.setTitle(UserDefaults.standard.string(forKey: key), for: .normal)
    }
    
    func updateSelectLabelButton(_ tag: String) {
        switch tag {
        case segmentAt1:
            setButtonTitle(selectLabelButton, "segmentAt1")
            break
        case segmentAt2:
            setButtonTitle(selectLabelButton, "segmentAt2")
            break
        case segmentAt3:
            setButtonTitle(selectLabelButton, "segmentAt3")
            break
        case segmentAt4:
            setButtonTitle(selectLabelButton, "segmentAt4")
            break
        case segmentAt5:
            setButtonTitle(selectLabelButton, "segmentAt5")
            break
        default:
            selectLabelButton.setTitle("Select a Tag", for: .normal)
        }
    }
    
    func updateColors() {
        textView.backgroundColor = Colors.cellDark
        noteTxtField.backgroundColor = Colors.textDark
        noteTxtField.textColor = Colors.cellLight
        addButton.backgroundColor = Colors.d6d6d6
        addButton.setTitleColor(Colors.cellDark, for: .normal)
        selectLabelButton.setTitleColor(Colors.cellLight, for: .normal)
    }
    
    func checkAction(){
        if noteTxtField.text!.count > 0 {
            if goEdit == 1 {
                //everyting same
                if sn.itemArray[editIndex].note == noteTxtField.text! &&
                    sn.itemArray[editIndex].label == tag {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    presentNotSavedAlert()
                }
            } else {
                if returnLastNote == 1 &&  sn.itemArray[editIndex].lastNote != noteTxtField.text! || returnLastNote == 0 {
                    presentNotSavedAlert()
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func scheduledTimer(timeInterval: Double, _ selector : Selector) {
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
