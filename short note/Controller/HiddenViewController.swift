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
    
    let tagSize = UserDefaults.standard.integer(forKey: "tagSize")
    let textSize = UserDefaults.standard.integer(forKey: "textSize")
    let imageSize = UserDefaults.standard.integer(forKey: "textSize") + 5
    
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
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(CGFloat(textSize))

        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
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
            tableView.backgroundColor = UIColor(named: "colorCellDark")
            searchBar.barTintColor = UIColor(named: "colorCellDark")
            if #available(iOS 13.0, *) {
                searchBar.searchTextField.textColor = UIColor(named: "colorCellLight")
                overrideUserInterfaceStyle = .dark
            } else {
                // Fallback on earlier versions
            }
        } else {
            tableView.backgroundColor = UIColor(named: "colorCellLight")
            searchBar.barTintColor = UIColor(named: "colorCellLight")
            if #available(iOS 13.0, *) {
                searchBar.searchTextField.textColor = UIColor(named: "colorCellDark")
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
                    self.saveLoadItemsUpdateSearchBar()
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

    //MARK: - tableView
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
        case "first":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt1")
            break
        case "second":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt2")
            break
        case "third":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt3")
            break
        case "fourth":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt4")
            break
        case "fifth":
            itemArray[tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt5")
            break
        default:
            itemArray[tempArray[indexPath.row]].label = " "
        }
        
        saveItems()
        
        cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
        cell.label.text = itemArray[tempArray[indexPath.row]].label
        
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
            
            cell.engView.backgroundColor = UIColor(named: "colorCellDark")
            cell.engLabel.textColor = UIColor(named: "colorTextLight")
            updateColors()
        } else {
            cell.engView.backgroundColor = UIColor(named: "colorCellLight")
            cell.engLabel.textColor = UIColor(named: "colorTextDark")
            updateColors()
        }
        
        cell.label.font = cell.label.font.withSize(CGFloat(tagSize))
        cell.engLabel.font = cell.engLabel.font.withSize(CGFloat(textSize))
        cell.dateLabel.font = cell.dateLabel.font.withSize(CGFloat(textSize-4))

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
                    self.saveLoadItemsUpdateSearchBar()
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
                self.saveLoadItemsUpdateSearchBar()
            }
            success(true)
        })
         deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
         deleteAction.backgroundColor = UIColor.red
         
         //tag-
         let favoriteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                     let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
                     let first = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt1"), style: .default) { (action) in
                         // what will happen once user clicks the add item button on UIAlert
                         //update simultaneously cell text when label type changed

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "first"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt1")
                         self.saveLoadItemsUpdateSearchBar()

                     }
                     let second = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt2"), style: .default) { (action) in

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "second"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt2")
                         self.saveLoadItemsUpdateSearchBar()
             
                     }
                     let third = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt3"), style: .default) { (action) in

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "third"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt3")
                         self.saveLoadItemsUpdateSearchBar()
             
                     }
                     let fourth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt4"), style: .default) { (action) in

                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "fourth"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt4")
                         self.saveLoadItemsUpdateSearchBar()
             
                     }
                     let fifth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt5"), style: .default) { (action) in
                         self.itemArray[self.tempArray[indexPath.row]].labelDetect = "fifth"
                         self.itemArray[self.tempArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt5")
                         self.saveLoadItemsUpdateSearchBar()
                     }
        
                     let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                     }
             
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "first" { alert.addAction(first) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "second" { alert.addAction(second) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "third" { alert.addAction(third) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "fourth" { alert.addAction(fourth) }
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "fifth" { alert.addAction(fifth) }
             
             if self.itemArray[self.tempArray[indexPath.row]].labelDetect != "" {
                 let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                     // what will happen once user clicks the add item button on UIAlert
                     self.itemArray[self.tempArray[indexPath.row]].labelDetect = ""
                     self.itemArray[self.tempArray[indexPath.row]].label = ""
                     self.saveLoadItemsUpdateSearchBar()
                 }
                 alert.addAction(removeLabel)
             }
             
             alert.addAction(cancel)
             success(true)
             self.present(alert, animated: true, completion: nil)
         })
          favoriteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
                  UIImage(named: "tag")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
              }
        favoriteAction.backgroundColor = UIColor(named: "colorBlue")
         
         //unhide-
         let unhideAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
             self.itemArray[self.tempArray[indexPath.row]].isHiddenn = 0
             self.saveLoadItemsUpdateSearchBar()

         })
         unhideAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "unhide")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        unhideAction.backgroundColor = UIColor(named: "colorGray")

         return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction, unhideAction])
    }
    
    func saveLoadItemsUpdateSearchBar(){
        saveItems()
        loadItems()
        changeSearchBarPlaceholder()
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        //edit-
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.tempArray[indexPath.row]
            let textEdit = self.itemArray[self.tempArray[indexPath.row]].note
            UserDefaults.standard.set(textEdit, forKey: "textEdit")
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        editAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "edit")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        editAction.backgroundColor = UIColor(named: "colorBlue")
        
        //previous-
        let lastNoteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.returnLastNote = 1
            self.editIndex = self.tempArray[indexPath.row]
            
            let lastNote = self.itemArray[self.tempArray[indexPath.row]].lastNote
            UserDefaults.standard.set(lastNote, forKey: "lastNote")
            
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        lastNoteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "return")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        lastNoteAction.backgroundColor = UIColor(named: "colorPurple")
        
        //copy-
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(self.itemArray[self.tempArray[indexPath.row]].note ?? "nothing")
            success(true)
        })
        copyAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "copy")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        copyAction.backgroundColor = UIColor(named: "colorYellow")
        
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
