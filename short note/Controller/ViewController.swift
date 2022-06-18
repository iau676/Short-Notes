//
//  ViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//
import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var sn = ShortNote()
    var tempArray = [Int]()
    
    var selectedSegmentIndex = 0
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    
    let gradient = CAGradientLayer()
    
    let tagSize = UserDefaults.standard.integer(forKey: "tagSize")
    let textSize = UserDefaults.standard.integer(forKey: "textSize")
    let imageSize = UserDefaults.standard.integer(forKey: "textSize") + 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Short Notes"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        
        updateColors()
        gradient.colors = [UIColor(red: 0.46, green: 0.62, blue: 0.80, alpha: 1.00).cgColor, UIColor(red: 0.73, green: 0.84, blue: 0.92, alpha: 1.00).cgColor]
        
        hideKeyboardWhenTappedAround()
        sn.loadItems()
        setupView()
       // addThemeGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedSegmentIndex = 0
        goEdit = 0
        setSearchBar(searchBar, textSize)
        setSegmentedControl()
        UserDefaults.standard.set(0, forKey: "selectedSegmentIndex")
        tableView.reloadData()
    }
    
//    private func addThemeGestureRecognizer(){
//        let themeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.themeGestureRecognizerDidTap(_:)))
//        themeGestureRecognizer.numberOfTapsRequired = 2
//        mainView.addGestureRecognizer(themeGestureRecognizer)
//    }
//
//    @objc private func themeGestureRecognizerDidTap(_ gesture: UITapGestureRecognizer) {
//        print("user tap double")
//    }
    
    //MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goAdd" {
            let destinationVC = segue.destination as! AddViewController

            destinationVC.modalPresentationStyle = .overFullScreen

            if segue.destination is AddViewController {
                (segue.destination as? AddViewController)?.onViewWillDisappear = {
                    self.sn.saveItems()
                    self.sn.loadItems()
                    self.tableView.reloadData()
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
        
        if segue.identifier == "goSettings" {
            if segue.destination is SettingsViewController {
                (segue.destination as? SettingsViewController)?.onViewWillDisappear = {
                    self.setSearchBar(self.searchBar, self.textSize)
                    self.updateColors()
                    self.setSegmentedControl()
                    self.sn.loadItems()
                    self.tableView.reloadData()
                }
            }
        }
    }

    //MARK: - IBAction
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goAdd", sender: self)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
        tableView.reloadData()
    }

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .right:
            performSegue(withIdentifier: "goSettings", sender: self)
        case .left:
            performSegue(withIdentifier: "goAdd", sender: self)
        default: break
        }
    }
    
    //MARK: - Objc Functions
    
    @objc func goAddPageIfNeed() {
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchNote") == 0 {
            performSegue(withIdentifier: "goAdd", sender: self)
        }
    }
    
    //MARK: - Other Functions
    
    func setupView(){
        
        segmentView.layer.cornerRadius = 10
        
        if UserDefaults.standard.integer(forKey: "textSize") == 0 {
            UserDefaults.standard.set(15, forKey: "textSize")
        }

        if UserDefaults.standard.string(forKey: "segmentAt1") == nil {
            UserDefaults.standard.set("⭐️", forKey: "segmentAt1")
            UserDefaults.standard.set("📚", forKey: "segmentAt2")
            UserDefaults.standard.set("🥰", forKey: "segmentAt3")
            UserDefaults.standard.set("🌸", forKey: "segmentAt4")
            UserDefaults.standard.set("🐼", forKey: "segmentAt5")
        }

        gradient.frame = view.bounds
        mainView.layer.insertSublayer(gradient, at: 0)
        
        goAddPageIfNeed()
        
        //delete navigation bar background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        
        //it will run when user reopen the app after pressing home button
        NotificationCenter.default.addObserver(self, selector: #selector(self.goAddPageIfNeed), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func updateColors() {
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            tableView.backgroundColor = UIColor(named: "colorCellDark")
            searchBar.barTintColor = UIColor(named: "colorCellDark")
            segmentedControl.backgroundColor = UIColor(named: "colorCellDark")
            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = UIColor(named: "colord6d6d6")
                searchBar.searchTextField.textColor = UIColor(named: "colorCellLight")
                overrideUserInterfaceStyle = .dark
                let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
            } else {
                // Fallback on earlier versions
            }
        } else {
            tableView.backgroundColor = UIColor(named: "colorCellLight")
            searchBar.barTintColor = UIColor(named: "colorCellLight")
            segmentedControl.backgroundColor = UIColor(named: "colorCellLight")
            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = UIColor.white
                searchBar.searchTextField.textColor = UIColor(named: "colorCellDark")
                overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func setSegmentedControl() {
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt1"), forSegmentAt: 1)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt2"), forSegmentAt: 2)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt3"), forSegmentAt: 3)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt4"), forSegmentAt: 4)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt5"), forSegmentAt: 5)
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: CGFloat(textSize+4))!], for: .normal)
    }
    
    func saveLoadItems(){
        sn.saveItems()
        sn.loadItems()
        tableView.reloadData()
    }

}

