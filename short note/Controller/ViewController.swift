//
//  ViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//
import UIKit
import CoreData

class ViewController: UIViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    //MARK: - Globals
    
    var sn = ShortNote()
    var tempArray = [Int]()
    
    var selectedSegmentIndex = 0
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    
    let gradient = CAGradientLayer()
    
    // MARK: -  UserDefaults
    
    var tagSize : CGFloat = 0.0
    var textSize : CGFloat = 0.0
    var imageSize : CGFloat = 0.0
    var segmentAt1 : String = ""
    var segmentAt2 : String = ""
    var segmentAt3 : String = ""
    var segmentAt4 : String = ""
    var segmentAt5 : String = ""
    

    // MARK: - Color Themes
    
    private var currentTheme: ShortNoteTheme {
        return ThemeManager.shared.currentTheme
    }
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        assignUserDefaults()
        updateColors()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        
        sn.loadItems()
        hideKeyboardWhenTappedAround()
        addThemeGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        selectedSegmentIndex = 0
        goEdit = 0
        setSearchBar(searchBar, textSize)
        setSegmentedControl()
        sn.setValue(0, sn.selectedSegmentIndex)
        tableView.reloadData()
    }
    
    //MARK: - GestureRecognizer
    
    private func addThemeGestureRecognizer(){
        let themeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.themeGestureRecognizerDidTap(_:)))
        themeGestureRecognizer.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(themeGestureRecognizer)
    }

    @objc private func themeGestureRecognizerDidTap(_ gesture: UITapGestureRecognizer) {
        print("user tap double")
        ThemeManager.shared.moveToNextTheme()
        tableView.reloadData()
        updateColors()
    }
    
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
                    self.assignUserDefaults()
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
        
        sn.setValue(sender.selectedSegmentIndex, sn.selectedSegmentIndex)
        selectedSegmentIndex = sender.selectedSegmentIndex
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
        if sn.getIntValue(sn.switchNote) == 1 {
            performSegue(withIdentifier: "goAdd", sender: self)
        }
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
    
    func setupView(){
        
        segmentView.layer.cornerRadius = 10

        if UserDefaults.standard.string(forKey: sn.selectedTimeFormat) == nil {
            sn.setValue(sn.defaultEmojies[0], sn.segmentAt1)
            sn.setValue(sn.defaultEmojies[1], sn.segmentAt2)
            sn.setValue(sn.defaultEmojies[2], sn.segmentAt3)
            sn.setValue(sn.defaultEmojies[3], sn.segmentAt4)
            sn.setValue(sn.defaultEmojies[4], sn.segmentAt5)
            sn.setValue(15, sn.textSize)
            sn.setValue(10, sn.tagSize)
            sn.setValue(1, sn.switchNote)
            sn.setValue(1, sn.switchShowDate)
            sn.setValue(0, sn.showHour)
            sn.setValue(1, sn.switchShowLabel)
            sn.setValue("EEEE, d MMM yyyy", sn.selectedDateFormat)
            sn.setValue("hh:mm a", sn.selectedHourFormat)
            sn.setValue("EEEE, d MMM yyyy", sn.selectedTimeFormat)
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
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        gradient.colors = [UIColor(hex: currentTheme.backgroundColor)!.cgColor, UIColor(hex: currentTheme.backgroundColorBottom)!.cgColor]
        
        if sn.getIntValue(sn.darkMode) == 1 {
            tableView.backgroundColor = UIColor(hex: ThemeManager.shared.darkTheme.tableViewColor)
            searchBar.barTintColor = UIColor(hex: ThemeManager.shared.darkTheme.searhcBarColor)
            segmentedControl.backgroundColor = UIColor(hex: ThemeManager.shared.darkTheme.segmentedControlColor)
            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = UIColor(hex: "#d6d6d6")
                searchBar.searchTextField.textColor = UIColor(hex: ThemeManager.shared.darkTheme.textColor)
                overrideUserInterfaceStyle = .dark
                let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
            }
        } else {
            tableView.backgroundColor = UIColor(hex: currentTheme.tableViewColor)
            searchBar.barTintColor = UIColor(hex: currentTheme.searhcBarColor)
            segmentedControl.backgroundColor = UIColor(hex: currentTheme.segmentedControlColor)
            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = UIColor.white
                searchBar.searchTextField.textColor = UIColor(hex: currentTheme.textColor)
                overrideUserInterfaceStyle = .light
            }
        }
        updateNavigationBar()
    }

    func updateNavigationBar(){
        switch currentTheme.statusBarStyle {
        case .light:
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            leftBarButton.tintColor = UIColor.white
            rightBarButton.tintColor =  UIColor.white
            //segmented control All color 
            if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .dark }
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)

        case .dark:
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            leftBarButton.tintColor = .black
            rightBarButton.tintColor = .black
        }
    }

    
    func setSegmentedControl() {
        
        segmentedControl.setTitle(segmentAt1, forSegmentAt: 1)
        segmentedControl.setTitle(segmentAt2, forSegmentAt: 2)
        segmentedControl.setTitle(segmentAt3, forSegmentAt: 3)
        segmentedControl.setTitle(segmentAt4, forSegmentAt: 4)
        segmentedControl.setTitle(segmentAt5, forSegmentAt: 5)
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: textSize+4)!], for: .normal)
    }
    
    func saveLoadItems(){
        
        sn.saveItems()
        sn.loadItems()
        tableView.reloadData()
    }

}

