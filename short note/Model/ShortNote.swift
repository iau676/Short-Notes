//
//  ShortNote.swift
//  short note
//
//  Created by ibrahim uysal on 24.02.2022.
//
import UIKit
import CoreData

struct ShortNote {
    
    static let shared = ShortNote()
    
    var itemArray = [Note]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let defaultEmojies = ["⭐️", "📚", "🥰", "🌸", "🐶"]

    let tagSize = "tagSize"
    let textSize = "textSize"
    let darkMode = "darkMode"
    let segmentAt1 = "segmentAt1"
    let segmentAt2 = "segmentAt2"
    let segmentAt3 = "segmentAt3"
    let segmentAt4 = "segmentAt4"
    let segmentAt5 = "segmentAt5"
    
    let showHour = "showHour"
    let switchShowLabel = "switchShowLabel"
    let switchShowDate = "switchShowDate"
    let switchNote = "switchNote"
    
    let segmentIndexForDate = "segmentIndexForDate"
    let segmentIndexForHour = "segmentIndexForHour"
    let selectedDateFormat = "selectedDateFormat"
    let selectedHourFormat = "selectedHourFormat"
    let selectedTimeFormat = "selectedTimeFormat"
    let isDefault = "isDefault"
    
    let lastBgColor = "lastBgColor"
    
    let textEdit = "textEdit"
    let lastNote = "lastNote"
    
    let selectedSegmentIndex = "selectedSegmentIndex"
    
    let themeIndex = "com.ibrahimuysal.short-note.ThemeManager.ThemeIndex"
    
    //MARK: - Model Manupulation Methods
    func saveItems() {
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
    }
    
    mutating func loadItems(with request: NSFetchRequest<Note> = Note.fetchRequest()){
        do {
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
          itemArray = try context.fetch(request)
        } catch {
           print("Error fetching data from context \(error)")
        }
    }
    
    mutating func loadItemsByDeleteDate(with request: NSFetchRequest<Note> = Note.fetchRequest()){
        do {
            request.sortDescriptors = [NSSortDescriptor(key: "deleteDate", ascending: false)]
          itemArray = try context.fetch(request)
        } catch {
           print("Error fetching data from context \(error)")
        }
    }
    
    //MARK: - Add New Note
    mutating func appendItem(_ noteTxtField: String, _ tag: String){
        let newItem = Note(context: self.context)
        newItem.note = noteTxtField
        newItem.date = Date()
        newItem.editDate = Date()
        newItem.deleteDate = Date()
        newItem.label = tag
        itemArray.append(newItem)
    }
    
    //MARK: - Delete Note
    mutating func deleteItem(at deleteIndex: Int){
        self.context.delete(self.itemArray[deleteIndex])
        self.itemArray.remove(at: deleteIndex)
    }
    
    mutating func deleteAllNotes() {
        let i = itemArray.count
        for _ in 0..<i {
            self.context.delete(self.itemArray[0])
            self.itemArray.remove(at: 0)
        }
        self.saveItems()
    }
}
