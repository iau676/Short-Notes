//
//  NotesController.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

private let reuseIdentifier = "NoteCell"

final class NotesController: UIViewController {
    
    //MARK: - Properties
    
    var delegate: TagsControllerDelegate?
    
    private let tag: String
    private var sn = ShortNote()
    
    private var noteArray = [Note]() {
        didSet {
            updateSearchBarPlaceholder()
            tableView.reloadData()
        }
    }
    
    private let cellColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    //MARK: - Lifecycle
    
    init(tag: String) {
        self.tag = tag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sn.loadItems()
        style()
        layout()
        findNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateCV()
    }
    
    //MARK: - Helpers
    
    private func style() {
        searchBar.delegate = self
        searchBar.barTintColor = cellColor
        searchBar.updateTextField()
        
        tableView.allowsSelection = false
        tableView.backgroundColor = cellColor
        tableView.tableFooterView = UIView()
        tableView.register(NoteCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func layout() {
        view.backgroundColor = cellColor
        
        let stack = UIStackView(arrangedSubviews: [searchBar, tableView])
        stack.spacing = 0
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.fillSuperview()
    }
    
    private func findNotes() {
        noteArray = sn.filteredNormalNotes(tag: tag)
    }
    
    private func updateSearchBarPlaceholder() {
        let noteCount = noteArray.count
        searchBar.placeholder  = (noteCount > 0) ?
        (noteCount == 1 ?
         "Search in \(noteCount) note" :
            "Search in \(noteCount) notes") :
        "Nothing to see here"
    }
    
    private func goAdd(type: NoteType, note: Note? = nil) {
        let controller = AddController(noteType: type)
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.note = note
        present(controller, animated: true)
    }
    
    private func refreshTable() {
        sn.saveContext()
        sn.loadItems()
        findNotes()
    }
}

//MARK: - UISearchBarDelegate

extension NotesController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        sn.searchNote(text: text)
        findNotes()
    }
}

//MARK: - UITableViewDataSource

extension NotesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoteCell
        cell.note = noteArray[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate

extension NotesController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = noteArray[indexPath.row]

        let deleteAction = makeAction(color: UIColor.red, image: Images.thrash) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.sn.tempDelete(note: note)
            self.refreshTable()
            success(true)
        }
        
        let hideAction = makeAction(color: Colors.gray, image: Images.hide) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.sn.hide(note: note)
            self.refreshTable()
            success(true)
        }
         
        return UISwipeActionsConfiguration(actions: [deleteAction, hideAction])
    }
    
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = noteArray[indexPath.row]
        
        let editAction = makeAction(color: Colors.blue, image: Images.edit) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .edit, note: note)
            success(true)
        }
        
        let lastNoteAction = makeAction(color: Colors.purple, image: Images.returN) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .previous, note: note)
            success(true)
        }
        
        let copyAction = makeAction(color: Colors.yellow, image: Images.copy) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            UIPasteboard.general.string = String(note.note ?? "")
            self.showAlertWithTimer(title: "Copied to clipboard")
            success(true)
        }
        
        if (note.isEdited) == 0 {
            return UISwipeActionsConfiguration(actions: [editAction, copyAction])
        } else {
            return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
        }
    }
}

//MARK: - AddControllerDelegate

extension NotesController: AddControllerDelegate {
    func handleNewNote() {
        refreshTable()
    }
}
