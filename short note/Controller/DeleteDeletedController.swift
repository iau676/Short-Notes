//
//  DeleteNotesViewController.swift
//  short note
//
//  Created by ibrahim uysal on 25.02.2022.
//
import UIKit

final class DeleteAllNotesViewController: UIViewController, UITextFieldDelegate {
        
    private let textView = UIView()
    private let stackView = UIStackView()
    private let questionStackView = UIStackView()
    private let buttonStackView = UIStackView()
    
    private let allNotesDeletedLabel = UILabel()
    private let warnLabelBold = UILabel()
    private let warnLabel = UILabel()
    private let confirmLabel = UILabel()
    private let questionLabel = UILabel()
    private let answerTxtFld = UITextField()
    
    private let checkButton = UIButton()
    private let cancelButton = UIButton()
    private let deleteButton = UIButton()
    private let emptyButton = UIButton()
    private let empty2Button = UIButton()
        
    var sn = ShortNote()
    var answer = 0
    var onViewWillDisappear: (()->())?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        style()
        layout()
        updateButtons()
                
        answerTxtFld.delegate = self
        allNotesDeletedLabel.isHidden = true
        
        let leftNumber = Int.random(in: 0..<10)
        let rightNumber = Int.random(in: 0..<10)
        questionLabel.text = "\(leftNumber) + \(rightNumber) = "
        answer = leftNumber + rightNumber
    }
    
    override func viewWillAppear(_ animated: Bool) {
        answerTxtFld.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onViewWillDisappear?()
    }
    
    //MARK: - IBAction
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Selectors
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteButtonPressed(_ sender: UIButton) {
        if answerTxtFld.text!.count > 0 {
            if Int(answerTxtFld.text!) == answer {
                
                scheduledTimer(timeInterval: 0.0, #selector(flipCheckButton))
                scheduledTimer(timeInterval: 0.4, #selector(flipCheckButtonSecond))
                scheduledTimer(timeInterval: 1.2, #selector(dismissView))
             
                stackView.isHidden = true
                allNotesDeletedLabel.isHidden = false
                
                sn.loadItems()
                sn.deleteDeletedNotes()
            } else {
                answerTxtFld.text = ""
            }
        }
    }
    
    @objc func flipCheckButton(){
        checkButton.setBackgroundImage(Images.checkGreen, for: .normal)
        UIView.transition(with: checkButton, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    @objc func flipCheckButtonSecond(){
        UIView.transition(with: checkButton, duration: 0.6, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }

    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = Colors.red
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 8
        textView.backgroundColor = .white
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        questionStackView.translatesAutoresizingMaskIntoConstraints = false
        questionStackView.axis = .horizontal
        questionStackView.distribution = .fillEqually
        questionStackView.spacing = 5
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        
        allNotesDeletedLabel.translatesAutoresizingMaskIntoConstraints = false
        allNotesDeletedLabel.text = "Deleted"
        allNotesDeletedLabel.font = UIFont(name: Fonts.AvenirNextDemiBold, size: 21)
        allNotesDeletedLabel.textColor = .black
        allNotesDeletedLabel.textAlignment = .center
        
        warnLabelBold.translatesAutoresizingMaskIntoConstraints = false
        warnLabelBold.text = "Deleted notes will be permanently deleted"
        warnLabelBold.font = UIFont(name: Fonts.AvenirNextDemiBold, size: 15)
        warnLabelBold.textColor = .black
        warnLabelBold.textAlignment = .center
        
        warnLabel.translatesAutoresizingMaskIntoConstraints = false
        warnLabel.text = "This action cannot be undone"
        warnLabel.font = UIFont(name: Fonts.AvenirNextRegular, size: 15)
        warnLabel.textColor = .black
        warnLabel.textAlignment = .center
        
        confirmLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmLabel.text = "Please answer the question for the confirm"
        confirmLabel.font = UIFont(name: Fonts.AvenirNextRegular, size: 14)
        confirmLabel.textColor = .black
        confirmLabel.textAlignment = .center
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.text = "2 + 2 = "
        questionLabel.font = UIFont(name: Fonts.AvenirNextRegular, size: 15)
        questionLabel.textColor = .black
        questionLabel.textAlignment = .right
        
        answerTxtFld.translatesAutoresizingMaskIntoConstraints = false
        answerTxtFld.placeholder = "?"
        answerTxtFld.keyboardType = .numberPad
        answerTxtFld.backgroundColor = Colors.d6d6d6
        answerTxtFld.layer.cornerRadius = 4
        answerTxtFld.setLeftPaddingPoints(10)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = .white
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.backgroundColor = .white
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        emptyButton.translatesAutoresizingMaskIntoConstraints = false
        empty2Button.translatesAutoresizingMaskIntoConstraints = false
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layout() {
        view.addSubview(textView)
        textView.addSubview(stackView)
        textView.addSubview(questionStackView)
        textView.addSubview(buttonStackView)
        
        questionStackView.addArrangedSubview(emptyButton)
        questionStackView.addArrangedSubview(questionLabel)
        questionStackView.addArrangedSubview(answerTxtFld)
        questionStackView.addArrangedSubview(empty2Button)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(deleteButton)
        
        stackView.addArrangedSubview(warnLabelBold)
        stackView.addArrangedSubview(warnLabel)
        stackView.addArrangedSubview(confirmLabel)
        stackView.addArrangedSubview(questionStackView)
        stackView.addArrangedSubview(buttonStackView)
        
        view.addSubview(checkButton)
        textView.addSubview(allNotesDeletedLabel)
        
        NSLayoutConstraint.activate([
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            stackView.topAnchor.constraint(equalTo: textView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -16),
            
            checkButton.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -32),
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            allNotesDeletedLabel.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
            allNotesDeletedLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: 200),
            answerTxtFld.widthAnchor.constraint(equalToConstant: 50),
            checkButton.heightAnchor.constraint(equalToConstant: 120),
            checkButton.widthAnchor.constraint(equalToConstant: 120),
        ])
    }

    func updateButtons(){
        checkButton.setBackgroundImage(nil, for: .normal)
        checkButton.setTitle("", for: .normal)
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
