//
//  RecentlyDeletedViewController.swift
//  short note
//
//  Created by ibrahim uysal on 11.03.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "ExampleCell"

final class RecentlyDeletedController: UIViewController {
    
    //MARK: - Properties
    
    private let tableView = UITableView()
    private let infoLabel = UILabel()

    var sn = ShortNote()
    var days = 0
    var tagSize: CGFloat = 0.0
    var textSize: CGFloat = 0.0
    var imageSize: CGFloat = 0.0
    var deletedItemArray = [Int]()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        assignUserDefaults()
        style()
        layout()
        sn.loadItemsByDeleteDate()
        deleteOldNotes()
        findDeletedItemsCount()
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = Colors.gray
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Colors.red
        
        infoLabel.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize-4)
        infoLabel.textColor = .darkGray
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.text = "Notes are available here for 30 days. After that time, notes will be permanently deleted."
    }
    
    private func layout() {
        let stack = UIStackView(arrangedSubviews: [infoLabel, tableView])
        stack.spacing = 8
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor,
                     paddingTop: 8)
    }
    
    func assignUserDefaults(){
        tagSize = UDM.getCGFloatValue(UDM.tagSize)
        textSize = UDM.getCGFloatValue(UDM.textSize)
        imageSize = UDM.getCGFloatValue(UDM.textSize) + 5
    }
    
    func deleteOldNotes() {
        for i in stride(from: sn.itemArray.count-1, through: 0, by: -1)  {
            if sn.itemArray[i].isDeletedd == 1 {
                // subtract date from now
                let dateComponents = Calendar.current.dateComponents([.day], from: sn.itemArray[i].deleteDate!, to: Date())
                if let daysCount = dateComponents.day {
                    if daysCount > 29 {
                        sn.deleteItem(at: i)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func findDeletedItemsCount(){
        deletedItemArray.removeAll()
        for i in 0..<sn.itemArray.count {
            if sn.itemArray[i].isDeletedd == 1 {
                deletedItemArray.append(i)
            }
        }
    }
    
    func refreshTable(){
        self.sn.saveItems()
        self.sn.loadItems()
        self.findDeletedItemsCount()
        self.tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension RecentlyDeletedController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deletedItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        let deletedNote = sn.itemArray[deletedItemArray[indexPath.row]]
        let dateComponents = Calendar.current.dateComponents([.day], from: deletedNote.deleteDate!, to: Date())
        if let daysCount = dateComponents.day { days = 30 - daysCount }
        
        cell.note = deletedNote
        cell.dayLabel.text = (days > 1 ? "\(days) days" : "\(days) day")
        cell.contentView.backgroundColor = Colors.red
        
        sn.saveItems()
        
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
         
         let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
             self.sn.deleteItem(at: self.deletedItemArray[indexPath.row])
             self.refreshTable()
         })
         deleteAction.setImage(image: Images.thrash, width: imageSize, height: imageSize)
         deleteAction.backgroundColor = UIColor.red

         return UISwipeActionsConfiguration(actions: [deleteAction])
    }
        
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let recoverAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let item = self.sn.itemArray[self.deletedItemArray[indexPath.row]]
            item.isDeletedd = 0
            item.isHiddenn = item.hideStatusBeforeDelete
            self.refreshTable()
        })
        recoverAction.setImage(image: Images.recover, width: imageSize+4, height: imageSize+4)
        recoverAction.backgroundColor = Colors.green
        
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
}
