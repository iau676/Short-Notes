//
//  ViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "NoteCell"

final class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
       let segmentedControl = UISegmentedControl()
        segmentedControl.setHeight(height: 50)
        segmentedControl.replaceSegments(segments: ["All", "", "", "", "", ""])
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private var sn = ShortNote()
    private var tempArray = [Int]()
    private let gradient = CAGradientLayer()
    
    private var selectedSegmentIndex = 0
    
    private var tagSize: CGFloat = 0.0
    private var textSize: CGFloat = 0.0
    private var imageSize: CGFloat = 0.0
    private var segmentAt1: String = ""
    private var segmentAt2: String = ""
    private var segmentAt3: String = ""
    private var segmentAt4: String = ""
    private var segmentAt5: String = ""

    private var currentTheme: ShortNoteTheme {
        return ThemeManager.shared.currentTheme
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sn.loadItems()
        assignUserDefaults()
        configureUI()
        
        findWhichNotesShouldShow()
        hideKeyboardWhenTappedAround()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSegmentedControl()
    }

    //MARK: - Selectors

    @objc private func goAddPageIfNeed() {
        if UDM.switchNote.getBool() { goAdd(type: .new) }
    }
    
    @objc private func leftBarButtonPressed() {
        let controller = SettingsController()
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
    
    @objc private func rightBarButtonPressed() {
        goAdd(type: .new)
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        UDM.selectedSegmentIndex.set(sender.selectedSegmentIndex)
        selectedSegmentIndex = sender.selectedSegmentIndex
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        configureNavigationBar()
        sn.setFirstLaunch()
        setSearchBar()
        updateColors()
        
        gradient.frame = view.layer.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.goAddPageIfNeed),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        
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
            leftBarIV.image = Images.menu?.withTintColor(.black, renderingMode: .alwaysOriginal)
            rightBarIV.image = Images.plus?.withTintColor(.black, renderingMode: .alwaysOriginal)
        } else {
            leftBarIV.image = Images.menu
            rightBarIV.image = Images.plus
        }
        
        let tapLeft = UITapGestureRecognizer(target: self, action: #selector(leftBarButtonPressed))
        leftBarIV.addGestureRecognizer(tapLeft)
        
        let tapRight = UITapGestureRecognizer(target: self, action: #selector(rightBarButtonPressed))
        rightBarIV.addGestureRecognizer(tapRight)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarIV)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarIV)
    }
    
    private func assignUserDefaults() {
        tagSize = UDM.tagSize.getCGFloat()
        textSize = UDM.textSize.getCGFloat()
        imageSize = textSize + 5
        segmentAt1 = UDM.segmentAt1.getString()
        segmentAt2 = UDM.segmentAt2.getString()
        segmentAt3 = UDM.segmentAt3.getString()
        segmentAt4 = UDM.segmentAt4.getString()
        segmentAt5 = UDM.segmentAt5.getString()
    }
    
    private func findWhichNotesShouldShow(){
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
    
    private func updateColors() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        gradient.colors = [UIColor(hex: currentTheme.backgroundColor)!.cgColor,
                           UIColor(hex: currentTheme.backgroundColorBottom)!.cgColor]
        
        tableView.backgroundColor = UIColor(hex: currentTheme.tableViewColor)
        searchBar.barTintColor = UIColor(hex: currentTheme.searhcBarColor)
        segmentedControl.backgroundColor = UIColor(hex: currentTheme.segmentedControlColor)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = UIColor.white
            searchBar.searchTextField.textColor = UIColor(hex: currentTheme.textColor)
            overrideUserInterfaceStyle = .light
        }
    }
    
    private func setSegmentedControl() {
        segmentedControl.setTitle(segmentAt1, forSegmentAt: 1)
        segmentedControl.setTitle(segmentAt2, forSegmentAt: 2)
        segmentedControl.setTitle(segmentAt3, forSegmentAt: 3)
        segmentedControl.setTitle(segmentAt4, forSegmentAt: 4)
        segmentedControl.setTitle(segmentAt5, forSegmentAt: 5)
        
        segmentedControl.setTitleTextAttributes([.font: UIFont(name: Fonts.AvenirNextRegular, size: textSize+4)!], for: .normal)
    }
    
    private func goAdd(type: NoteType, note: Note? = nil) {
        let controller = AddController(noteType: type)
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.note = note
        present(controller, animated: true)
    }
    
    private func refreshTable(){
        sn.saveItems()
        sn.loadItems()
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
}

