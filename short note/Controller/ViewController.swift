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
    
    var selectedSegmentIndex = 0
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    var numberForSearchBar = 0
    var numberSegment0Search = 0
    
    var sn = ShortNote()
    var itemArray = [Item]()
    var tempArray = [Int]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        updateBgColor()
        hideKeyboardWhenTappedAround()
        loadItems()
        changeSearchBarPlaceholder()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedSegmentIndex = 0
        goEdit = 0
        updateSearchBarAndSegmentedControl()
        setSegmentedControl()
        UserDefaults.standard.set(0, forKey: "selectedSegmentIndex")
        tableView.reloadData()
    }
    
    //MARK: - setup
    func setupView(){
        
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
        
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchNote") == 1 {
            
        } else {
            performSegue(withIdentifier: "goAdd", sender: self)
        }
        
        //delete navigation bar background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        
        //it will run when user reopen the app after pressing home button
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateView), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        segmentView.layer.cornerRadius = 10
    }//setupView

    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goAdd", sender: self)
    }
    
    func setSegmentedControl() {
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt1"), forSegmentAt: 1)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt2"), forSegmentAt: 2)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt3"), forSegmentAt: 3)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt4"), forSegmentAt: 4)
        segmentedControl.setTitle(UserDefaults.standard.string(forKey: "segmentAt5"), forSegmentAt: 5)
    }
    
    //MARK: - updateColors
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
    
    @objc func updateView() {
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchNote") == 1 {
            
        } else {
            performSegue(withIdentifier: "goAdd", sender: self)
        }
    }
    
    func updateSearchBarAndSegmentedControl(){
        // SearchBar text
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(CGFloat(textSize))

        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: CGFloat(textSize+4))!], for: .normal)
    }
    
    func updateBgColor() {
        
        let bgColor = UserDefaults.standard.integer(forKey: "bgColor")
        if bgColor == 5{
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "colorTextLight")!]
            leftBarButton.tintColor = UIColor(named: "colorTextLight")
            rightBarButton.tintColor =  UIColor(named: "colorTextLight")
        } else {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            leftBarButton.tintColor = .black
            rightBarButton.tintColor = .black
        }
            
        switch bgColor {
        case 0: //blue
            gradient.colors = [UIColor(red: 0.46, green: 0.62, blue: 0.80, alpha: 1.00).cgColor, UIColor(red: 0.73, green: 0.84, blue: 0.92, alpha: 1.00).cgColor]
            break
        case 1: //red
            gradient.colors = [UIColor(red: 0.73, green: 0.04, blue: 0.00, alpha: 1.00).cgColor, UIColor(red: 0.85, green: 0.46, blue: 0.42, alpha: 1.00).cgColor]
            break
        case 2: //green
            gradient.colors = [UIColor(red: 0.00, green: 0.57, blue: 0.40, alpha: 1.00).cgColor, UIColor(red: 0.00, green: 0.78, blue: 0.59, alpha: 1.00).cgColor]
            break
        case 3: //purple
            gradient.colors = [UIColor(red: 0.54, green: 0.22, blue: 0.88, alpha: 1.00).cgColor, UIColor(red: 0.71, green: 0.40, blue: 0.95, alpha: 1.00).cgColor]
            break
        case 4: //yellow
            gradient.colors = [UIColor(red: 1.00, green: 0.83, blue: 0.40, alpha: 1.00).cgColor, UIColor(red: 0.99, green: 1.00, blue: 0.66, alpha: 1.00).cgColor]
            break
        case 5: //black
            gradient.colors = [UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00).cgColor, UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00).cgColor]
            break
        case 6: //white
            gradient.colors = [UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00).cgColor, UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00).cgColor]
            break
        default:
            print("-#-")
        }
    }
    
    
    //MARK: - Delete all notes
    func deleteAllNotes() {
        let i = itemArray.count // itemArray.count will change
        for _ in 0..<i {
            self.context.delete(self.itemArray[0])
            self.itemArray.remove(at: 0)
        }
        self.saveItems()
        self.loadItems()
        self.numberForSearchBar = 0
        self.changeSearchBarPlaceholder()
        UserDefaults.standard.set(0, forKey: "deleteAllNotes")
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
    
    //MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goAdd" {
            let destinationVC = segue.destination as! AddViewController

            destinationVC.itemArray = itemArray
            destinationVC.modalPresentationStyle = .overFullScreen

            if segue.destination is AddViewController {
                (segue.destination as? AddViewController)?.onViewWillDisappear = {
                    self.numberForSearchBar = 0
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
        
        if segue.identifier == "goSettings" {
            if segue.destination is SettingsViewController {
                (segue.destination as? SettingsViewController)?.onViewWillDisappear = {
                    self.updateBgColor()
                    self.updateSearchBarAndSegmentedControl()
                    self.updateColors() // need for zero note count
                    self.setSegmentedControl()
                    self.numberForSearchBar = 0
                    self.loadItems()
                    if UserDefaults.standard.integer(forKey: "deleteAllNotes") == 1 {
                        self.deleteAllNotes()
                    }
                }
            }
        }
    }
        
    //MARK: - segmented control changed
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
        numberForSearchBar = 0
        tableView.reloadData()
    }
    

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {

        if sender.direction == .right {
             performSegue(withIdentifier: "goSettings", sender: self)
        }
        
        if sender.direction == .left {
            performSegue(withIdentifier: "goAdd", sender: self)
        }
    }
}

