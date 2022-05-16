//
//  HiddenController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//

import UIKit
import CoreData

class HiddenViewController: UIViewController, UITableViewDataSource {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var tempArray = [Int]()
    var sn = ShortNote()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    
    var onViewWillDisappear: (()->())?
    
    override func viewDidLoad() {
        updateColors()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        loadItems()
        changeSearchBarPlaceholder()
        hideKeyboardWhenTappedAround()
        goEdit = 0
        
        
        // SearchBar text
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))

        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
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
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
          itemArray = try context.fetch(request)
        } catch {
           print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }
    
    //MARK: - updateColors
    func updateColors() {
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            tableView.backgroundColor = sn.cellDarkColor
            searchBar.barTintColor = sn.cellDarkColor
            if #available(iOS 13.0, *) {
                searchBar.searchTextField.textColor = sn.cellLightColor
                overrideUserInterfaceStyle = .dark
            } else {
                // Fallback on earlier versions
            }
        } else {
            tableView.backgroundColor = sn.cellLightColor
            searchBar.barTintColor = sn.cellLightColor
            if #available(iOS 13.0, *) {
                searchBar.searchTextField.textColor = sn.cellDarkColor
                overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    //MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goAdd" {
            let destinationVC = segue.destination as! AddViewController

            destinationVC.itemArray = itemArray
            destinationVC.modalPresentationStyle = .overFullScreen

            if segue.destination is AddViewController {
                (segue.destination as? AddViewController)?.onViewWillDisappear = {
//                    self.numberForSearchBar = 0
                    self.saveItems()
                    self.loadItems()
                    self.changeSearchBarPlaceholder()
                    self.goEdit = 0
                    self.returnLastNote = 0
                    }
            }

            if goEdit == 1 {
                destinationVC.goEdit = 1
                destinationVC.editIndex = editIndex
            }
            
            if returnLastNote == 1 {
                destinationVC.returnLastNote = 1
                destinationVC.editIndex = editIndex
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var tArray = [Int]()
        for i in 0..<itemArray.count {
            if itemArray[i].isHiddenn == 1 {
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
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            
            cell.engView.backgroundColor = sn.cellDarkColor
            cell.engLabel.textColor = sn.textLightColor
            updateColors()
        } else {
            cell.engView.backgroundColor = sn.cellLightColor
            cell.engLabel.textColor = sn.cellDarkColor
            updateColors()
        }
        
        //textSize
        
        cell.engLabel.font = cell.engLabel.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")))
        
        cell.dateLabel.font = cell.dateLabel.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "textSize")-4))

        return cell
    }
    
}


extension HiddenViewController: UITableViewDelegate {
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
         //delete-
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
           
