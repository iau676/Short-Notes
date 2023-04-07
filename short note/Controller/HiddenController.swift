//
//  HiddenController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//

import UIKit
import CoreData

private let reuseIdentifier = "ExampleCell"

final class HiddenController: UIViewController {
    
    //MARK: - Properties

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    var sn = ShortNote()
    var hiddenItemArray = [Int]()
    
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
    
    private func assignUserDefaults() {
        tagSize = UDM.tagSize.getCGFloat()
        textSize = UDM.textSize.getCGFloat()
        imageSize = UDM.textSize.getCGFloat() + 5
        segmentAt1 = UDM.segmentAt1.getString()
        segmentAt2 = UDM.segmentAt2.getString()
        segmentAt3 = UDM.segmentAt3.getString()
        segmentAt4 = UDM.segmentAt4.getString()
        segmentAt5 = UDM.segmentAt5.getString()
    }
    
    private func findHiddenNotesCount(){
        hiddenItemArray.removeAll()
        for i in 0..<sn.itemArray.count {
            if sn.itemArray[i].isHiddenn == 1 {
                hiddenItemArray.append(i)
            }
        }
        tableView.reloadData()
    }
    
    private func goAdd(type: NoteType, note: Note? = nil) {
        let controller = AddController(noteType: type)
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.note = note
        present(controller, animated: true)
    }
    
    private func refreshTable(){
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

    func updateSearchBarPlaceholder() {
        let noteCount = hiddenItemArray.count
        searchBar.placeholder = noteCount > 0 ?
        (noteCount == 1 ?
         "Search in \(noteCount) hidden note" :
            "Search in \(noteCount) hidden notes") :
        "Nothing to see here"
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
        
        let deleteAction = makeAction(color: UIColor.red, image: Images.thrash) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void)  in
            hiddenItem.isDeletedd = 1
            hiddenItem.hideStatusBeforeDelete = hiddenItem.isHiddenn
         
            hiddenItem.isHiddenn = 0
            hiddenItem.deleteDate = Date()
            self.refreshTable()
            success(true)
        }
        
        let unhideAction = makeAction(color: Colors.gray, image: Images.unhide) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            hiddenItem.isHiddenn = 0
            self.refreshTable()
            success(true)
        }

         return UISwipeActionsConfiguration(actions: [deleteAction, unhideAction])
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let hiddenItem = self.sn.itemArray[self.hiddenItemArray[indexPath.row]]
        
        let editAction = makeAction(color: Colors.blue, image: Images.edit) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .edit, note: hiddenItem)
            success(true)
        }
        
        let lastNoteAction = makeAction(color: Colors.purple, image: Images.returN) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .previous, note: hiddenItem)
            success(true)
        }
        
        let copyAction = makeAction(color: Colors.yellow, image: Images.copy) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            UIPasteboard.general.string = String(hiddenItem.note ?? "")
            
            let alert = UIAlertController(title: "Copied to clipboard", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
            success(true)
        }
        
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
    }
}
