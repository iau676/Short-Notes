//
//  RecentlyDeletedViewController.swift
//  short note
//
//  Created by ibrahim uysal on 11.03.2022.
//
import UIKit
import CoreData

class RecentlyDeletedViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var dayText: UILabel!
    

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var tempArray = [Int]()
    var sn = ShortNote()
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        updateColors()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor(named: "red")
        loadItems()
        
        
        dayText.font = dayText.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")-4))
        deleteOldNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }

    
    //MARK: - Model Manupulation Methods
    func saveItems() {
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()){
        do {
            request.sortDescriptors = [NSSortDescriptor(key: "deleteDate", ascending: false)]
          itemArray = try context.fetch(request)
        } catch {
           print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }
    
    //MARK: - updateColors
    func updateColors() {
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .dark
            } else {
                // Fallback on earlier versions
            }
        } else {
            
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var tArray = [Int]()

        
        for i in 0..<itemArray.count {
            if itemArray[i].isDeletedd == 1 {
                
                tArray.append(i)
            }
        }
      tempArray = tArray
        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! NoteCell
        
        
        
        //update simultaneously cell text when label type changed
        switch itemArray[tempArray[indexPath.row]].labelDetect {
        case "red":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt1")
            break
        case "green":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt2")
            break
        case "blue":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt3")
            break
        case "purple":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt4")
            break
        case "yellow":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt5")
            break
        default:
            itemArray[tempArray[indexPath.row]].label = " "
        }
        
        saveItems()
        

        cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
        
        cell.label.text = itemArray[tempArray[indexPath.row]].label
        
        
        
        
        print("tempArray.count--\(tempArray.count)")
        switch itemArray[tempArray[indexPath.row]].label  {
        case "🔴":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟠":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟡":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟢":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🔵":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟣":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "⚫️":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "⚪️":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟤":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🔶":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🔷":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🔳":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🔲":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟥":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟧":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟨":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟩":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟦":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟪":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "⬜️":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "⬛️":
            cell.label.font = cell.label.font.withSize(6)
            break
        case "🟫":
            cell.label.font = cell.label.font.withSize(6)
            break
        default:
            cell.label.font = cell.label.font.withSize(10)
        }
      
        if UserDefaults.standard.integer(forKey: "switchShowDate") == 1 {
            // 1 is true, 0 is false
            if UserDefaults.standard.integer(forKey: "showHour") == 1 {
                cell.dateLabel.text = itemArray[tempArray[indexPath.row]].date?.getFormattedDate(format: "hh:mm a")
            } else {
                cell.dateLabel.text = ""
            }
        } else {
            cell.dateLabel.text = itemArray[tempArray[indexPath.row]].date?.getFormattedDate(format: UserDefaults.standard.string(forKey: "selectedDateFormat") ?? "EEEE, MMM d, yyyy")
        }

        
        cell.engView.backgroundColor = UIColor(named: "red")
        
        //textSize
        cell.engLabel.font = cell.engLabel.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
        cell.dateLabel.font = cell.dateLabel.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")-4))
        
        return cell
    }
    
    
    func deleteOldNotes() {

        
        for i in stride(from: tempArray.count-1, through: 0, by: -1)  {
            if itemArray[tempArray[i]].isDeletedd == 1 {
                
                // subtract date from now
                let dateComponents = Calendar.current.dateComponents([.day], from: itemArray[tempArray[i]].deleteDate!, to: Date())
                

                if let daysCount = dateComponents.day {
                    if daysCount > 30 {
                        self.context.delete(self.itemArray[tempArray[i]])
                        self.itemArray.remove(at: tempArray[i])
                        self.saveItems()
                        self.loadItems()
                    }
                }
            }
        }

        
    }
    
    
}


extension RecentlyDeletedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
     func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         let textSize = UserDefaults.standard.integer(forKey: "textSize")
         
         let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
             
             // 1 is false, 0 is true
             if UserDefaults.standard.integer(forKey: "switchDelete") == 0 {
                 
                 let alert = UIAlertController(title: "Note will delete", message: "This action cannot be undone", preferredStyle: .alert)
                 let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                     // what will happen once user clicks the add item button on UIAlert
                     self.context.delete(self.itemArray[self.tempArray[indexPath.row]])
                     self.itemArray.remove(at: self.tempArray[indexPath.row])
                     tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                     self.saveItems()
                     self.loadItems()
                 }
                 
                 let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                     // what will happen once user clicks the cancel item button on UIAlert
                     alert.dismiss(animated: true, completion: nil)

                 }

                 alert.addAction(action)
                 alert.addAction(actionCancel)
                 self.present(alert, animated: true, completion: nil)
             } else {
                 //don't ask option
                 self.context.delete(self.itemArray[self.tempArray[indexPath.row]])
                 self.itemArray.remove(at: self.tempArray[indexPath.row])
                 tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                 self.saveItems()
                 self.loadItems()
             }
         })
         deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
             UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
         deleteAction.backgroundColor = UIColor.red

         return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    
    //MARK: - Recover
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let textSize = UserDefaults.standard.integer(forKey: "textSize")
        
        let recoverAction = UIContextualAction(style: .normal, title:  "Recover", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

             self.itemArray[self.tempArray[indexPath.row]].isDeletedd = 0
            
            self.itemArray[self.tempArray[indexPath.row]].isHiddenn = self.itemArray[self.tempArray[indexPath.row]].hideStatusBeforeDelete
            
             tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
             self.saveItems()
             self.loadItems()
        })
        recoverAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
            UIImage(named: "recover")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
        recoverAction.backgroundColor = UIColor(red: 0.40, green: 0.76, blue: 0.55, alpha: 1.00)
        
        return UISwipeActionsConfiguration(actions: [recoverAction])

    }
    
}


