//
//  UIViewController+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 11.02.2023.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HiddenController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, completion: @escaping(Bool)-> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: false, completion: nil)
            completion(true)
        }
        alert.addAction(actionOK)
        present(alert, animated: true)
      
    }
    
    func showAlertWithCancel(title: String, message: String, completion: @escaping(Bool)-> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: false, completion: nil)
            completion(true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithTimer(title: String, time: TimeInterval = 0.5) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        let when = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: when){
          alert.dismiss(animated: true, completion: nil)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func scheduledTimer(timeInterval: Double, _ selector : Selector) {
       Timer.scheduledTimer(timeInterval: timeInterval,
                            target: self,
                            selector: selector,
                            userInfo: nil,
                            repeats: false)
   }
}
