//
//  DeleteNotesViewController.swift
//  short note
//
//  Created by ibrahim uysal on 25.02.2022.
//
import UIKit

class DeleteAllNotesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var sView: UIStackView!
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var allNotesDeletedLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var labelPermenently: UILabel!
    @IBOutlet weak var labelUndone: UILabel!
    @IBOutlet weak var labelConfirm: UILabel!
    @IBOutlet weak var labelSum: UILabel!
    
    @IBOutlet weak var answerTextField: UITextField!
    
    var sn = ShortNote()
    
    var answer = 0
    
    //UserDefaults
    var darkMode : Int = 0
    
    var onViewWillDisappear: (()->())?
    
    override func viewDidLoad() {
        
        updateButtons()
        updateViews()
        
        assignUserDefaults()
        
        answerTextField.delegate = self
        allNotesDeletedLabel.isHidden = true
        
        if darkMode == 1 { updateColor() }
        
        let leftNumber = Int.random(in: 0..<10)
        let rightNumber = Int.random(in: 0..<10)
        
        questionLabel.text = "\(leftNumber) + \(rightNumber) ="
        answer = leftNumber + rightNumber
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onViewWillDisappear?()
    }
    
    //MARK: - IBAction
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        
        if answerTextField.text!.count > 0 {
            
            if Int(answerTextField.text!) == answer {
                
                let image = UIImage(named: "checkGreen.png")!
                checkButton.setBackgroundImage(image, for: .normal)
                
                UIView.transition(with: checkButton, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
                
                Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(flipSecond), userInfo: nil, repeats: false)
                
                Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(diss), userInfo: nil, repeats: false)
                
                sView.isHidden = true
                allNotesDeletedLabel.isHidden = false
                
                sn.loadItems()
                sn.deleteAllNotes()
            } else {
                answerTextField.text = ""
            }
        }
    }
    
    @IBAction func topViewPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Objc Functions
    
    @objc func flipSecond(){
        let image = UIImage(named: "checkGreen.png")!
        checkButton.setBackgroundImage(image, for: .normal)
        UIView.transition(with: checkButton, duration: 0.6, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }

    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Other Functions
    
    func assignUserDefaults(){
        darkMode = sn.getIntValue(sn.darkMode)
    }
    
    func updateButtons(){
        
        checkButton.setBackgroundImage(nil, for: .normal)
        checkButton.setTitle("", for: .normal)
        
        rightButton.layer.cornerRadius = 6
        leftButton.layer.cornerRadius = 6
    }
    
    func updateViews() {
        
        firstView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        
        textView.layer.cornerRadius = 12
    }
    
    func updateColor() {
        
        textView.backgroundColor = UIColor(named: "colorCellDark")
        
        updateLabelColor(labelPermenently)
        updateLabelColor(labelUndone)
        updateLabelColor(labelConfirm)
        updateLabelColor(labelSum)
        updateLabelColor(allNotesDeletedLabel)
    }
    
    func updateLabelColor(_ label:UILabel){
        label.textColor = UIColor(named: "colorCellLight")
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return self.textLimit(existingText: textField.text,
                              newText: string,
                              limit: 2)
    }
    
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
}
