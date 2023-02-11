//
//  ViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "NoteCell"

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let segmentedControl = UISegmentedControl()
    
    var sn = ShortNote()
    var tempArray = [Int]()
    let gradient = CAGradientLayer()
    
    var selectedSegmentIndex = 0
    var goEdit = 0
    var returnLastNote = 0
    var editIndex = 0
    var editText = ""
    
    //UserDefaults
    var tagSize: CGFloat = 0.0
    var textSize: CGFloat = 0.0
    var imageSize: CGFloat = 0.0
    var segmentAt1: String = ""
    var segmentAt2: String = ""
    var segmentAt3: String = ""
    var segmentAt4: String = ""
    var segmentAt5: String = ""

    private var currentTheme: ShortNoteTheme {
        return ThemeManager.shared.currentTheme
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        assignUserDefaults()
        style()
        layout()
        
        updateColors()
        sn.loadItems()
        findWhichNotesShouldShow()
        hideKeyboardWhenTappedAround()
        addThemeGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedSegmentIndex = 0
        goEdit = 0
        setSearchBar(searchBar, textSize)
        setSegmentedControl()
        UDM.setValue(0, UDM.selectedSegmentIndex)
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradient.frame = view.layer.bounds
    }
    
    //MARK: - Gesture Recognizer
    
    private func addThemeGestureRecognizer(){
        let themeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.themeGestureRecognizerDidTap(_:)))
        themeGestureRecognizer.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(themeGestureRecognizer)
    }

    @objc private func themeGestureRecognizerDidTap(_ gesture: UITapGestureRecognizer) {
        ThemeManager.shared.moveToNextTheme()
        tableView.reloadData()
        updateColors()
    }

    //MARK: - Selectors

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            rightBarButtonPressed()
        case .left:
            rightBarButtonPressed()
        default: break
        }
    }
    
    @objc func goAddPageIfNeed() {
        if UDM.getIntValue(UDM.switchNote) == 1 {
            rightBarButtonPressed()
        }
    }
    
    @objc private func leftBarButtonPressed() {
        let controller = HiddenController()
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
    
    @objc private func rightBarButtonPressed() {
        let controller = AddController()
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        if goEdit == 1 {
            controller.goEdit = 1
            controller.editIndex = editIndex
        }
        if returnLastNote == 1 {
            controller.returnLastNote = 1
            controller.editIndex = editIndex
        }
        present(controller, animated: true)
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        UDM.setValue(sender.selectedSegmentIndex, UDM.selectedSegmentIndex)
        selectedSegmentIndex = sender.selectedSegmentIndex
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
    
    //MARK: - Helpers
    
    private func style() {
        configureNavigationBar()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        segmentedControl.setHeight(height: 50)
        segmentedControl.replaceSegments(segments: ["All", "", "", "", "", ""])
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: UIControl.Event.valueChanged)
    }
    
    private func layout() {
        let tableStack = UIStackView(arrangedSubviews: [searchBar, tableView])
        tableStack.spacing = 0
        tableStack.axis = .vertical
        
        let stack = UIStackView(arrangedSubviews: [tableStack, segmentedControl])
        stack.spacing = 16
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor,
                     paddingTop: 16, paddingLeft: 16, paddingBottom: 32, paddingRight: 16)
    }
    
    private func configureNavigationBar() {
        title = "Short Notes"
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let leftBarIV = UIImageView()
        leftBarIV.setDimensions(height: 20, width: 20)
        leftBarIV.layer.masksToBounds = true
        leftBarIV.isUserInteractionEnabled = true
        
        let rightBarIV = UIImageView()
        rightBarIV.setDimensions(height: 20, width: 20)
        rightBarIV.layer.masksToBounds = true
        rightBarIV.isUserInteractionEnabled = true
        
        if #available(iOS 13.0, *) {
            leftBarIV.image = UIImage(named: "menu")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            rightBarIV.image = UIImage(named: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        } else {
            leftBarIV.image = UIImage(named: "menu")
            rightBarIV.image = UIImage(named: "plus")
        }
        
        let tapLeft = UITapGestureRecognizer(target: self, action: #selector(leftBarButtonPressed))
        leftBarIV.addGestureRecognizer(tapLeft)
        
        let tapRight = UITapGestureRecognizer(target: self, action: #selector(rightBarButtonPressed))
        rightBarIV.addGestureRecognizer(tapRight)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarIV)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarIV)
    }
    
    func assignUserDefaults(){
        tagSize = UDM.getCGFloatValue(UDM.tagSize)
        textSize = UDM.getCGFloatValue(UDM.textSize)
        imageSize = UDM.getCGFloatValue(UDM.textSize) + 5
        segmentAt1 = UDM.getStringValue(UDM.segmentAt1)
        segmentAt2 = UDM.getStringValue(UDM.segmentAt2)
        segmentAt3 = UDM.getStringValue(UDM.segmentAt3)
        segmentAt4 = UDM.getStringValue(UDM.segmentAt4)
        segmentAt5 = UDM.getStringValue(UDM.segmentAt5)
    }
    
    func findWhichNotesShouldShow(){
        tempArray.removeAll()
        
        for i in 0..<sn.itemArray.count {
            if sn.itemArray[i].isHiddenn == 0 && sn.itemArray[i].isDeletedd == 0 {
                switch selectedSegmentIndex {
                case 0: tempArray.append(i)
                case 1: if sn.itemArray[i].label == segmentAt1 { tempArray.append(i) }
                case 2: if sn.itemArray[i].label == segmentAt2 { tempArray.append(i) }
                case 3: if sn.itemArray[i].label == segmentAt3 { tempArray.append(i) }
                case 4: if sn.itemArray[i].label == segmentAt4 { tempArray.append(i) }
                default:if sn.itemArray[i].label == segmentAt5 { tempArray.append(i) }
                }
            }
        }
    }
    
    func setupView(){
        if UserDefaults.standard.string(forKey: UDM.selectedTimeFormat) == nil {
            UDM.setValue(sn.defaultEmojies[0], UDM.segmentAt1)
            UDM.setValue(sn.defaultEmojies[1], UDM.segmentAt2)
            UDM.setValue(sn.defaultEmojies[2], UDM.segmentAt3)
            UDM.setValue(sn.defaultEmojies[3], UDM.segmentAt4)
            UDM.setValue(sn.defaultEmojies[4], UDM.segmentAt5)
            
            UDM.setValue(15, UDM.textSize)
            UDM.setValue(10, UDM.tagSize)
            UDM.setValue(0, UDM.switchNote)
            UDM.setValue(1, UDM.switchShowDate)
            UDM.setValue(0, UDM.showHour)
            UDM.setValue(1, UDM.switchShowLabel)
            UDM.setValue(1, UDM.isDefault)
            
            UDM.setValue("EEEE, d MMM yyyy", UDM.selectedDateFormat)
            UDM.setValue("hh:mm a", UDM.selectedHourFormat)
            UDM.setValue("EEEE, d MMM yyyy", UDM.selectedTimeFormat)
            
            sn.appendItem("Swipe -> Settings", sn.defaultEmojies[0])
            sn.appendItem("Swipe <- New Note", sn.defaultEmojies[4])
            sn.appendItem("Double click to change theme", sn.defaultEmojies[2])
        }

        view.layer.insertSublayer(gradient, at: 0)
        
        goAddPageIfNeed()
        
        //it will run when user reopen the app after pressing home button
        NotificationCenter.default.addObserver(self, selector: #selector(self.goAddPageIfNeed),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func updateColors() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        gradient.colors = [UIColor(hex: currentTheme.backgroundColor)!.cgColor,
                           UIColor(hex: currentTheme.backgroundColorBottom)!.cgColor]
        
        if UDM.getIntValue(UDM.darkMode) == 1 {
            tableView.backgroundColor = UIColor(hex: ThemeManager.shared.darkTheme.tableViewColor)
            searchBar.barTintColor = UIColor(hex: ThemeManager.shared.darkTheme.searhcBarColor)
            segmentedControl.backgroundColor = UIColor(hex: ThemeManager.shared.darkTheme.segmentedControlColor)
            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = Colors.d6d6d6
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
    }
    
    func setSegmentedControl() {
        segmentedControl.setTitle(segmentAt1, forSegmentAt: 1)
        segmentedControl.setTitle(segmentAt2, forSegmentAt: 2)
        segmentedControl.setTitle(segmentAt3, forSegmentAt: 3)
        segmentedControl.setTitle(segmentAt4, forSegmentAt: 4)
        segmentedControl.setTitle(segmentAt5, forSegmentAt: 5)
        
        segmentedControl.setTitleTextAttributes([.font: UIFont(name: Fonts.AvenirNextRegular,
                                                               size: textSize+4)!], for: .normal)
    }
    
    func refreshTable(){
        sn.saveItems()
        sn.loadItems()
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
}

//MARK: - Search Bar

extension HomeController: UISearchBarDelegate {
    
    func setSearchBar(_ searchBar: UISearchBar, _ textSize: CGFloat){
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(textSize)

        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            let request : NSFetchRequest<Note> = Note.fetchRequest()
            request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
            sn.loadItems(with: request)
        } else {
            sn.loadItems()
        }
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            sn.loadItems()
            findWhichNotesShouldShow()
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
                searchBar.placeholder = "Nothing to see here"
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension HomeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sn.itemArray.count == 0 {updateColors()}
        updateSearchBarPlaceholder()
        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        let note = sn.itemArray[tempArray[indexPath.row]]
        cell.note = note
        return cell
    }
}


