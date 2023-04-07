//
//  HiddenController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//

import UIKit

private let reuseIdentifier = "ExampleCell"

final class HiddenController: UIViewController {
    
    //MARK: - Properties

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    private var sn = ShortNote()
    
    private var tagSize: CGFloat = UDM.tagSize.getCGFloat()
    private var textSize: CGFloat = UDM.textSize.getCGFloat()

    private var hiddenNoteArray = [Note]() {
        didSet {
            updateSearchBarPlaceholder()
            tableView.reloadData()
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        style()
        layout()
        
        sn.loadItems()
        findHiddenNotes()
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
        searchBar.updateTextField()
    }
    
    private func layout() {
        let stack = UIStackView(arrangedSubviews: [searchBar, tableView])
        stack.spacing = 0
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    private func findHiddenNotes() {
        hiddenNoteArray = sn.hiddenNotes()
    }
    
    private func goAdd(type: NoteType, note: Note? = nil) {
        let controller = AddController(noteType: type)
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.note = note
        present(controller, animated: true)
    }
    
    private func updateSearchBarPlaceholder() {
        let noteCount = hiddenNoteArray.count
        searchBar.placeholder = noteCount > 0 ?
        (noteCount == 1 ?
         "Search in \(noteCount) hidden note" :
            "Search in \(noteCount) hidden notes") :
        "Nothing to see here"
    }
    
    private func refreshTable(){
        sn.saveItems()
        sn.loadItems()
        findHiddenNotes()
    }
}

//MARK: - UISearchBarDelegate

extension HiddenController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        sn.searchNote(text: text)
        findHiddenNotes()
    }
}

    //MARK: - UITableViewDataSource

extension HiddenController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hiddenNoteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        cell.note = hiddenNoteArray[indexPath.row]
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
        
        let hiddenItem = hiddenNoteArray[indexPath.row]
        
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
        
        let hiddenItem = hiddenNoteArray[indexPath.row]
        
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
            self.showAlertWithTimer(title: "Copied to clipboard")
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
