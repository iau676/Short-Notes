//
//  RecentlyDeletedViewController.swift
//  short note
//
//  Created by ibrahim uysal on 11.03.2022.
//
import UIKit
import CoreData

class RecentlyDeletedViewController: UIViewController {
    
    @IBOutlet weak var dayText: UILabel!
    
    var sn = ShortNote()
    var deletedItemArray = [Int]()
    
    //UserDefaults
    var tagSize : CGFloat = 0.0
    var textSize : CGFloat = 0.0
    var imageSize : CGFloat = 0.0
    var segmentAt1 : String = ""
    var segmentAt2 : String = ""
    var segmentAt3 : String = ""
    var segmentAt4 : String = ""
    var segmentAt5 : String = ""
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        
        assignUserDefaults()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor(named: "red")
        sn.loadItems()
        
        dayText.font = dayText.font.withSize(textSize-4)
        deleteOldNotes()
        
        findDeletedItemsCount()
    }
    
    //MARK: - Other Functions
    
    func assignUserDefaults(){
        
        tagSize = sn.getCGFloatValue(sn.tagSize)
        textSize = sn.getCGFloatValue(sn.textSize)
        imageSize = sn.getCGFloatValue(sn.textSize) + 5
        segmentAt1 = sn.getStringValue(sn.segmentAt1)
        segmentAt2 = sn.getStringValue(sn.segmentAt2)
        segmentAt3 = sn.getStringValue(sn.segmentAt3)
        segmentAt4 = sn.getStringValue(sn.segmentAt4)
        segmentAt5 = sn.getStringValue(sn.segmentAt5)
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
        
        switch deletedItem.labelDetect {
        case "first":
            deletedItem.label = segmentAt1
            break
        case "second":
            deletedItem.label = segmentAt2
            break
        case "third":
            deletedItem.label = segmentAt3
            break
        case "fourth":
            deletedItem.label = segmentAt4
            break
        case "fifth":
            deletedItem.label = segmentAt5
            break
        default:
            deletedItem.label = " "
        }
        
        sn.saveItems()
        
        cell.noteLabel.text = deletedItem.note
        cell.tagLabel.text = deletedItem.label
        
        if sn.getIntValue(sn.switchShowDate) == 0 {
            if sn.getIntValue(sn.showHour) == 1 {
                cell.dateLabel.text = deletedItem.date?.getFormattedDate(format: "hh:mm a")
            } else {
                cell.dateLabel.text = ""
            }
        } else {
            cell.dateLabel.text = deletedItem.date?.getFormattedDate(format: sn.getStringValue(sn.selectedDateFormat))
        }

        if sn.getIntValue(sn.switchShowLabel) == 0 { cell.tagLabel.text = "" }
        cell.noteView.backgroundColor = UIColor(named: "red")
        cell.tagLabel.font = cell.tagLabel.font.withSize(tagSize)
        cell.noteLabel.font = cell.noteLabel.font.withSize(textSize)
        cell.dateLabel.font = cell.dateLabel.font.withSize(textSize-4)
        
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
                 //tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                 self.refreshTable()
                 
         })
         deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
         deleteAction.backgroundColor = UIColor.red

         return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //MARK: - Recover
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let recoverAction = UIContextualAction(style: .normal, title:  "Recover", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.sn.itemArray[self.deletedItemArray[indexPath.row]].isDeletedd = 0
            
            self.sn.itemArray[self.deletedItemArray[indexPath.row]].isHiddenn = self.sn.itemArray[self.deletedItemArray[indexPath.row]].hideStatusBeforeDelete
            
            //tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
            self.refreshTable()
        })
        recoverAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "recover")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        recoverAction.backgroundColor = UIColor(named: "colorGreen")
        
        return UISwipeActionsConfiguration(actions: [recoverAction])

    }
    
}