//MARK: - Search Bar
extension ViewController: UISearchBarDelegate {
    
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
            item.label = segmentAt1
            break
        case "second":
            item.label = segmentAt2
            break
        case "third":
            item.label = segmentAt3
            break
        case "fourth":
            item.label = segmentAt4
            break
        case "fifth":
            item.label = segmentAt5
            break
        default:
            item.label = " "
        }
        
        sn.saveItems()
        
        cell.noteLabel.text = item.note
        cell.tagLabel.text = item.label
        cell.dateLabel.text = item.date?.getFormattedDate(format: sn.getStringValue(sn.selectedTimeFormat))
        
        if sn.getIntValue(sn.darkMode) == 1 {
            cell.noteView.backgroundColor = UIColor(named: "colorCellDark")
            cell.noteLabel.textColor = UIColor(named: "colorTextLight")
            updateColors()
        } else {
            cell.noteView.backgroundColor = UIColor(hex: currentTheme.cellColor)
            cell.noteLabel.textColor = UIColor(hex: currentTheme.textColor)
            updateColors()
        }
        
        if sn.getIntValue(sn.switchShowLabel) == 0 { cell.tagLabel.text = "" }
        cell.tagLabel.font = cell.tagLabel.font.withSize(tagSize)
        cell.noteLabel.font = cell.noteLabel.font.withSize(textSize)
        cell.dateLabel.font = cell.dateLabel.font.withSize(textSize-4)
           
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
            let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
                        item.labelDetect = "first"
                        item.label = self.segmentAt1
                        self.saveLoadItems()
                    }
                    let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
                        item.labelDetect = "second"
                        item.label = self.segmentAt2
                        self.saveLoadItems()
                    }
                    let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
                        item.labelDetect = "third"
                        item.label = self.segmentAt3
                        self.saveLoadItems()
                    }
                    let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
                        item.labelDetect = "fourth"
                        item.label = self.segmentAt4
                        self.saveLoadItems()
                    }
                    let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
                        item.labelDetect = "fifth"
                        item.label = self.segmentAt5
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
         
         
        return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction, hideAction])
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
            self.editIndex = self.tempArray[indexPath.row]
            
            let lastNote = item.lastNote
            self.sn.setValue(lastNote ?? "", self.sn.lastNote)
            
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
        
            if (item.isEdited) == 0 {
                return UISwipeActionsConfiguration(actions: [editAction, copyAction])
            } else {
                return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
            }
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
