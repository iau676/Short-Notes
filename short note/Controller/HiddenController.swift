//
//  HiddenController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//

import UIKit
import CoreData

private let reuseIdentifier = "ExampleCell"

class HiddenController: UIViewController {
    
    //MARK: - Properties

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    var sn = ShortNote()
    var hiddenItemArray = [Int]()
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    
    //UserDefaults
    var tagSize: CGFloat = 0.0
    var textSize: CGFloat = 0.0
    var imageSize: CGFloat = 0.0
    var segmentAt1: String = ""
    var segmentAt2: String = ""
    var segmentAt3: String = ""
    var segmentAt4: String = ""
    var segmentAt5: String = ""
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        assignUserDefaults()
        style()
        layout()
        
        sn.loadItems()
        findHiddenNotesCount()
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: - Helpers
    
    private func style() {
        tableView.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        searchBar.delegate = self
        searchBar.barTintColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        setSearchBar(searchBar, textSize)
    }
    
    private func layout() {
        let stack = UIStackView(arrangedSubviews: [searchBar, tableView])
        stack.spacing = 0
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func assignUserDefaults(){
        tagSize = UDM.getCGFloatValue(UDM.tagSize)
        textSize = UDM.getCGFloatValue(UDM.textSize)
        imageSize = UDM.getCGFloatValue(UDM.textSize) + 5
        segmentAt1 = UDM.getStringValue(UDM.segmentAt1)
        segmentAt2 = UDM.getStringValue(UDM.segmentAt2)
        segmentAt3 = UDM.getStringValue(UDM.segmentAt3)
        segmentAt4 = UDM.getStringValue(UDM.segmentAt4)
        segmentAt5 = UDM.getStringValue(UDM.segmentAt5)
    }
    
    func findHiddenNotesCount(){
        hiddenItemArray.removeAll()
        for i in 0..<sn.itemArray.count {
            if sn.itemArray[i].isHiddenn == 1 {
                hiddenItemArray.append(i)
            }
        }
        tableView.reloadData()
    }
    
    private func goAdd() {
        let controller = AddController()
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        if goEdit == 1 {
            controller.goEdit = 1
            controller.editIndex = editIndex
        }
        if returnLastNote == 1 {
            controller.returnLastNote = 1
            controller.editIndex = editIndex
        }
        present(controller, animated: true)
    }
    
    func refreshTable(){
        sn.saveItems()
        sn.loadItems()
        findHiddenNotesCount()
    }
}

//MARK: - Search Bar

extension HiddenController: UISearchBarDelegate {
    func setSearchBar(_ searchBar: UISearchBar, _ textSize: CGFloat){
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(textSize)

        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            let request : NSFetchRequest<Note> = Note.fetchRequest()
            request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
            sn.loadItems(with: request)
        } else {
            sn.loadItems()
        }
        findHiddenNotesCount()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            sn.loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            findHiddenNotesCount()
        }
    }

    func updateSearchBarPlaceholder(){
        if hiddenItemArray.count > 0 {
            searchBar.placeholder = (hiddenItemArray.count == 1 ? "Search in \(hiddenItemArray.count) hidden note" : "Search in \(hiddenItemArray.count) hidden notes")
        } else {
            searchBar.placeholder = "Nothing to see here"
        }
    }
}

    //MARK: - UITableViewDataSource

extension HiddenController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateSearchBarPlaceholder()
        return hiddenItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        let hiddenNote = sn.itemArray[hiddenItemArray[indexPath.row]]
        cell.note = hiddenNote
        return cell
    }
}

    //MARK: - UITableViewDelegate

extension HiddenController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let hiddenItem = self.sn.itemArray[self.hiddenItemArray[indexPath.row]]
         
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
       
            hiddenItem.isDeletedd = 1
            hiddenItem.hideStatusBeforeDelete = hiddenItem.isHiddenn
         
            hiddenItem.isHiddenn = 0
            hiddenItem.deleteDate = Date()
            self.refreshTable()
            success(true)
        })
        deleteAction.setImage(image: Images.thrash, width: imageSize, height: imageSize)
        deleteAction.setBackgroundColor(UIColor.red)
         
         let tagAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
             
             let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
             
             let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
                 hiddenItem.label = self.segmentAt1
                 self.refreshTable()
             }
             let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
                 hiddenItem.label = self.segmentAt2
                 self.refreshTable()
             }
             let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
                 hiddenItem.label = self.segmentAt3
                 self.refreshTable()
             }
             let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
                 hiddenItem.label = self.segmentAt4
                 self.refreshTable()
             }
             let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
                 hiddenItem.label = self.segmentAt5
                 self.refreshTable()
             }
             let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in}
             
             if hiddenItem.label != self.segmentAt1 { alert.addAction(first) }
             if hiddenItem.label != self.segmentAt2 { alert.addAction(second) }
             if hiddenItem.label != self.segmentAt3 { alert.addAction(third) }
             if hiddenItem.label != self.segmentAt4 { alert.addAction(fourth) }
             if hiddenItem.label != self.segmentAt5 { alert.addAction(fifth) }
             
             if hiddenItem.label != "" {
                 let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                     hiddenItem.label = ""
                     self.refreshTable()
                 }
                 alert.addAction(removeLabel)
             }
             alert.addAction(cancel)
             success(true)
             self.present(alert, animated: true, completion: nil)
         })
        tagAction.setImage(image: Images.tag, width: imageSize, height: imageSize)
        tagAction.setBackgroundColor(Colors.blue)
         
         let unhideAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
             hiddenItem.isHiddenn = 0
             self.refreshTable()
         })
         unhideAction.setImage(image: Images.unhide, width: imageSize, height: imageSize)
         unhideAction.setBackgroundColor(Colors.gray)

         return UISwipeActionsConfiguration(actions: [deleteAction, tagAction, unhideAction])
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let hiddenItem = self.sn.itemArray[self.hiddenItemArray[indexPath.row]]
        
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goEdit = 1
            self.editIndex = self.hiddenItemArray[indexPath.row]
            let textEdit = hiddenItem.note
            UDM.setValue(textEdit ?? "", UDM.textEdit)
            self.goAdd()
            success(true)
        })
        editAction.setImage(image: Images.edit, width: imageSize, height: imageSize)
        editAction.setBackgroundColor(Colors.blue)
        
        let lastNoteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.returnLastNote = 1
            self.editIndex = self.hiddenItemArray[indexPath.row]
            
            let lastNote = hiddenItem.lastNote
            UDM.setValue(lastNote ?? "", UDM.lastNote)
            
            self.goAdd()
            success(true)
        })
        lastNoteAction.setImage(image: Images.returN, width: imageSize, height: imageSize)
        lastNoteAction.setBackgroundColor(Colors.purple)
        
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(hiddenItem.note ?? "nothing")
            
            let alert = UIAlertController(title: "Copied to clipboard", message: "", preferredStyle: .alert)
            
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
            
            self.present(alert, animated: true, completion: nil)
            success(true)
        })
        copyAction.setImage(image: Images.copy, width: imageSize, height: imageSize)
        copyAction.setBackgroundColor(Colors.yellow)
        
        if (hiddenItem.isEdited) == 0 {
            return UISwipeActionsConfiguration(actions: [editAction, copyAction])
        } else {
            return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
        }
    }
}

//MARK: - AddControllerDelegate

extension HiddenController: AddControllerDelegate {
    func handleNewNote() {
        refreshTable()
        goEdit = 0
        returnLastNote = 0
    }
}
