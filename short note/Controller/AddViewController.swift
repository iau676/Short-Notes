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
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var noteTxtField: UITextView!
    @IBOutlet weak var selectLabelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    var sn = ShortNote()
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    
    var labelName = ""
    var isOpen = false
    var onViewWillDisappear: (()->())?
    
    override func viewDidLoad() {
        
        sn.loadItems()
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 { updateColors() }
        
        firstView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        textView.layer.cornerRadius = 12
        addButton.layer.cornerRadius = 6
        noteTxtField.layer.cornerRadius = 6
        
        checkButton.setBackgroundImage(nil, for: .normal)
        checkButton.setTitle("", for: .normal)
        
        if goEdit == 1 {
            noteTxtField.text = UserDefaults.standard.string(forKey: "textEdit")
            labelName = sn.itemArray[editIndex].labelDetect ?? ""
            updateSelectLabelButton(labelName)
        }
        
        if returnLastNote == 1 {
            noteTxtField.text = UserDefaults.standard.string(forKey: "lastNote")
            labelName = sn.itemArray[editIndex].lastLabel ?? ""
            updateSelectLabelButton(labelName)
        }
        
        noteTxtField.font = UIFont(name: "AvenirNext-Regular", size: CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
        selectLabelButton.titleLabel?.font =  selectLabelButton.titleLabel?.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
        addButton.titleLabel?.font =  addButton.titleLabel?.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
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
        
        let first = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt1"), style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt1")
            self.labelName = "first"
        }
        let second = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt2"), style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt2")
            self.labelName = "second"
        }
        let third = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt3"), style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt3")
            self.labelName = "third"
        }
        let fourth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt4"), style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt4")
            self.labelName = "fourth"
        }
        let fifth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt5"), style: .default) { (action) in
            self.setButtonTitle(self.selectLabelButton, "segmentAt5")
            self.labelName = "fifth"

        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }

        if labelName != "first" { alert.addAction(first) }
        if labelName != "second" { alert.addAction(second) }
        if labelName != "third" { alert.addAction(third) }
        if labelName != "fourth" { alert.addAction(fourth) }
        if labelName != "fifth" { alert.addAction(fifth) }
        if labelName != "" {
            let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                self.selectLabelButton.setTitle("Select a Tag", for: UIControl.State.normal)
                self.labelName = ""
            }
            alert.addAction(removeLabel)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        if noteTxtField.text!.count > 0 {
            
            let item = sn.itemArray[editIndex]
            
            if goEdit == 1 {
                item.isEdited = 1
                item.lastLabel = item.labelDetect
                item.lastNote = item.note
                item.note = noteTxtField.text!
                item.labelDetect = labelName
            }
            
            if returnLastNote == 1 {
                item.lastLabel = item.labelDetect
                item.lastNote = item.note
                item.note = noteTxtField.text!
                item.labelDetect = labelName
            }
            
            if goEdit == 0 && returnLastNote == 0 {
                sn.appendItem(noteTxtField.text!, labelName)
                noteTxtField.text = ""
            }

            onViewWillDisappear?()
            
            noteTxtField.becomeFirstResponder()
            
            let image = UIImage(named: "checkGreen.png")!
            checkButton.setBackgroundImage(image, for: .normal)
            
            UIView.transition(with: checkButton, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(flipSecond), userInfo: nil, repeats: false)
                   
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSomething), userInfo: nil, repeats: false)
                
            Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(diss), userInfo: nil, repeats: false)
        }
    }
    

    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Objc Functions
    
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
    
    //MARK: - Other Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == noteTxtField {
            } else {
                noteTxtField.becomeFirstResponder()
            }
            return true
    }
    
    func setButtonTitle(_ button: UIButton, _ key: String){
        button.setTitle(UserDefaults.standard.string(forKey: key), for: UIControl.State.normal)
    }
    
    func updateSelectLabelButton(_ labelDetect: String) {
        
        switch labelDetect {
        case "first":
            setButtonTitle(selectLabelButton, "segmentAt1")
            break
        case "second":
            setButtonTitle(selectLabelButton, "segmentAt2")
            break
        case "third":
            setButtonTitle(selectLabelButton, "segmentAt3")
            break
        case "fourth":
            setButtonTitle(selectLabelButton, "segmentAt4")
            break
        case "fifth":
            setButtonTitle(selectLabelButton, "segmentAt5")
            break
        default:
            selectLabelButton.setTitle("Select a Tag", for: UIControl.State.normal)
        }
    }

    
    func updateColors() {
        textView.backgroundColor = UIColor(named: "colorTextDark")
        noteTxtField.backgroundColor = UIColor(named: "colorCellDark")
        noteTxtField.textColor = UIColor(named: "colorCellLight")
        addButton.backgroundColor = UIColor(named: "colord6d6d6")
        addButton.setTitleColor(UIColor(named: "colorCellDark"), for: UIControl.State.normal)
        selectLabelButton.setTitleColor(UIColor(named: "colorCellLight"), for: UIControl.State.normal)
    }
    
    func checkAction(){
        if noteTxtField.text!.count > 0 {
            
            if goEdit == 1 {
                                
                // in edit page everyting same
                if sn.itemArray[editIndex].note == noteTxtField.text! &&
                    sn.itemArray[editIndex].labelDetect == labelName {
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
                if returnLastNote == 1 &&  sn.itemArray[editIndex].lastNote != noteTxtField.text! || returnLastNote == 0 {
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