//MARK: - UITableViewDelegate

extension HomeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.sn.itemArray[self.tempArray[indexPath.row]]
         
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            item.isDeletedd = 1
            item.deleteDate = Date()
            item.hideStatusBeforeDelete = item.isHiddenn
            self.refreshTable()
            self.dismiss(animated: true, completion: nil)
            success(true)
        })
        deleteAction.setImage(image: Images.thrash, width: imageSize, height: imageSize)
        deleteAction.setBackgroundColor(UIColor.red)
         
        let tagAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)
            
            let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
                item.label = self.segmentAt1
                self.refreshTable()
            }
            let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
                item.label = self.segmentAt2
                self.refreshTable()
            }
            let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
                item.label = self.segmentAt3
                self.refreshTable()
            }
            let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
                item.label = self.segmentAt4
                self.refreshTable()
            }
            let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
                item.label = self.segmentAt5
                self.refreshTable()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
            
            if item.label != self.segmentAt1 { alert.addAction(first) }
            if item.label != self.segmentAt2 { alert.addAction(second) }
            if item.label != self.segmentAt3 { alert.addAction(third) }
            if item.label != self.segmentAt4 { alert.addAction(fourth) }
            if item.label != self.segmentAt5 { alert.addAction(fifth) }
            
            if item.label != "" {
                let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                    item.label = ""
                    self.refreshTable()
                }
                alert.addAction(removeLabel)
            }
            alert.addAction(cancel)
            success(true)
            self.present(alert, animated: true, completion: nil)
        })
        tagAction.setImage(image: Images.tag, width: imageSize, height: imageSize)
        tagAction.setBackgroundColor(Colors.blue)
         
         let hideAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

             item.isHiddenn = 1
             self.refreshTable()
         })
         hideAction.setImage(image: Images.hide, width: imageSize, height: imageSize)
         hideAction.setBackgroundColor(Colors.gray)
         
        return UISwipeActionsConfiguration(actions: [deleteAction, tagAction, hideAction])
    }
    
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.sn.itemArray[self.tempArray[indexPath.row]]
        
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.goEdit = 1
            self.editIndex = self.tempArray[indexPath.row]
            let textEdit = item.note
            UDM.setValue(textEdit ?? "", UDM.textEdit)
            self.rightBarButtonPressed()
            success(true)
        })
        editAction.setImage(image: Images.edit, width: imageSize, height: imageSize)
        editAction.setBackgroundColor(Colors.blue)
        
        let lastNoteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            self.returnLastNote = 1
            self.editIndex = self.tempArray[indexPath.row]
            
            let lastNote = item.lastNote
            UDM.setValue(lastNote ?? "", UDM.lastNote)
            
            self.rightBarButtonPressed()
            success(true)
        })
        lastNoteAction.setImage(image: Images.returN, width: imageSize, height: imageSize)
        lastNoteAction.setBackgroundColor(Colors.purple)
        
        let copyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            UIPasteboard.general.string = String(item.note ?? "nothing")
          
            let alert = UIAlertController(title: "Copied to clipboard", message: "", preferredStyle: .alert)
            
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
            
            self.present(alert, animated: true, completion: nil)
            success(true)
        })
        copyAction.setImage(image: Images.copy, width: imageSize, height: imageSize)
        copyAction.setBackgroundColor(Colors.yellow)
        
        if (item.isEdited) == 0 {
            return UISwipeActionsConfiguration(actions: [editAction, copyAction])
        } else {
            return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
        }
    }
}

//MARK: - AddControllerDelegate

extension HomeController: AddControllerDelegate {
    func handleNewNote() {
        sn.saveItems()
        sn.loadItems()
        findWhichNotesShouldShow()
        tableView.reloadData()
        goEdit = 0
        returnLastNote = 0
    }
}