//MARK: - Search Bar

extension HomeController: UISearchBarDelegate {
    
    func setSearchBar(){
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.black
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(textSize)

        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = UIColor.darkGray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }

        if text.count > 0 {
            let request : NSFetchRequest<Note> = Note.fetchRequest()
            request.predicate = NSPredicate(format: "note CONTAINS[cd] %@", text)
            request.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
            sn.loadItems(with: request)
        } else {
            sn.loadItems()
        }
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
    
    func updateSearchBarPlaceholder() {
        let noteCount = tempArray.count
        searchBar.placeholder = noteCount > 0 ?
        noteCount == 1 ? "Search in \(noteCount) note" :
        "Search in \(noteCount) notes" :
        selectedSegmentIndex == 0 ?
        "You can add note using the + sign" :
        "Nothing to see here"
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

        let deleteAction = makeAction(color: UIColor.red, image: Images.thrash) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            item.isDeletedd = 1
            item.deleteDate = Date()
            item.hideStatusBeforeDelete = item.isHiddenn
            self.refreshTable()
            success(true)
        }
        
        let hideAction = makeAction(color: Colors.gray, image: Images.hide) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            item.isHiddenn = 1
            self.refreshTable()
            success(true)
        }
         
        return UISwipeActionsConfiguration(actions: [deleteAction, hideAction])
    }
    
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.sn.itemArray[self.tempArray[indexPath.row]]
        
        let editAction = makeAction(color: Colors.blue, image: Images.edit) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .edit, note: item)
            success(true)
        }
        
        let lastNoteAction = makeAction(color: Colors.purple, image: Images.returN) { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .previous, note: item)
            success(true)
        }
        
        let copyAction = makeAction(color: Colors.yellow, image: Images.copy) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            UIPasteboard.general.string = String(item.note ?? "")
          
            let alert = UIAlertController(title: "Copied to clipboard", message: "", preferredStyle: .alert)
            
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
            
            self.present(alert, animated: true, completion: nil)
            success(true)
        }
        
        if (item.isEdited) == 0 {
            return UISwipeActionsConfiguration(actions: [editAction, copyAction])
        } else {
            return UISwipeActionsConfiguration(actions: [editAction, lastNoteAction, copyAction])
        }
    }
}

//MARK: - Swipe Gesture

extension HomeController {
    private func addGestureRecognizer() {
        addThemeGestureRecognizer()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeLeftGesture))
        swipeLeft.direction = .left
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeRightGesture))
        swipeRight.direction = .right
        
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func respondToSwipeLeftGesture(gesture: UISwipeGestureRecognizer) {
        goAdd(type: .new)
    }
    
    @objc private func respondToSwipeRightGesture(gesture: UISwipeGestureRecognizer) {
        let controller = SettingsController()
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
}

//MARK: - Gesture Recognizer

extension HomeController {
    private func addThemeGestureRecognizer(){
        let themeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.themeGestureRecognizerDidTap(_:)))
        themeGestureRecognizer.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(themeGestureRecognizer)
    }

    @objc private func themeGestureRecognizerDidTap(_ gesture: UITapGestureRecognizer) {
        if UDM.switchDoubleClick.getBool() {
            ThemeManager.shared.moveToNextTheme()
            tableView.reloadData()
            updateColors()
        }
    }
}

//MARK: - SettingsControllerDelegate

extension HomeController: SettingsControllerDelegate {
    func updateTableView() {
        assignUserDefaults()
        setSegmentedControl()
        setSearchBar()
        updateColors()
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
}

//MARK: - AddControllerDelegate

extension HomeController: AddControllerDelegate {
    func handleNewNote() {
        sn.saveItems()
        sn.loadItems()
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
}
