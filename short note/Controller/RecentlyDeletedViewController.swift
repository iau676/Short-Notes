//
//  RecentlyDeletedViewController.swift
//  short note
//
//  Created by ibrahim uysal on 11.03.2022.
//
import UIKit
import CoreData

class RecentlyDeletedViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    
    //MARK: - Variabes
    
    var sn = ShortNote()
    var deletedItemArray = [Int]()
    var days = 0
    
    //MARK: - UserDefaults
    
    var tagSize : CGFloat = 0.0
    var textSize : CGFloat = 0.0
    var imageSize : CGFloat = 0.0
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        assignUserDefaults()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = Colors.red
        infoLabel.font = infoLabel.font.withSize(textSize-4)
        
        sn.loadItemsByDeleteDate()
        
        deleteOldNotes()
        
        findDeletedItemsCount()
    }
    
    //MARK: - Helpers
    
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

//MARK: - Show Words

extension RecentlyDeletedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deletedItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! NoteCell
        
        let deletedItem = sn.itemArray[deletedItemArray[indexPath.row]]
        
        let dateComponents = Calendar.current.dateComponents([.day], from: deletedItem.deleteDate!, to: Date())
        
        if let daysCount = dateComponents.day { days = 30 - daysCount }
        
        cell.noteLabel.text = deletedItem.note
        cell.tagLabel.text = UDM.getIntValue(UDM.switchShowLabel) == 1 ? deletedItem.label : ""
        cell.dayLabel.text = (days > 1 ? "\(days) days" : "\(days) day")
        cell.dateLabel.text = deletedItem.date?.getFormattedDate(format: UDM.getStringValue(UDM.selectedTimeFormat))

        cell.noteView.backgroundColor = Colors.red
        cell.tagLabel.font = cell.tagLabel.font.withSize(tagSize)
        cell.noteLabel.font = cell.noteLabel.font.withSize(textSize)
        cell.dateLabel.font = cell.dateLabel.font.withSize(textSize-4)
        cell.dayLabel.font = cell.dayLabel.font.withSize(textSize-4)
        
        sn.saveItems()
        
        return cell
    }
}

//MARK: - Cell Swipe

extension RecentlyDeletedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Delete
    
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         
         let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
             self.sn.deleteItem(at: self.deletedItemArray[indexPath.row])
             self.refreshTable()
         })
         deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
         deleteAction.backgroundColor = UIColor.red

         return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //MARK: - Recover
    
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let recoverAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let item = self.sn.itemArray[self.deletedItemArray[indexPath.row]]
            item.isDeletedd = 0
            item.isHiddenn = item.hideStatusBeforeDelete
            self.refreshTable()
        })
        recoverAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "recover")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        recoverAction.backgroundColor = Colors.green
        
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
}
