//
//  RecentlyDeletedViewController.swift
//  short note
//
//  Created by ibrahim uysal on 11.03.2022.
//
import UIKit

private let reuseIdentifier = "ExampleCell"

final class RecentlyDeletedController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var infoLabel = UILabel()
    private lazy var tableView = UITableView()
    private let deleteAllButton = UIButton()

    private var sn = ShortNote()
    private var tagSize: CGFloat = UDM.tagSize.getCGFloat()
    private var textSize: CGFloat = UDM.textSize.getCGFloat()

    private var deletedNoteArray = [Note]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        sn.loadItemsByDeleteDate()
        sn.deleteOldNotes()
        style()
        layout()
        findDeletedNotes()
    }
    
    //MARK: - Selectors
    
    @objc private func deleteAllButtonPressed() {
        let leftNumber = Int.random(in: 0..<10)
        let rightNumber = Int.random(in: 0..<10)
        let answer = "\(leftNumber + rightNumber)"
        let title = "Delete All"
        let message = "\nThis action cannot be undone\n\nPlease answer the question to confirm"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = " \(leftNumber) + \(rightNumber) = ?" }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let select = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            alert.dismiss(animated: true) {
                if text == answer {
                    self.sn.deleteDeletedNotes()
                    self.refreshTable()
                    self.showAlertWithTimer(title: "Done")
                } else {
                    self.showAlertWithTimer(title: "Wrong Answer")
                }
            }
        }
        alert.addAction(cancel)
        alert.addAction(select)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = Colors.gray
        
        infoLabel.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize-4)
        infoLabel.textColor = .darkGray
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.text = "Notes are available here for 30 days. After that time, notes will be permanently deleted."
        
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Colors.red
        
        deleteAllButton.setImage(image: Images.thrash, width: 24, height: 24)
        deleteAllButton.imageView?.tintColor = .red
        deleteAllButton.backgroundColor = Colors.red
        deleteAllButton.addTarget(self, action: #selector(deleteAllButtonPressed), for: .touchUpInside)
        deleteAllButton.setHeight(height: 66)
    }
    
    private func layout() {
        let stack = UIStackView(arrangedSubviews: [infoLabel, tableView, deleteAllButton])
        stack.spacing = 0
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor,
                     paddingTop: 8)
    }
    
    private func findDeletedNotes() {
        deletedNoteArray = sn.deletedNotes()
        deleteAllButton.isHidden = deletedNoteArray.count == 0
    }
    
    private func refreshTable(){
        self.sn.saveContext()
        self.sn.loadItems()
        self.findDeletedNotes()
    }
}

//MARK: - UITableViewDataSource

extension RecentlyDeletedController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deletedNoteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        cell.note = deletedNoteArray[indexPath.row]
        cell.contentView.backgroundColor = Colors.red
        return cell
    }
}

//MARK: - UITableViewDelegate

extension RecentlyDeletedController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = makeAction(color: UIColor.red, image: Images.thrash) { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void)  in
            let note = self.deletedNoteArray[indexPath.row]
            let title = "'\(note.note?.prefix(10) ?? "Note")' will be deleted"
            let message = "This action cannot be undone"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.sn.delete(note: note)
                self.refreshTable()
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            self.present(alert, animated: true, completion: nil)
            success(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
        
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let recoverAction = makeAction(color: Colors.green, image: Images.recover) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let note = self.deletedNoteArray[indexPath.row]
            self.sn.recover(note: note)
            self.refreshTable()
        }
        
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
}