//MARK: - searchbar
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text!.count > 0 {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
            loadItems(with: request)
        }
        else {
            numberForSearchBar = 0
            loadItems()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            numberForSearchBar = 0
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func changeSearchBarPlaceholder(){
  
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

//MARK: - show words
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if itemArray.count == 0 {updateColors()}
        if selectedSegmentIndex != 0 && tempArray.count == 0 { updateColors() }
        
        tempArray = tArray()
        changeSearchBarPlaceholder()
        
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
        
        // 1 is false, 0 is true
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
        
        changeSearchBarPlaceholder()
        
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            cell.engView.backgroundColor = UIColor(named: "colorCellDark")
            cell.engLabel.textColor = UIColor(named: "colorTextLight")
            updateColors()
        } else {
            cell.engView.backgroundColor = UIColor(named: "colorCellLight")
            cell.engLabel.textColor = UIColor(named: "colorTextDark")
            updateColors()
        }
        
        // print notes
        switch selectedSegmentIndex {
        case 0:
            cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
            cell.label.text = itemArray[tempArray[indexPath.row]].label
            break
        case 1:
            cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
            cell.label.text = UserDefaults.standard.string(forKey: "segmentAt1")
            break
        case 2:
            cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
            cell.label.text = UserDefaults.standard.string(forKey: "segmentAt2")
            break
        case 3:
            cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
            cell.label.text = UserDefaults.standard.string(forKey: "segmentAt3")
            break
        case 4:
            cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
            cell.label.text = UserDefaults.standard.string(forKey: "segmentAt4")
            break
        default:
            cell.engLabel.text = itemArray[tempArray[indexPath.row]].note
            cell.label.text = UserDefaults.standard.string(forKey: "segmentAt5")
        }
        
        if UserDefaults.standard.integer(forKey: "invisible") == 1 {
            cell.engView.isHidden = true
        } else {
            cell.engView.isHidden = false
        }
        
        if UserDefaults.standard.integer(forKey: "switchShowLabel") == 1 {
            cell.label.text = ""
        }
        
        cell.label.font = cell.label.font.withSize(CGFloat(tagSize))
        
        cell.engLabel.font = cell.engLabel.font.withSize(CGFloat(textSize))
        
        cell.dateLabel.font = cell.dateLabel.font.withSize(CGFloat(textSize-4))
           
        return cell
    }
    
    //MARK: - tArray
    func tArray() -> Array<Int> {
        
        var tArray = [Int]()
        
        for i in 0..<itemArray.count {
            // how many cell should return different tag
            if itemArray[i].isHiddenn == 0 && itemArray[i].isDeletedd == 0 {
                switch selectedSegmentIndex {
                case 0:
                    tArray = tArrayAppend(i, tArray)
                case 1:
                    if itemArray[i].labelDetect == "first" { tArray = tArrayAppend(i, tArray) }
                    break
                case 2:
                    if itemArray[i].labelDetect == "second" { tArray = tArrayAppend(i, tArray) }
                    break
                case 3:
                    if itemArray[i].labelDetect == "third" { tArray = tArrayAppend(i, tArray) }
                    break
                case 4:
                    if itemArray[i].labelDetect == "fourth" { tArray = tArrayAppend(i, tArray) }
                    break
                default:
                    if itemArray[i].labelDetect == "fifth" { tArray = tArrayAppend(i, tArray) }
                }
            }
        }
        return tArray
    }
    
    func tArrayAppend(_ i:Int, _ tArray: Array<Int>)  -> Array<Int> {
        
        var tArrayForAppend = tArray
        
        let allNotes = UserDefaults.standard.integer(forKey: "allNotes")
        
        switch allNotes {
            case 0:
                segmentedControl.setTitle("All", forSegmentAt: 0)
                tArrayForAppend.append(i)
            case 1:
                segmentedControl.setTitle("10", forSegmentAt: 0)
                if tArray.count < 10 {
                    tArrayForAppend.append(i)
                } else {
                    return tArrayForAppend
                }
            case 2:
                segmentedControl.setTitle("100", forSegmentAt: 0)
                if tArray.count < 100 {
                    tArrayForAppend.append(i)
                } else {
                    return tArrayForAppend
                }
            default:
                segmentedControl.setTitle("1000", forSegmentAt: 0)
                if tArray.count < 1000 {
                    tArrayForAppend.append(i)
                } else {
                    return tArrayForAppend
                }
        }
        return tArrayForAppend
    }
}