//MARK: - Search Bar
extension ViewController: UISearchBarDelegate {
    
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
        }
        else {
            sn.loadItems()
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            sn.loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func updateSearchBarPlaceholder(){
  
        if selectedSegmentIndex == 0 {
            if tempArray.count > 0 {
                searchBar.placeholder = (tempArray.count == 1 ? "Search in \(tempArray.count) note" : "Search in \(tempArray.count) notes")
            } else {
                searchBar.placeholder = "You can add note using the + sign"
            }
        } else {
            if tempArray.count > 0 {
                searchBar.placeholder = (tempArray.count == 1 ? "Search in \(tempArray.count) note" : "Search in \(tempArray.count) notes")
            } else {
                searchBar.placeholder = "Nothing see here"
            }
        }
    }
}

//MARK: - Show Words
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if sn.itemArray.count == 0 {updateColors()}
        if selectedSegmentIndex != 0 && tempArray.count == 0 {updateColors()}
        
        tempArray = tArray()
        updateSearchBarPlaceholder()

        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! NoteCell
        
        let item = sn.itemArray[tempArray[indexPath.row]]

        switch item.labelDetect {
        case "first":
            item.label = UserDefaults.standard.string(forKey: "segmentAt1")
            break
        case "second":
            item.label = UserDefaults.standard.string(forKey: "segmentAt2")
            break
        case "third":
            item.label = UserDefaults.standard.string(forKey: "segmentAt3")
            break
        case "fourth":
            item.label = UserDefaults.standard.string(forKey: "segmentAt4")
            break
        case "fifth":
            item.label = UserDefaults.standard.string(forKey: "segmentAt5")
            break
        default:
            item.label = " "
        }
        
        sn.saveItems()
        
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchShowDate") == 1 {
            // 1 is true, 0 is false
            if UserDefaults.standard.integer(forKey: "showHour") == 1 {
                cell.dateLabel.text = item.date?.getFormattedDate(format: "hh:mm a")
            } else {
                cell.dateLabel.text = ""
            }
        } else {
            cell.dateLabel.text = item.date?.getFormattedDate(format: UserDefaults.standard.string(forKey: "selectedDateFormat") ?? "EEEE, MMM d, yyyy")
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
        
        switch selectedSegmentIndex {
        case 0:
            cell.noteLabel.text = item.note
            cell.tagLabel.text = item.label
            break
        case 1:
            cell.noteLabel.text = item.note
            cell.tagLabel.text = UserDefaults.standard.string(forKey: "segmentAt1")
            break
        case 2:
            cell.noteLabel.text = item.note
            cell.tagLabel.text = UserDefaults.standard.string(forKey: "segmentAt2")
            break
        case 3:
            cell.noteLabel.text = item.note
            cell.tagLabel.text = UserDefaults.standard.string(forKey: "segmentAt3")
            break
        case 4:
            cell.noteLabel.text = item.note
            cell.tagLabel.text = UserDefaults.standard.string(forKey: "segmentAt4")
            break
        default:
            cell.noteLabel.text = item.note
            cell.tagLabel.text = UserDefaults.standard.string(forKey: "segmentAt5")
        }
        
        if UserDefaults.standard.integer(forKey: "switchShowLabel") == 1 {
            cell.tagLabel.text = ""
        }
        
        cell.tagLabel.font = cell.tagLabel.font.withSize(CGFloat(tagSize))
        
        cell.noteLabel.font = cell.noteLabel.font.withSize(CGFloat(textSize))
        
        cell.dateLabel.font = cell.dateLabel.font.withSize(CGFloat(textSize-4))
           
        return cell
    }
    
    //MARK: - tArray
    func tArray() -> Array<Int> {
        
        var tArray = [Int]()
        
        for i in 0..<sn.itemArray.count {
            // how many cell should return different tag
            if sn.itemArray[i].isHiddenn == 0 && sn.itemArray[i].isDeletedd == 0 {
                switch selectedSegmentIndex {
                case 0:
                    tArray.append(i)
                case 1:
                    if sn.itemArray[i].labelDetect == "first" { tArray.append(i) }
                    break
                case 2:
                    if sn.itemArray[i].labelDetect == "second" { tArray.append(i) }
                    break
                case 3:
                    if sn.itemArray[i].labelDetect == "third" { tArray.append(i) }
                    break
                case 4:
                    if sn.itemArray[i].labelDetect == "fourth" { tArray.append(i) }
                    break
                default:
                    if sn.itemArray[i].labelDetect == "fifth" { tArray.append(i) }
                }
            }
        }
        return tArray
    }
    
}