            // 1 is false, 0 is true
            if UserDefaults.standard.integer(forKey: "switchDelete") == 0 {
                
                let alert = UIAlertController(title: "Note will delete", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    // what will happen once user clicks the add item button on UIAlert
                    self.itemArray[self.tempArray[indexPath.row]].isDeletedd = 1
                    self.itemArray[self.tempArray[indexPath.row]].hideStatusBeforeDelete = self.itemArray[self.tempArray[indexPath.row]].isHiddenn
             
                    self.itemArray[self.tempArray[indexPath.row]].isHiddenn = 0
                    self.itemArray[self.tempArray[indexPath.row]].deleteDate = Date()
                    self.saveItems()
                    self.loadItems()
                    self.changeSearchBarPlaceholder()
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
                self.itemArray[self.tempArray[indexPath.row]].isDeletedd = 1
                self.itemArray[self.tempArray[indexPath.row]].hideStatusBeforeDelete = self.itemArray[self.tempArray[indexPath.row]].isHiddenn
             
                self.itemArray[self.tempArray[indexPath.row]].isHiddenn = 0
                self.itemArray[self.tempArray[indexPath.row]].deleteDate = Date()
                self.saveItems()
                self.loadItems()
                self.changeSearchBarPlaceholder()
            }
            success(true)
        })
         deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
             UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
         deleteAction.backgroundColor = UIColor.red

         
         //tag-
         let favoriteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                     let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
                     let red = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt1"), style: .default) { (action) in
                         // what will happen once user clicks the add item button on UIAlert
                         //update simultaneously cell text when label type changed

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "red"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt1")
                         self.saveItems()
                         self.loadItems()
                         self.changeSearchBarPlaceholder()

                     }
                     let green = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt2"), style: .default) { (action) in

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "green"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt2")
                         self.saveItems()
                         self.loadItems()
                         self.changeSearchBarPlaceholder()
             
                     }
                     let blue = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt3"), style: .default) { (action) in

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "blue"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt3")
                         self.saveItems()
                         self.loadItems()
                         self.changeSearchBarPlaceholder()
             
                     }
                     let purple = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt4"), style: .default) { (action) in

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "purple"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt4")
                         self.saveItems()
                         self.loadItems()
                         self.changeSearchBarPlaceholder()
             
                     }
                     let yellow = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt5"), style: .default) { (action) in
                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "yellow"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt5")
                         self.saveItems()
                         self.loadItems()
                         self.changeSearchBarPlaceholder()
                     }
        
                     let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                     }
             
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "red" { alert.addAction(red) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "green" { alert.addAction(green) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "blue" { alert.addAction(blue) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "purple" { alert.addAction(purple) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "yellow" { alert.addAction(yellow) }
             
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "" {
                 let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                     // what will happen once user clicks the add item button on UIAlert
                     self.itemArray[self.tempArray[indexPath.row]].labelDetect = ""
                     self.itemArray[self.tempArray[indexPath.row]].label = ""
                     self.saveItems()
                     self.loadItems()
                     self.changeSearchBarPlaceholder()
                 }
                 alert.addAction(removeLabel)
             }
            
             
             alert.addAction(cancel)
             success(true)
             self.present(alert, animated: true, completion: nil)
         })
         // favoriteAction.image = UIImage(named: "tag")
          favoriteAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
                  UIImage(named: "tag")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5))
              }
          favoriteAction.backgroundColor = UIColor(red: 0.46, green: 0.62, blue: 0.80, alpha: 1.00)
         
         //unhide-
         let unhideAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            

             self.itemArray[self.tempArray[indexPath.row]].isHiddenn = 0
             self.saveItems()
             self.loadItems()
             self.changeSearchBarPlaceholder()

         })
         unhideAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
             UIImage(named: "unhide")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
         unhideAction.backgroundColor = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1.00)

         return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction, unhideAction])
    }
    
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let textSize = UserDefaults.standard.integer(forKey: "textSize")
        
        //edit-
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.tempArray[indexPath.row]
            let textEdit = self.itemArray[self.tempArray[indexPath.row]].note
            UserDefaults.standard.set(textEdit, forKey: "textEdit")
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        editAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
            UIImage(named: "edit")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
        editAction.backgroundColor = UIColor(red: 0.46, green: 0.62, blue: 0.80, alpha: 1.00)
        
        //previous-
        let lastNoteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.returnLastNote = 1
            self.editIndex = self.tempArray[indexPath.row]
            
            let lastNote = self.itemArray[self.tempArray[indexPath.row]].lastNote
            UserDefaults.standard.set(lastNote, forKey: "lastNote")
            
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        lastNoteAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
            UIImage(named: "return")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
        lastNoteAction.backgroundColor = UIColor(red: 0.61, green: 0.45, blue: 0.67, alpha: 1.00)
        
        //copy-
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(self.itemArray[self.tempArray[indexPath.row]].note ?? "nothing")
            success(true)
        })
        copyAction.image = UIGraphicsImageRenderer(size: CGSize(width: textSize+5, height: textSize+5)).image { _ in
            UIImage(named: "copy")?.draw(in: CGRect(x: 0, y: 0, width: textSize+5, height: textSize+5)) }
        copyAction.backgroundColor = UIColor(red: 1.00, green: 0.76, blue: 0.38, alpha: 1.00)
        
        
        if (itemArray[tempArray[indexPath.row]].isEdited) == 0 {
            return UISwipeActionsConfiguration(actions: [editAction, copyAction])
        } else {
            return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
        }
    }

}


//MARK: - searchbar
extension HiddenViewController: UISearchBarDelegate {
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    if searchBar.text!.count > 0 {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
        loadItems(with: request)
    }
    else {
        loadItems()
    }
}

func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
        loadItems()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

    func changeSearchBarPlaceholder(){
    

        if tempArray.count > 0 {
            searchBar.placeholder = (tempArray.count == 1 ? "Search in \(tempArray.count) hidden note" : "Search in \(tempArray.count) hidden notes")
        }
        else{
            searchBar.placeholder = "Nothing see here"
        }
           
    }
}

//MARK:- dismiss keyboard when user tap around
extension HiddenViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HiddenViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
