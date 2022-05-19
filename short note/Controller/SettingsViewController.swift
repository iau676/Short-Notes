//
//  SettingsViewController.swift
//  short note
//
//  Created by ibrahim uysal on 21.02.2022.
//
import UIKit
import CoreData

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstView: UIView!
    
    @IBOutlet weak var darkView: UIView!
    var tapGesture = UITapGestureRecognizer()
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var invisibleView: UIView!
    
    @IBOutlet weak var labelAskWhenDelete: UILabel!
    @IBOutlet weak var labelStartWithNewNote: UILabel!
    @IBOutlet weak var labelDarkMode: UILabel!
    @IBOutlet weak var labelInvisible: UILabel!
    @IBOutlet weak var otherSettingsButton: UIButton!
    
    @IBOutlet weak var HiddenButton: UIButton!
    @IBOutlet weak var recentlyDeletedButton: UIButton!
    
    @IBOutlet weak var switchDelete: UISwitch!
    @IBOutlet weak var switchNote: UISwitch!
    @IBOutlet weak var switchDarkMode: UISwitch!
    @IBOutlet weak var switchInvisible: UISwitch!

    var segmentIndexForUpdateHour = 0
    var segmentNumber = 0
    var goEdit = 0
    var editIndex = 0
    var labelName = ""
    var isOpen = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var sn = ShortNote()
    
    @IBOutlet weak var firstTextField: UITextField! 
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var fifthTextField: UITextField!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var leftButtonState = 0
    var rightButtonState = 0
    var buttonState = 0
    
    var onViewWillDisappear: (()->())?
    
    override func viewDidLoad() {
        
        setupView()
        
        leftButtonState = 0
        rightButtonState = 0
        buttonState = 0
        
        updateColor()
        updateTextSize()

        HiddenButton.moveImageLeftTextCenter()
        otherSettingsButton.moveImageLeftTextCenter()
        recentlyDeletedButton.moveImageLeftTextCenter()
    }

    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onViewWillDisappear?()
        }
    
    func setupView(){
        firstView.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        invisibleView.isHidden=true
        
        textView.layer.cornerRadius = 12
        deleteView.layer.cornerRadius = 8
        noteView.layer.cornerRadius = 8
        labelView.layer.cornerRadius = 8
        invisibleView.layer.cornerRadius = 8
        leftButton.layer.cornerRadius = 4
        rightButton.layer.cornerRadius = 4
        otherSettingsButton.layer.cornerRadius = 8
        HiddenButton.layer.cornerRadius = 8
        recentlyDeletedButton.layer.cornerRadius = 8
  
        darkModeView.layer.cornerRadius = 8

        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchDelete") == 1 {
            switchDelete.isOn = false
        } else {
            switchDelete.isOn = true
        }
        
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchNote") == 1 {
            switchNote.isOn = false
        } else {
            switchNote.isOn = true
        }

        // 1 is true, 0 is false
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            switchDarkMode.isOn = true
        } else {
            switchDarkMode.isOn = false
        }
        
        // 1 is true, 0 is false
        if UserDefaults.standard.integer(forKey: "invisible") == 1 {
            switchInvisible.isOn = true
        } else {
            switchInvisible.isOn = false
        }
        
        firstTextField.delegate = self
        secondTextField.delegate = self
        thirdTextField.delegate = self
        fourthTextField.delegate = self
        fifthTextField.delegate = self
        
        firstTextField.isEnabled = false
        secondTextField.isEnabled = false
        thirdTextField.isEnabled = false
        fourthTextField.isEnabled = false
        fifthTextField.isEnabled = false
        
        if UserDefaults.standard.integer(forKey: "isDefault") == 1 {
            rightButton.isHidden = true
        } else {
            rightButton.isHidden = false
        }
   
        firstTextField.text = UserDefaults.standard.string(forKey: "segmentAt1")
        secondTextField.text = UserDefaults.standard.string(forKey: "segmentAt2")
        thirdTextField.text = UserDefaults.standard.string(forKey: "segmentAt3")
        fourthTextField.text = UserDefaults.standard.string(forKey: "segmentAt4")
        fifthTextField.text = UserDefaults.standard.string(forKey: "segmentAt5")

        leftButton.setTitle("Edit", for: UIControl.State.normal)
        rightButton.setTitle("Default", for: UIControl.State.normal)
    }//setupView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "goHidden" {
            if segue.destination is HiddenViewController {
                (segue.destination as? HiddenViewController)?.onViewWillDisappear = {
                        self.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        if segue.identifier == "goOther" {
            if segue.destination is OtherSettingsViewController {
                (segue.destination as? OtherSettingsViewController)?.onViewWillDisappear = {
                    self.updateTextSize()
                    self.onViewWillDisappear?()
                }
            }
        }
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


    @IBAction func switchDeletePressed(_ sender: UISwitch) {
        print(sender.isOn)
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "switchDelete")
        } else {
            UserDefaults.standard.set(1, forKey: "switchDelete")
        }
    }
    
    @IBAction func swicthNotePressed(_ sender: UISwitch) {
        print(sender.isOn)
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "switchNote")
        } else {
            UserDefaults.standard.set(1, forKey: "switchNote")
        }
    }

    @IBAction func switchDarkModePressed(_ sender: UISwitch) {
        // when user switch to dark mode bgcolor will be dark, when switch again bgcolor will be color that before dark mode
        if sender.isOn {
            UserDefaults.standard.set(5, forKey: "bgColor")
            UserDefaults.standard.set(1, forKey: "darkMode")
        } else {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "lastBgColor"), forKey: "bgColor")
            UserDefaults.standard.set(0, forKey: "darkMode")
        }
        updateColor()
        onViewWillDisappear?()
    }
    
    @IBAction func switchInvisiblePressed(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(1, forKey: "invisible")
        } else {
            UserDefaults.standard.set(0, forKey: "invisible")
        }
        onViewWillDisappear?()
    }
    
    //Icons text and image should update same time
    func updateIcons() {
        //let textSize = UserDefaults.standard.integer(forKey: "textSize")
        let buttonImageSize = 18
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            HiddenButton.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
                UIImage(named: "hide")?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
            
            recentlyDeletedButton.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
                UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
            
            otherSettingsButton.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
                UIImage(named: "settings")?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
        } else {
            HiddenButton.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
                UIImage(named: "hideBlack")?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
            
            recentlyDeletedButton.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
                UIImage(named: "thrashBlack")?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
            
            otherSettingsButton.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
                UIImage(named: "settingsBlack")?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
        }
    }
    
    func updateColor() {
        
        updateIcons()
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            textView.backgroundColor = sn.dark
            deleteView.backgroundColor = sn.cellDarkColor
            noteView.backgroundColor = sn.cellDarkColor
            labelView.backgroundColor = sn.cellDarkColor
            darkModeView.backgroundColor = sn.cellDarkColor
            invisibleView.backgroundColor = sn.cellDarkColor

            labelAskWhenDelete.textColor = sn.cellLightColor
            labelStartWithNewNote.textColor = sn.cellLightColor
            labelDarkMode.textColor = sn.cellLightColor
            labelInvisible.textColor = sn.cellLightColor
            
            otherSettingsButton.setTitleColor(sn.cellLightColor, for: UIControl.State.normal)
            otherSettingsButton.backgroundColor = sn.cellDarkColor
            
            HiddenButton.setTitleColor(sn.cellLightColor, for: UIControl.State.normal)
            HiddenButton.backgroundColor = sn.cellDarkColor
            
            recentlyDeletedButton.setTitleColor(sn.cellLightColor, for: UIControl.State.normal)
            recentlyDeletedButton.backgroundColor = sn.cellDarkColor
            
            firstTextField.backgroundColor = sn.cellDarkColor
            firstTextField.layer.borderWidth = 0.5
            firstTextField.layer.cornerRadius = 4
            firstTextField.layer.borderColor = sn.e5e5ea.cgColor;
            
            secondTextField.backgroundColor = sn.cellDarkColor
            secondTextField.layer.borderWidth = 0.5
            secondTextField.layer.cornerRadius = 4
            secondTextField.layer.borderColor = sn.e5e5ea.cgColor;
            
            thirdTextField.backgroundColor = sn.cellDarkColor
            thirdTextField.layer.borderWidth = 0.5
            thirdTextField.layer.cornerRadius = 4
            thirdTextField.layer.borderColor = sn.e5e5ea.cgColor;
            
            fourthTextField.backgroundColor = sn.cellDarkColor
            fourthTextField.layer.borderWidth = 0.5
            fourthTextField.layer.cornerRadius = 4
            fourthTextField.layer.borderColor = sn.e5e5ea.cgColor;
            
            fifthTextField.backgroundColor = sn.cellDarkColor
            fifthTextField.layer.borderWidth = 0.5
            fifthTextField.layer.cornerRadius = 4
            fifthTextField.layer.borderColor = sn.e5e5ea.cgColor;

        } else {
            textView.backgroundColor = UIColor.white
            deleteView.backgroundColor = sn.e5e5ea
            noteView.backgroundColor = sn.e5e5ea
            labelView.backgroundColor = sn.e5e5ea
            darkModeView.backgroundColor = sn.e5e5ea
            invisibleView.backgroundColor = sn.e5e5ea

            labelAskWhenDelete.textColor = sn.cellDarkColor
            labelStartWithNewNote.textColor = sn.cellDarkColor
            labelDarkMode.textColor = sn.cellDarkColor
            labelInvisible.textColor = sn.cellDarkColor
            
            otherSettingsButton.setTitleColor(sn.cellDarkColor, for: UIControl.State.normal)
            otherSettingsButton.backgroundColor = sn.e5e5ea
            
            HiddenButton.setTitleColor(sn.cellDarkColor, for: UIControl.State.normal)
            HiddenButton.backgroundColor = sn.e5e5ea
            
            recentlyDeletedButton.setTitleColor(sn.cellDarkColor, for: UIControl.State.normal)
            recentlyDeletedButton.backgroundColor = sn.e5e5ea
            
            firstTextField.backgroundColor = sn.cellLightColor
            secondTextField.backgroundColor = sn.cellLightColor
            thirdTextField.backgroundColor = sn.cellLightColor
            fourthTextField.backgroundColor = sn.cellLightColor
            fifthTextField.backgroundColor = sn.cellLightColor
        }
    }
    
    func updateTextSize() {
        
        let textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))

        labelAskWhenDelete.font = labelAskWhenDelete.font.withSize(textSize)
        labelStartWithNewNote.font = labelStartWithNewNote.font.withSize(textSize)
        labelDarkMode.font = labelDarkMode.font.withSize(textSize)
        labelInvisible.font = labelInvisible.font.withSize(textSize)
        otherSettingsButton.titleLabel?.font =  otherSettingsButton.titleLabel?.font.withSize(textSize)
        HiddenButton.titleLabel?.font =  HiddenButton.titleLabel?.font.withSize(textSize)
        leftButton.titleLabel?.font =  leftButton.titleLabel?.font.withSize(textSize)
        rightButton.titleLabel?.font =  rightButton.titleLabel?.font.withSize(textSize)
        recentlyDeletedButton.titleLabel?.font =  recentlyDeletedButton.titleLabel?.font.withSize(textSize)
        
        updateIcons()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            switch textField {
            case firstTextField:
                secondTextField.becomeFirstResponder()
                break
            case secondTextField:
                thirdTextField.becomeFirstResponder()
                break
            case thirdTextField:
                fourthTextField.becomeFirstResponder()
                break
            case fourthTextField:
                fifthTextField.becomeFirstResponder()
                break
            default:
                firstTextField.becomeFirstResponder()
            }
            return true
        }

    @IBAction func deleteAllNotesPressed(_ sender: UIButton) {
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {

        if buttonState == 0 {
            buttonState = 1
            leftButton.setTitle("Cancel", for: UIControl.State.normal)
            rightButton.setTitle("Apply", for: UIControl.State.normal)
            
            firstTextField.isEnabled = true
            secondTextField.isEnabled = true
            thirdTextField.isEnabled = true
            fourthTextField.isEnabled = true
            fifthTextField.isEnabled = true
            
            rightButton.isHidden = false
            
            firstTextField.becomeFirstResponder()
        } else {
            buttonState = 0
            leftButton.setTitle("Edit", for: UIControl.State.normal)
            rightButton.setTitle("Default", for: UIControl.State.normal)
            
            firstTextField.text = UserDefaults.standard.string(forKey: "segmentAt1")
            secondTextField.text = UserDefaults.standard.string(forKey: "segmentAt2")
            thirdTextField.text = UserDefaults.standard.string(forKey: "segmentAt3")
            fourthTextField.text = UserDefaults.standard.string(forKey: "segmentAt4")
            fifthTextField.text = UserDefaults.standard.string(forKey: "segmentAt5")
            
            firstTextField.isEnabled = false
            secondTextField.isEnabled = false
            thirdTextField.isEnabled = false
            fourthTextField.isEnabled = false
            fifthTextField.isEnabled = false
             
            if UserDefaults.standard.integer(forKey: "isDefault") == 1 {
                self.rightButton.isHidden = true // if tags default, don't show default button
            } else {
                self.rightButton.isHidden = false
            }
        }
    }
    
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        // if edit clicked
        if buttonState == 1 {
            if firstTextField.text!.isEmpty || secondTextField.text!.isEmpty || thirdTextField.text!.isEmpty || fourthTextField.text!.isEmpty || fifthTextField.text!.isEmpty {
                //textFiedls are empty
                let alert = UIAlertController(title: "Tag can not be empty.", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    // what will happen once user clicks the add item button on UIAlert
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            } else {
                //textFiedls are full
                //text is different from before
                if firstTextField.text! != UserDefaults.standard.string(forKey: "segmentAt1")! ||
                    secondTextField.text! != UserDefaults.standard.string(forKey: "segmentAt2")! ||
                    thirdTextField.text! != UserDefaults.standard.string(forKey: "segmentAt3")! ||
                    fourthTextField.text! != UserDefaults.standard.string(forKey: "segmentAt4")! ||
                    fifthTextField.text! != UserDefaults.standard.string(forKey: "segmentAt5")! {
                    
                    self.rightButton.isHidden = false
                    
                    let alert = UIAlertController(title: "Tags will change like this", message: "\(firstTextField.text!)  \(secondTextField.text!)  \(thirdTextField.text!)  \(fourthTextField.text!)  \(fifthTextField.text!)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        // what will happen once user clicks the add item button on UIAlert
                        UserDefaults.standard.set(self.firstTextField.text!, forKey: "segmentAt1")
                        UserDefaults.standard.set(self.secondTextField.text!, forKey: "segmentAt2")
                        UserDefaults.standard.set(self.thirdTextField.text!, forKey: "segmentAt3")
                        UserDefaults.standard.set(self.fourthTextField.text!, forKey: "segmentAt4")
                        UserDefaults.standard.set(self.fifthTextField.text!, forKey: "segmentAt5")
                  
                        self.onViewWillDisappear?()
                        
                        self.firstTextField.isEnabled = false
                        self.secondTextField.isEnabled = false
                        self.thirdTextField.isEnabled = false
                        self.fourthTextField.isEnabled = false
                        self.fifthTextField.isEnabled = false
                        
                        self.buttonState = 0
                        self.leftButton.setTitle("Edit", for: UIControl.State.normal)
                        self.rightButton.setTitle("Default", for: UIControl.State.normal)
                        UserDefaults.standard.set(0, forKey: "isDefault")
                    }
                    
                    let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                        // what will happen once user clicks the cancel item button on UIAlert
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    alert.addAction(action)
                    alert.addAction(actionCancel)
                    present(alert, animated: true, completion: nil)
                    
                } else {
                    //text is same
                   // UserDefaults.standard.set(0, forKey: "isDefault")
                    self.rightButton.isHidden = true
                    
                    self.firstTextField.isEnabled = false
                    self.secondTextField.isEnabled = false
                    self.thirdTextField.isEnabled = false
                    self.fourthTextField.isEnabled = false
                    self.fifthTextField.isEnabled = false
                    
                    self.buttonState = 0
                    self.leftButton.setTitle("Edit", for: UIControl.State.normal)
                    self.rightButton.setTitle("Default", for: UIControl.State.normal)
                    if UserDefaults.standard.integer(forKey: "isDefault") == 1 {
                        self.rightButton.isHidden = true // if tags default, don't show default button
                    } else {
                        self.rightButton.isHidden = false
                    }
                }
            }
        } else {
                    let alert = UIAlertController(title: "All tags will be default", message: "⭐️  📚  🥰  🌸  🐼", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        // what will happen once user clicks the add item button on UIAlert
                        UserDefaults.standard.set("⭐️", forKey: "segmentAt1")
                        UserDefaults.standard.set("📚", forKey: "segmentAt2")
                        UserDefaults.standard.set("🥰", forKey: "segmentAt3")
                        UserDefaults.standard.set("🌸", forKey: "segmentAt4")
                        UserDefaults.standard.set("🐼", forKey: "segmentAt5")
                        UserDefaults.standard.set(1, forKey: "isDefault")
                        self.rightButton.isHidden = true
                        self.firstTextField.text = UserDefaults.standard.string(forKey: "segmentAt1")
                        self.secondTextField.text = UserDefaults.standard.string(forKey: "segmentAt2")
                        self.thirdTextField.text = UserDefaults.standard.string(forKey: "segmentAt3")
                        self.fourthTextField.text = UserDefaults.standard.string(forKey: "segmentAt4")
                        self.fifthTextField.text = UserDefaults.standard.string(forKey: "segmentAt5")
                        self.onViewWillDisappear?()
                    }
                    let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                        // what will happen once user clicks the cancel item button on UIAlert
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    alert.addAction(actionCancel)
                    present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }


    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }
    
    @IBAction func bottomViewPressed(_ sender: UIButton) {
        //checkAction()
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    func checkAction(){
        self.dismiss(animated: true, completion: nil)
    }
}

//moveImageLeftTextCenter
extension UIButton {
    func moveImageLeftTextCenter(imagePadding: CGFloat = 32.0){
        guard let imageViewWidth = self.imageView?.frame.width else{return}
        guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
        self.contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding - imageViewWidth / 2, bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
    }
}
