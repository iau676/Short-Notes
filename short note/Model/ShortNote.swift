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
    
    //MARK: - Helpers
    
    mutating func setFirstLaunch() {
        if UDM.textSize.getInt() == 0 {
           
            UDM.segmentAt1.set(defaultEmojies[0])
            UDM.segmentAt2.set(defaultEmojies[1])
            UDM.segmentAt3.set(defaultEmojies[2])
            UDM.segmentAt4.set(defaultEmojies[3])
            UDM.segmentAt5.set(defaultEmojies[4])
            
            UDM.textSize.set(15)
            UDM.tagSize.set(10)
            UDM.switchNote.set(0)
            UDM.switchShowDate.set(1)
            UDM.showHour.set(0)
            UDM.switchShowLabel.set(1)
            UDM.isDefault.set(1)
            
            UDM.selectedDateFormat.set("EEEE, d MMM yyyy")
            UDM.selectedHourFormat.set("hh:mm a")
            UDM.selectedTimeFormat.set("EEEE, d MMM yyyy")
            
            appendItem("Swipe -> Settings", defaultEmojies[0])
            appendItem("Swipe <- New Note", defaultEmojies[4])
            appendItem("Double click to change theme", defaultEmojies[2])
        }
    }
}
