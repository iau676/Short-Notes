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
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize-4)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Notes are available here for 30 days. After that time, notes will be permanently deleted."
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Colors.red
        return tableView
    }()

    private var sn = ShortNote()
    private var tagSize: CGFloat = UDM.tagSize.getCGFloat()
    private var textSize: CGFloat = UDM.textSize.getCGFloat()

    private var deletedNoteArray = [Note]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        sn.loadItemsByDeleteDate()
        sn.deleteOldNotes()
        configureUI()
        findDeletedNotes()
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = Colors.gray
        
        let stack = UIStackView(arrangedSubviews: [infoLabel, tableView])
        stack.spacing = 8
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor,
                     paddingTop: 8)
    }
    
    private func findDeletedNotes() {
        deletedNoteArray = sn.deletedNotes()
    }
    
    private func refreshTable(){
        self.sn.saveItems()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = makeAction(color: UIColor.red, image: Images.thrash) { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void)  in
            self.sn.deleteItem(at: indexPath.row)
            self.refreshTable()
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
        
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let recoverAction = makeAction(color: Colors.green, image: Images.recover) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let item = self.deletedNoteArray[indexPath.row]
            item.isDeletedd = 0
            item.isHiddenn = item.hideStatusBeforeDelete
            self.refreshTable()
        }
        
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
}
