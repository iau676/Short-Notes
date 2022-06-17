//
//  HiddenController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//

import UIKit
import CoreData

class HiddenViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var sn = ShortNote()
    var hiddenItemArray = [Int]()
    
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    
    var onViewWillDisappear: (()->())?
    
    let tagSize = UserDefaults.standard.integer(forKey: "tagSize")
    let textSize = UserDefaults.standard.integer(forKey: "textSize")
    let imageSize = UserDefaults.standard.integer(forKey: "textSize") + 5
    
    override func viewDidLoad() {
        
        sn.loadItems()
        
        updateColors()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        
        findHiddenNotesCount()
        
        searchBar.delegate = self
        hideKeyboardWhenTappedAround()
        
        setSearchBar(searchBar, textSize)
    }
    
    //MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goAdd" {
            let destinationVC = segue.destination as! AddViewController

            destinationVC.modalPresentationStyle = .overFullScreen

            if segue.destination is AddViewController {
                (segue.destination as? AddViewController)?.onViewWillDisappear = {
                    self.saveLoadItems()
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
    
    //MARK: - Other Functions
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
    
    func findHiddenNotesCount(){
        hiddenItemArray.removeAll()
        for i in 0..<sn.itemArray.count {
            if sn.itemArray[i].isHiddenn == 1 {
                hiddenItemArray.append(i)
            }
        }
    }
    
    func saveLoadItems(){
        sn.saveItems()
        sn.loadItems()
        findHiddenNotesCount()
        self.tableView.reloadData()
    }
    
}

//MARK: - Search Bar
extension HiddenViewController: UISearchBarDelegate {
    
    func setSearchBar(_ searchBar: UISearchBar, _ textSize: Int){
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(CGFloat(textSize))

        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
            sn.loadItems(with: request)
        } else {
            sn.loadItems()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            sn.loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func updateSearchBarPlaceholder(){
        if hiddenItemArray.count > 0 {
            searchBar.placeholder = (hiddenItemArray.count == 1 ? "Search in \(hiddenItemArray.count) hidden note" : "Search in \(hiddenItemArray.count) hidden notes")
        } else {
            searchBar.placeholder = "Nothing see here"
        }
    }
}

    //MARK: - Show Words
extension HiddenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        updateSearchBarPlaceholder()
        
        return hiddenItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! NoteCell
        
        switch sn.itemArray[hiddenItemArray[indexPath.row]].labelDetect {
        case "first":
            sn.itemArray[hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt1")
            break
        case "second":
            sn.itemArray[hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt2")
            break
        case "third":
            sn.itemArray[hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt3")
            break
        case "fourth":
            sn.itemArray[hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt4")
            break
        case "fifth":
            sn.itemArray[hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt5")
            break
        default:
            sn.itemArray[hiddenItemArray[indexPath.row]].label = " "
        }
        
        sn.saveItems()
        
        cell.noteLabel.text = sn.itemArray[hiddenItemArray[indexPath.row]].note
        cell.tagLabel.text = sn.itemArray[hiddenItemArray[indexPath.row]].label
        
        if UserDefaults.standard.integer(forKey: "switchShowDate") == 1 {
            // 1 is true, 0 is false
            if UserDefaults.standard.integer(forKey: "showHour") == 1 {
                cell.dateLabel.text = sn.itemArray[hiddenItemArray[indexPath.row]].date?.getFormattedDate(format: "hh:mm a")
            } else {
                cell.dateLabel.text = ""
            }
        } else {
            cell.dateLabel.text = sn.itemArray[hiddenItemArray[indexPath.row]].date?.getFormattedDate(format: UserDefaults.standard.string(forKey: "selectedDateFormat") ?? "EEEE, MMM d, yyyy")
        }
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            cell.noteView.backgroundColor = UIColor(named: "colorCellDark")
            cell.noteLabel.textColor = UIColor(named: "colorTextLight")
            updateColors()
        } else {
            cell.noteView.backgroundColor = UIColor(named: "colorCellLight")
            cell.noteLabel.textColor = UIColor(named: "colorTextDark")
            updateColors()
        }
        
        cell.tagLabel.font = cell.tagLabel.font.withSize(CGFloat(tagSize))
        cell.noteLabel.font = cell.noteLabel.font.withSize(CGFloat(textSize))
        cell.dateLabel.font = cell.dateLabel.font.withSize(CGFloat(textSize-4))

        return cell
    }
}

    //MARK: - Cell Swipe
extension HiddenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //MARK: - Cell Left Swipe
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         
         //delete-
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
           
            // 1 is false, 0 is true
            if UserDefaults.standard.integer(forKey: "switchDelete") == 0 {
                
                let alert = UIAlertController(title: "Note will delete", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    // what will happen once user clicks the add item button on UIAlert
                    self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isDeletedd = 1
                    self.sn.itemArray[self.hiddenItemArray[indexPath.row]].hideStatusBeforeDelete = self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isHiddenn
             
                    self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isHiddenn = 0
                    self.sn.itemArray[self.hiddenItemArray[indexPath.row]].deleteDate = Date()
                    self.saveLoadItems()
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
                self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isDeletedd = 1
                self.sn.itemArray[self.hiddenItemArray[indexPath.row]].hideStatusBeforeDelete = self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isHiddenn
             
                self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isHiddenn = 0
                self.sn.itemArray[self.hiddenItemArray[indexPath.row]].deleteDate = Date()
                self.saveLoadItems()
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

                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect = "first"
                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt1")
                         self.saveLoadItems()

                     }
                     let second = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt2"), style: .default) { (action) in

                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect = "second"
                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt2")
                         self.saveLoadItems()
             
                     }
                     let third = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt3"), style: .default) { (action) in

                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect = "third"
                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt3")
                         self.saveLoadItems()
             
                     }
                     let fourth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt4"), style: .default) { (action) in

                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect = "fourth"
                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt4")
                         self.saveLoadItems()
             
                     }
                     let fifth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt5"), style: .default) { (action) in
                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect = "fifth"
                         self.sn.itemArray[self.hiddenItemArray[indexPath.row]].label = UserDefaults.standard.string(forKey: "segmentAt5")
                         self.saveLoadItems()
                     }
        
                     let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                     }
             
             if self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect != "first" { alert.addAction(first) }
             if self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect != "second" { alert.addAction(second) }
             if self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect != "third" { alert.addAction(third) }
             if self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect != "fourth" { alert.addAction(fourth) }
             if self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect != "fifth" { alert.addAction(fifth) }
             
             if self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect != "" {
                 let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                     // what will happen once user clicks the add item button on UIAlert
                     self.sn.itemArray[self.hiddenItemArray[indexPath.row]].labelDetect = ""
                     self.sn.itemArray[self.hiddenItemArray[indexPath.row]].label = ""
                     self.saveLoadItems()
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
            
             self.sn.itemArray[self.hiddenItemArray[indexPath.row]].isHiddenn = 0
             self.saveLoadItems()

         })
         unhideAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "unhide")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        unhideAction.backgroundColor = UIColor(named: "colorGray")

         return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction, unhideAction])
    }
    
    
    //MARK: - Cell Right Swipe
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //edit-
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.hiddenItemArray[indexPath.row]
            let textEdit = self.sn.itemArray[self.hiddenItemArray[indexPath.row]].note
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
            self.editIndex = self.hiddenItemArray[indexPath.row]
            
            let lastNote = self.sn.itemArray[self.hiddenItemArray[indexPath.row]].lastNote
            UserDefaults.standard.set(lastNote, forKey: "lastNote")
            
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        lastNoteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "return")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        lastNoteAction.backgroundColor = UIColor(named: "colorPurple")
        
        //copy-
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(self.sn.itemArray[self.hiddenItemArray[indexPath.row]].note ?? "nothing")
            success(true)
        })
        copyAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "copy")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        copyAction.backgroundColor = UIColor(named: "colorYellow")
        
        if (sn.itemArray[hiddenItemArray[indexPath.row]].isEdited) == 0 {
            return UISwipeActionsConfiguration(actions: [editAction, copyAction])
        } else {
            return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
        }
    }
}

//MARK: - dismiss keyboard when user tap around
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
