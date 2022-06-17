//
//  ShortNote.swift
//  short note
//
//  Created by ibrahim uysal on 24.02.2022.
//
import UIKit
import CoreData

struct ShortNote {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Model Manupulation Methods
    func saveItems() {
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
    }
    
    mutating func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()){
        do {
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
          itemArray = try context.fetch(request)
        } catch {
           print("Error fetching data from context \(error)")
        }
    }
    
    //MARK: - Add New Note
    mutating func appendItem(_ noteTxtField: String, _ labelName: String){
        let newItem = Item(context: self.context)
        newItem.note = noteTxtField
        newItem.date = Date()
        newItem.editDate = Date()
        newItem.deleteDate = Date()
        newItem.labelDetect = labelName
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
