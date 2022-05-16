//
//  DeleteNotesViewController.swift
//  short note
//
//  Created by ibrahim uysal on 25.02.2022.
//


import UIKit

class DeleteNotesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var sView: UIStackView!
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var allNotesDeletedLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var text4: UILabel!
    
    @IBOutlet weak var answerTextField: UITextField!
    var answer = 0

    var sn = ShortNote()
    
    var onViewWillDisappear: (()->())?
    
    override func viewDidLoad() {
        
        checkButton.setBackgroundImage(nil, for: .normal)
        checkButton.setTitle("", for: .normal)
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            updateColors()
        }
        
        answerTextField.delegate = self
        
        allNotesDeletedLabel.isHidden = true
        
        firstView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        
        textView.layer.cornerRadius = 12
        
        rightButton.layer.cornerRadius = 6
        
        leftButton.layer.cornerRadius = 6
        
        
        let leftNumber = Int.random(in: 0..<10)
        let rightNumber = Int.random(in: 0..<10)
        
        questionLabel.text = "\(leftNumber) + \(rightNumber) ="
        
        answer = leftNumber + rightNumber
        
        
        answerTextField.becomeFirstResponder()
        answerTextField.attributedPlaceholder = NSAttributedString(string:"?", attributes: [NSAttributedString.Key.foregroundColor: sn.cellDarkColor])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onViewWillDisappear?()
        }
    
    
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
                
                UserDefaults.standard.set(1, forKey: "deleteAllNotes")
            } else {
                answerTextField.text = ""
            }
        }
    }
    
    @objc func flipSecond(){
        
        let image = UIImage(named: "checkGreen.png")!
        checkButton.setBackgroundImage(image, for: .normal)
        UIView.transition(with: checkButton, duration: 0.6, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }


    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateColors() {
        textView.backgroundColor = sn.cellDarkColor
        text1.textColor = sn.cellLightColor
        text2.textColor = sn.cellLightColor
        text3.textColor = sn.cellLightColor
        text4.textColor = sn.cellLightColor
        allNotesDeletedLabel.textColor = sn.cellLightColor
    }
    
    
    @IBAction func topViewPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bottomViewPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
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