//MARK: - Cell Swipe
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Cell Right Swipe
     func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         
         let item = self.sn.itemArray[self.tempArray[indexPath.row]]
         
         //delete-
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
           
                item.isDeletedd = 1
                item.deleteDate = Date()
                item.hideStatusBeforeDelete = item.isHiddenn
                self.saveLoadItems()
                                
                self.dismiss(animated: true, completion: nil)
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
                        item.labelDetect = "first"
                        item.label = UserDefaults.standard.string(forKey: "segmentAt1")
                        self.saveLoadItems()
                    }
                    let second = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt2"), style: .default) { (action) in
                        item.labelDetect = "second"
                        item.label = UserDefaults.standard.string(forKey: "segmentAt2")
                        self.saveLoadItems()
                    }
                    let third = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt3"), style: .default) { (action) in
                        item.labelDetect = "third"
                        item.label = UserDefaults.standard.string(forKey: "segmentAt3")
                        self.saveLoadItems()
                    }
                    let fourth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt4"), style: .default) { (action) in
                        item.labelDetect = "fourth"
                        item.label = UserDefaults.standard.string(forKey: "segmentAt4")
                        self.saveLoadItems()
                    }
                    let fifth = UIAlertAction(title: UserDefaults.standard.string(forKey: "segmentAt5"), style: .default) { (action) in
                        item.labelDetect = "fifth"
                        item.label = UserDefaults.standard.string(forKey: "segmentAt5")
                        self.saveLoadItems()
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    }
            
            if item.labelDetect != "first" { alert.addAction(first) }
            if item.labelDetect != "second" { alert.addAction(second) }
            if item.labelDetect != "third" { alert.addAction(third) }
            if item.labelDetect != "fourth" { alert.addAction(fourth) }
            if item.labelDetect != "fifth" { alert.addAction(fifth) }
            
            if item.labelDetect != "" {
                let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                    // what will happen once user clicks the add item button on UIAlert
                    item.labelDetect = ""
                    item.label = ""
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
         
         //hide-
         let hideAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

             item.isHiddenn = 1
             self.saveLoadItems()

         })
         hideAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "hide")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
         hideAction.backgroundColor = UIColor(named: "colorGray")
         
         
         if UserDefaults.standard.integer(forKey: "invisible") == 0 {
             return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction, hideAction])
         }
         return UISwipeActionsConfiguration(actions: [])
    }
    

    
    //MARK: - Cell Left Swipe
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let item = self.sn.itemArray[self.tempArray[indexPath.row]]
        
        //edit-
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.tempArray[indexPath.row]
            let textEdit = item.note
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
            
            let lastNote = item.lastNote
            UserDefaults.standard.set(lastNote, forKey: "lastNote")
            
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        lastNoteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "return")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        lastNoteAction.backgroundColor = UIColor(named: "colorPurple")
        
        //copy-
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(item.note ?? "nothing")
          
            let alert = UIAlertController(title: "Copied to clipboard", message: "", preferredStyle: .alert)
            
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
            
            self.present(alert, animated: true, completion: nil)
            success(true)
        })
        copyAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "copy")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        copyAction.backgroundColor = UIColor(named: "colorYellow")
        
        if UserDefaults.standard.integer(forKey: "invisible") == 0 {
            if (item.isEdited) == 0 {
                return UISwipeActionsConfiguration(actions: [editAction, copyAction])
            } else {
                return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
            }
        }
        return UISwipeActionsConfiguration(actions: [])
    }
}

//MARK: - dismiss keyboard when user tap around

extension ViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
