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
    
    let defaultEmojies = ["🔵", "🟡", "🟣", "🔴", "🟢"]
    var fiveEmojies = [String]()
    
    //MARK: - Model Manupulation Methods
    
    func saveContext() {
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
    }
    
    mutating func loadItems(with request: NSFetchRequest<Note> = Note.fetchRequest()){
        configureFiveEmojies()
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
    
    mutating func deleteDeletedNotes() {
        for item in itemArray {
            if item.isDeletedd == 1 {
                self.context.delete(item)
            }
        }
        self.saveContext()
    }
    
    mutating func deleteOldNotes() {
        for i in stride(from: itemArray.count-1, through: 0, by: -1)  {
            if itemArray[i].isDeletedd == 1 {
                if let deleteDate = itemArray[i].deleteDate {
                    let dateComponents = Calendar.current.dateComponents([.day],
                                                                         from: deleteDate,
                                                                         to: Date())
                    if let daysCount = dateComponents.day {
                        if daysCount > 29 {
                            deleteItem(at: i)
                        }
                    }
                }
            }
        }
        saveContext()
    }
    
    //MARK: - UIContextualAction
    
    mutating func delete(note: Note) {
        self.context.delete(note)
    }
    
    mutating func tempDelete(note: Note) {
        note.isDeletedd = 1
        note.deleteDate = Date()
        note.hideStatusBeforeDelete = note.isHiddenn
    }
    
    mutating func hide(note: Note) {
        note.isHiddenn = 1
    }
    
    mutating func unhide(note: Note) {
        note.isHiddenn = 0
    }
    
    mutating func recover(note: Note) {
        note.isDeletedd = 0
        note.isHiddenn = note.hideStatusBeforeDelete
    }
    
    //MARK: - Helpers
    
    private mutating func configureFiveEmojies() {
        fiveEmojies.removeAll()
        fiveEmojies.append("All")
        fiveEmojies.append(UDM.segmentAt1.getString())
        fiveEmojies.append(UDM.segmentAt2.getString())
        fiveEmojies.append(UDM.segmentAt3.getString())
        fiveEmojies.append(UDM.segmentAt4.getString())
        fiveEmojies.append(UDM.segmentAt5.getString())
    }
    
    mutating func searchNote(text: String) {
        if text.count > 0 {
            let request : NSFetchRequest<Note> = Note.fetchRequest()
            request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", text)
            request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
            loadItems(with: request)
        } else {
            loadItems()
        }
    }
    
    func findTags() -> [Dictionary<String, Int>.Element] {
        var tagDict = [String: Int]()
        var sortedTagDict = [Dictionary<String, Int>.Element]()
        
        for item in itemArray {
            if let label = item.label {
                if item.isHiddenn == 0 && item.isDeletedd == 0 && label.count > 0 {
                    tagDict.updateValue((tagDict[label] ?? 0)+1, forKey: label)
                    sortedTagDict = tagDict.sorted{$0.value > $1.value}
                }
            }
        }
        return sortedTagDict
    }
    
    func normalNotes() -> [Note] {
        var normalNotes = [Note]()
        for item in itemArray {
            if item.isHiddenn == 0 && item.isDeletedd == 0 {
                normalNotes.append(item)
            }
        }
        return normalNotes
    }
    
    func filteredNormalNotes(tag: String) -> [Note] {
        var filteredNormalNotes = [Note]()
        for item in itemArray {
            if let label = item.label {
                if item.isHiddenn == 0 && item.isDeletedd == 0 && label == tag {
                    filteredNormalNotes.append(item)
                }
             }
        }
        return filteredNormalNotes
    }
    
    func hiddenNotes() -> [Note] {
        var hiddenNotes = [Note]()
        for item in itemArray {
            if item.isHiddenn == 1 {
                hiddenNotes.append(item)
            }
        }
        return hiddenNotes
    }
    
    func deletedNotes() -> [Note] {
        var deletedNotes = [Note]()
        for item in itemArray {
            if item.isDeletedd == 1 {
                deletedNotes.append(item)
            }
        }
        return deletedNotes
    }
    
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
            UDM.switchDoubleClick.set(true)
            UDM.isDefault.set(1)
            
            UDM.selectedDateFormat.set("EEEE, d MMM yyyy")
            UDM.selectedHourFormat.set("hh:mm a")
            UDM.selectedTimeFormat.set("EEEE, d MMM yyyy")
            
            appendItem("Swipe -> Settings", defaultEmojies[0])
            appendItem("Swipe <- New Note", defaultEmojies[4])
            appendItem("Double click to change theme", defaultEmojies[2])
            saveContext()
        }
    }
}