//MARK: - remove word
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //trailingSwipeActionsConfigurationForRowAt
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
                    self.itemArray[self.tempArray[indexPath.row]].deleteDate = Date()
                    self.itemArray[self.tempArray[indexPath.row]].hideStatusBeforeDelete = self.itemArray[self.tempArray[indexPath.row]].isHiddenn
                    self.saveLoadItemsUpdateSearchBar()
                    self.dismiss(animated: true, completion: nil)
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
                self.itemArray[self.tempArray[indexPath.row]].deleteDate = Date()
                self.itemArray[self.tempArray[indexPath.row]].hideStatusBeforeDelete = self.itemArray[self.tempArray[indexPath.row]].isHiddenn
                self.saveLoadItemsUpdateSearchBar()
                                
                self.dismiss(animated: true, completion: nil)
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
         
         //hide-
         let hideAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

             self.itemArray[self.tempArray[indexPath.row]].isHiddenn = 1
             self.saveLoadItemsUpdateSearchBar()

         })
         hideAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
             UIImage(named: "hide")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
         hideAction.backgroundColor = UIColor(named: "colorGray")
         
         
         if UserDefaults.standard.integer(forKey: "invisible") == 0 {
             return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction, hideAction])
         }
         return UISwipeActionsConfiguration(actions: [])
    }
    
    func saveLoadItemsUpdateSearchBar(){
        saveItems()
        loadItems()
        numberForSearchBar = 0
        changeSearchBarPlaceholder()
    }
    
    //MARK: - Edit
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        
        //edit-
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.tempArray[indexPath.row]
            let textEdit = self.itemArray[self.tempArray[indexPath.row]].note
            UserDefaults.standard.set(textEdit, forKey: "textEdit")
            self.numberForSearchBar = 0
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
            
            self.numberForSearchBar = 0
            self.performSegue(withIdentifier: "goAdd", sender: self)
            success(true)
        })
        lastNoteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: "return")?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
        lastNoteAction.backgroundColor = UIColor(named: "colorPurple")
        
        //copy-
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(self.itemArray[self.tempArray[indexPath.row]].note ?? "nothing")
          
            let alert = UIAlertController(title: "Copied to clipboard", message: "", preferredStyle: .alert)
            
            // dismiss alert after 1 second
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
            if (itemArray[tempArray[indexPath.row]].isEdited) == 0 {
                return UISwipeActionsConfiguration(actions: [editAction, copyAction])
            } else {
                return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
            }
        }
        return UISwipeActionsConfiguration(actions: [])
    }
}

//MARK: - simple extensions
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

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
