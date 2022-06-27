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
    
    //UserDefaults
    var tagSize : CGFloat = 0.0
    var textSize : CGFloat = 0.0
    var imageSize : CGFloat = 0.0
    var darkMode : Int = 0
    var segmentAt1 : String = ""
    var segmentAt2 : String = ""
    var segmentAt3 : String = ""
    var segmentAt4 : String = ""
    var segmentAt5 : String = ""
    
    override func viewDidLoad() {
        
        assignUserDefaults()
        
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
    
    func assignUserDefaults(){
        
        tagSize = sn.getCGFloatValue(sn.tagSize)
        textSize = sn.getCGFloatValue(sn.textSize)
        imageSize = sn.getCGFloatValue(sn.textSize) + 5
        darkMode = sn.getIntValue(sn.darkMode)
        segmentAt1 = sn.getStringValue(sn.segmentAt1)
        segmentAt2 = sn.getStringValue(sn.segmentAt2)
        segmentAt3 = sn.getStringValue(sn.segmentAt3)
        segmentAt4 = sn.getStringValue(sn.segmentAt4)
        segmentAt5 = sn.getStringValue(sn.segmentAt5)
    }
    
    func updateColors() {
        
        if darkMode == 1 {
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
    
    func setSearchBar(_ searchBar: UISearchBar, _ textSize: CGFloat){
        
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(textSize)

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
        
        let hiddenItem = sn.itemArray[hiddenItemArray[indexPath.row]]
        
        switch hiddenItem.labelDetect {
        case "first":
            hiddenItem.label = segmentAt1
            break
        case "second":
            hiddenItem.label = segmentAt2
            break
        case "third":
            hiddenItem.label = segmentAt3
            break
        case "fourth":
            hiddenItem.label = segmentAt4
            break
        case "fifth":
            hiddenItem.label = segmentAt5
            break
        default:
            hiddenItem.label = " "
        }
        
        sn.saveItems()
        
        cell.noteLabel.text = hiddenItem.note
        cell.tagLabel.text = hiddenItem.label
        
        if sn.getIntValue(sn.switchShowDate) == 0 {
            if sn.getIntValue(sn.showHour) == 1 {
                cell.dateLabel.text = hiddenItem.date?.getFormattedDate(format: "hh:mm a")
            } else {
                cell.dateLabel.text = ""
            }
        } else {
            cell.dateLabel.text = hiddenItem.date?.getFormattedDate(format: sn.getStringValue(sn.selectedDateFormat))
        }
        
        if darkMode == 1 {
            cell.noteView.backgroundColor = UIColor(named: "colorCellDark")
            cell.noteLabel.textColor = UIColor(named: "colorTextLight")
            updateColors()
        } else {
            cell.noteView.backgroundColor = UIColor(named: "colorCellLight")
            cell.noteLabel.textColor = UIColor(named: "colorTextDark")
            updateColors()
        }
        
        if sn.getIntValue(sn.switchShowLabel) == 0 { cell.tagLabel.text = "" }
        cell.tagLabel.font = cell.tagLabel.font.withSize(tagSize)
        cell.noteLabel.font = cell.noteLabel.font.withSize(textSize)
        cell.dateLabel.font = cell.dateLabel.font.withSize(textSize-4)

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
        
        let hiddenItem = self.sn.itemArray[self.hiddenItemArray[indexPath.row]]
         
         //delete-
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
       
                hiddenItem.isDeletedd = 1
                hiddenItem.hideStatusBeforeDelete = hiddenItem.isHiddenn
             
                hiddenItem.isHiddenn = 0
                hiddenItem.deleteDate = Date()
                self.saveLoadItems()
            success(true)
        })
         deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "thrash")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
         deleteAction.backgroundColor = UIColor.red
         
         //tag-
         let favoriteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                     let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
             let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
                         hiddenItem.labelDetect = "first"
                 hiddenItem.label = self.segmentAt1
                         self.saveLoadItems()
                     }
             let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
                         hiddenItem.labelDetect = "second"
                 hiddenItem.label = self.segmentAt2
                         self.saveLoadItems()
                     }
             let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
                         hiddenItem.labelDetect = "third"
                 hiddenItem.label = self.segmentAt3
                         self.saveLoadItems()
                     }
             let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
                         hiddenItem.labelDetect = "fourth"
                 hiddenItem.label = self.segmentAt4
                         self.saveLoadItems()
                     }
             let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
                         hiddenItem.labelDetect = "fifth"
                 hiddenItem.label = self.segmentAt5
                         self.saveLoadItems()
                     }
        
                     let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
             
             if hiddenItem.labelDetect != "first" { alert.addAction(first) }
             if hiddenItem.labelDetect != "second" { alert.addAction(second) }
             if hiddenItem.labelDetect != "third" { alert.addAction(third) }
             if hiddenItem.labelDetect != "fourth" { alert.addAction(fourth) }
             if hiddenItem.labelDetect != "fifth" { alert.addAction(fifth) }
             
             if hiddenItem.labelDetect != "" {
                 let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                     hiddenItem.labelDetect = ""
                     hiddenItem.label = ""
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
            
             hiddenItem.isHiddenn = 0
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
        
        let hiddenItem = self.sn.itemArray[self.hiddenItemArray[indexPath.row]]
        
        //edit-
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.hiddenItemArray[indexPath.row]
            let textEdit = hiddenItem.note
            self.sn.setValue(textEdit ?? "", self.sn.textEdit)
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
            
            let lastNote = hiddenItem.lastNote
            self.sn.setValue(lastNote ?? "", self.sn.lastNote)
            
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        lastNoteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "return")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        lastNoteAction.backgroundColor = UIColor(named: "colorPurple")
        
        //copy-
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(hiddenItem.note ?? "nothing")
            success(true)
        })
        copyAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "copy")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        copyAction.backgroundColor = UIColor(named: "colorYellow")
        
        if (hiddenItem.isEdited) == 0 {
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
