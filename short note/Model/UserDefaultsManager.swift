//
//  UserDefaultsManager.swift
//  short note
//
//  Created by ibrahim uysal on 9.02.2023.
//

import UIKit

struct UserDefaultsManager {
    
    // MARK: - Unique Key
    
    let key: String
    
    // MARK: - Storing Data
    
    func set(_ value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    // MARK: - Get Data
    
    func getValue() -> Any? {
        UserDefaults.standard.object(forKey: key)
    }
    
    func getBool() -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
    
    func getInt() -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
    
    func getString() -> String {
        UserDefaults.standard.string(forKey: key) ?? "empty"
    }
    
    func getDouble() -> Double {
        UserDefaults.standard.double(forKey: key)
    }
    
    func getCGFloat() -> CGFloat {
        CGFloat(UserDefaults.standard.integer(forKey: key))
    }
    
    // MARK: - Deleting Data
    
    func deleteValue() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
