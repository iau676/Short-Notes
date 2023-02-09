//
//  UserDefaultsManager.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

struct UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    func getCGFloatValue(_ key: String) -> CGFloat {
       return CGFloat(UserDefaults.standard.integer(forKey: key))
    }
    
    func getIntValue(_ key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func getStringValue(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    func setValue( _ value: Any, _ key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
