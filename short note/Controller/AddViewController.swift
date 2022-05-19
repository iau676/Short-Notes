//
//  AddViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//


import UIKit
import CoreData

class AddViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstView: UIView!
    
    @IBOutlet weak var darkView: UIView!
    var tapGesture = UITapGestureRecognizer()
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var engTxtField: UITextView!
    @IBOutlet weak var selectLabelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var sn = ShortNote()
    
    var labelName = ""
    var isOpen = false
    var itemArray = [Item]()
    var onViewWillDisappear: (()->())?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            updateColors()
        }
        
        firstView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        textView.layer.cornerRadius = 12
        addButton.layer.cornerRadius = 6
        engTxtField.layer.cornerRadius = 6
        
        
        checkButton.setBackgroundImage(nil, for: .normal)
        checkButton.setTitle("", for: .normal)
        
        if goEdit == 1 {
            engTxtField.text = UserDefaults.standard.string(forKey: "textEdit")
            labelName = itemArray[editIndex].labelDetect ?? ""
            updateSelectLabelButton(labelName)
        }
        
        if returnLastNote == 1 {
            engTxtField.text = UserDefaults.standard.string(forKey: "lastNote")
            labelName = itemArray[editIndex].lastLabel ?? ""
            updateSelectLabelButton(labelName)
        }
        
        engTxtField.font = UIFont(name: "AvenirNext-Regular", size: CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
        selectLabelButton.titleLabel?.font =  selectLabelButton.titleLabel?.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
        addButton.titleLabel?.font =  addButton.titleLabel?.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        engTxtField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onViewWillDisappear?()
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == engTxtField {
            }else {
                engTxtField.becomeFirstResponder()
            }
                return true
        }
    
    func updateSelectLabelButton(_ labelDetect: String) {
        
        switch labelDetect {
        case "first":
            selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt1"), for: UIControl.State.normal)
            break
        case "second":
            selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt2"), for: UIControl.State.normal)
            break
        case "third":
            selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt3"), for: UIControl.State.normal)
            break
        case "fourth":
            selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt4"), for: UIControl.State.normal)
            break
        case "fifth":
            selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt5"), for: UIControl.State.normal)
            break
        default:
            selectLabelButton.setTitle("Select a Tag", for: UIControl.State.normal)
        }
    }
    
    
    @IBAction func selectLabelPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
        let first = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt1"), style: .default) { (action) in
            // what will happen once user clicks the add item button on UIAlert
            self.selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt1"), for: UIControl.State.normal)
            self.labelName = "first"
        }
        let second = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt2"), style: .default) { (action) in
            self.selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt2"), for: UIControl.State.normal)
            self.labelName = "second"
        }
        let third = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt3"), style: .default) { (action) in
            self.selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt3"), for: UIControl.State.normal)
            self.labelName = "third"
        }
        let fourth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt4"), style: .default) { (action) in
            self.selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt4"), for: UIControl.State.normal)
            self.labelName = "fourth"
        }
        let fifth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt5"), style: .default) { (action) in
            self.selectLabelButton.setTitle(UserDefaults.standard.string(forKey: "segmentAt5"), for: UIControl.State.normal)
            self.labelName = "fifth"

        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }

        if labelName != "first" { alert.addAction(first) }
        if labelName != "second" { alert.addAction(second) }
        if labelName != "third" { alert.addAction(third) }
        if labelName != "fourth" { alert.addAction(fourth) }
        if labelName != "fifth" { alert.addAction(fifth) }
        if labelName != "" {
            let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                // what will happen once user clicks the add item button on UIAlert
                self.selectLabelButton.setTitle("Select a Tag", for: UIControl.State.normal)
                self.labelName = ""
            }
            alert.addAction(removeLabel)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        if engTxtField.text!.count > 0 {
            
            if goEdit == 1 {
                itemArray[editIndex].isEdited = 1
                itemArray[editIndex].lastLabel = itemArray[editIndex].labelDetect
                itemArray[editIndex].lastNote = itemArray[editIndex].note
                itemArray[editIndex].note = engTxtField.text!
                itemArray[editIndex].labelDetect = labelName
            }
            
            if returnLastNote == 1 {
                itemArray[editIndex].lastLabel = itemArray[editIndex].labelDetect
                itemArray[editIndex].lastNote = itemArray[editIndex].note
                itemArray[editIndex].note = engTxtField.text!
                itemArray[editIndex].labelDetect = labelName
            }
            
            if goEdit == 0 && returnLastNote == 0 {
                let newItem = Item(context: self.context)
                newItem.note = engTxtField.text!
                newItem.date = Date()
                newItem.editDate = Date()
                newItem.deleteDate = Date()
                newItem.labelDetect = labelName
                self.itemArray.append(newItem)
               // self.changeSearchBarPlaceholder()
                engTxtField.text = ""
            }

            onViewWillDisappear?()
            
            engTxtField.becomeFirstResponder()
            
            let image = UIImage(named: "checkGreen.png")!
            checkButton.setBackgroundImage(image, for: .normal)
            
            UIView.transition(with: checkButton, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(flipSecond), userInfo: nil, repeats: false)
                   
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSomething), userInfo: nil, repeats: false)
                
            Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(diss), userInfo: nil, repeats: false)
        }
    }
    
    @objc func flipSecond(){
        let image = UIImage(named: "checkGreen.png")!
        checkButton.setBackgroundImage(image, for: .normal)
        
        UIView.transition(with: checkButton, duration: 0.4, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }

    @objc func changeSomething(){
        checkButton.setBackgroundImage(nil, for: .normal)
    }
    
    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }

    
    func updateColors() {
        textView.backgroundColor = sn.dark
        engTxtField.backgroundColor = sn.cellDarkColor
        engTxtField.textColor = sn.cellLightColor
        addButton.backgroundColor = sn.d6d6d6
        addButton.setTitleColor(sn.cellDarkColor, for: UIControl.State.normal)
        selectLabelButton.setTitleColor(sn.cellLightColor, for: UIControl.State.normal)
    }
    

    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }
    
    @IBAction func bottomViewPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    func checkAction(){
        if engTxtField.text!.count > 0 {
            
            if goEdit == 1 {
                                
                // in edit page everyting same
                if itemArray[editIndex].note == engTxtField.text! &&
                    itemArray[editIndex].labelDetect == labelName {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // in edit page something changed so warn user
                    let alert = UIAlertController(title: "Edit page will close", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        // what will happen once user clicks the add item button on UIAlert
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    alert.addAction(actionCancel)
                    present(alert, animated: true, completion: nil)
                }
            } else {
                
                    let alert = (returnLastNote == 0 ? UIAlertController(title: "Add note page will close", message: "", preferredStyle: .alert) : UIAlertController(title: "Previous note page will close", message: "", preferredStyle: .alert))
                    let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    alert.addAction(actionCancel)
                if returnLastNote == 1 &&  itemArray[editIndex].lastNote != engTxtField.text! || returnLastNote == 0 {
                    present(alert, animated: true, completion: nil)
                } else {
                    dismiss(animated: true, completion: nil)
                }
             
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
