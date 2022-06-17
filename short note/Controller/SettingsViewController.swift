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
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    
    @IBOutlet weak var labelStartWithNewNote: UILabel!
    @IBOutlet weak var labelDarkMode: UILabel!
    @IBOutlet weak var otherSettingsButton: UIButton!
    
    @IBOutlet weak var HiddenButton: UIButton!
    @IBOutlet weak var recentlyDeletedButton: UIButton!
    
    @IBOutlet weak var switchNote: UISwitch!
    @IBOutlet weak var switchDarkMode: UISwitch!
    
    @IBOutlet weak var firstTextField: UITextField! 
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var fifthTextField: UITextField!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var sn = ShortNote()
    
    var segmentIndexForUpdateHour = 0
    var segmentNumber = 0
    var goEdit = 0
    var editIndex = 0
    var labelName = ""
    var isOpen = false
    
    var leftButtonState = 0
    var rightButtonState = 0
    var buttonState = 0
    
    var onViewWillDisappear: (()->())?
    
    var textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
    
    let buttonImageSize = 18
    
    override func viewDidLoad() {
        
        setViews()
        setDefaults()
        
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
    
    //MARK: - prepare
    
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


    //MARK: - IBAction

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

    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Objc Functions
    
    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Other Functions
    
    func checkAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setViews(){
        
        firstView.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        
        setViewCornerRadius(textView, 12)
        setViewCornerRadius(noteView, 8)
        setViewCornerRadius(labelView, 8)
        setViewCornerRadius(darkModeView, 8)
        
        setButtonCornerRadius(leftButton, 4)
        setButtonCornerRadius(rightButton, 4)
        setButtonCornerRadius(otherSettingsButton, 8)
        setButtonCornerRadius(HiddenButton, 8)
        setButtonCornerRadius(recentlyDeletedButton, 8)
        
        leftButton.setTitle("Edit", for: UIControl.State.normal)
        rightButton.setTitle("Default", for: UIControl.State.normal)

        if UserDefaults.standard.integer(forKey: "isDefault") == 1 {
            rightButton.isHidden = true
        } else {
            rightButton.isHidden = false
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
        
        firstTextField.text = UserDefaults.standard.string(forKey: "segmentAt1")
        secondTextField.text = UserDefaults.standard.string(forKey: "segmentAt2")
        thirdTextField.text = UserDefaults.standard.string(forKey: "segmentAt3")
        fourthTextField.text = UserDefaults.standard.string(forKey: "segmentAt4")
        fifthTextField.text = UserDefaults.standard.string(forKey: "segmentAt5")
    }
    
    func setDefaults(){
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
    }
    
    func setIcons() {
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            updateIcon(HiddenButton, "hide")
            updateIcon(recentlyDeletedButton, "thrash")
            updateIcon(otherSettingsButton, "settings")
        } else {
            updateIcon(HiddenButton, "hideBlack")
            updateIcon(recentlyDeletedButton, "thrashBlack")
            updateIcon(otherSettingsButton, "settingsBlack")
        }
    }
    
    func setViewCornerRadius(_ view: UIView, _ number: Int){
        view.layer.cornerRadius = CGFloat(number)
    }
    
    func setButtonCornerRadius(_ button: UIButton, _ number: Int){
        button.layer.cornerRadius = CGFloat(number)
    }
    
    func setLabelSize(_ label:UILabel){
        label.font = label.font.withSize(textSize)
    }
    
    func setButtonFontSize(_ button:UIButton){
        button.titleLabel?.font =  button.titleLabel?.font.withSize(textSize)
    }
    
    func setLabelColor(_ label: UILabel, _ color: UIColor){
        label.textColor = color
    }
    
    func setViewBackgroundColor(_ view: UIView, _ color: UIColor){
        view.backgroundColor = color
    }
    
    func updateIcon(_ button: UIButton, _ imageName: String) {
        button.setImage(UIGraphicsImageRenderer(size: CGSize(width: buttonImageSize, height: buttonImageSize)).image { _ in
            UIImage(named: imageName)?.draw(in: CGRect(x: 0, y: 0, width: buttonImageSize, height: buttonImageSize)) }, for: .normal)
    }
    
    func updateColor() {
        
        setIcons()
        
        let colorFirstDark = (UserDefaults.standard.integer(forKey: "darkMode") == 1 ? UIColor(named: "colorCellDark") : UIColor(named: "colorCellLight"))
        
        let colorFirstLight = (UserDefaults.standard.integer(forKey: "darkMode") == 1 ? UIColor(named: "colorCellLight") : UIColor(named: "colorCellDark"))
        
        updateTextFieldColor(firstTextField, colorFirstDark!)
        updateTextFieldColor(secondTextField, colorFirstDark!)
        updateTextFieldColor(thirdTextField, colorFirstDark!)
        updateTextFieldColor(fourthTextField, colorFirstDark!)
        updateTextFieldColor(fifthTextField, colorFirstDark!)
        
        setLabelColor(labelStartWithNewNote, colorFirstLight!)
        setLabelColor(labelDarkMode, colorFirstLight!)
        
        setViewBackgroundColor(noteView, colorFirstDark!)
        setViewBackgroundColor(labelView, colorFirstDark!)
        setViewBackgroundColor(darkModeView, colorFirstDark!)
        
        updateButtonColor(otherSettingsButton, colorFirstDark!, colorFirstLight!)
        updateButtonColor(HiddenButton, colorFirstDark!, colorFirstLight!)
        updateButtonColor(recentlyDeletedButton, colorFirstDark!, colorFirstLight!)
        
        textView.backgroundColor = (UserDefaults.standard.integer(forKey: "darkMode") == 1 ? UIColor(named: "colorTextDark") : .white )
    }
    
    func updateTextFieldColor(_ textField: UITextField, _ color: UIColor){
        textField.backgroundColor = color
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 4
        textField.layer.borderColor = UIColor(named: "colord6d6d6")?.cgColor;
    }
    
    func updateButtonColor(_ button: UIButton, _ colorFirstDark: UIColor, _ colorFirstLight: UIColor){
        button.setTitleColor(colorFirstLight, for: UIControl.State.normal)
        button.backgroundColor = colorFirstDark
    }
    
    func updateTextSize() {
        textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))

        setLabelSize(labelStartWithNewNote)
        setLabelSize(labelDarkMode)
        
        setButtonFontSize(otherSettingsButton)
        setButtonFontSize(HiddenButton)
        setButtonFontSize(leftButton)
        setButtonFontSize(rightButton)
        setButtonFontSize(recentlyDeletedButton)
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
