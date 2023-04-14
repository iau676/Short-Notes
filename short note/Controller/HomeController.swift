//
//  ViewController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//
import UIKit

private let reuseIdentifier = "NoteCell"

final class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl()
    
    private var sn = ShortNote()
    private var tempArray = [Int]()
    private let gradient = CAGradientLayer()
    private var selectedSegmentIndex = 0
    private var tagSize: CGFloat = UDM.tagSize.getCGFloat()
    private var textSize: CGFloat = UDM.textSize.getCGFloat()
    
    private var noteArray = [Note]() {
        didSet {
            updateSearchBarPlaceholder()
            tableView.reloadData()
        }
    }
    
    private var currentTheme: ShortNoteTheme {
        return ThemeManager.shared.currentTheme
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sn.setFirstLaunch()
        sn.loadItems()
        findWhichNotesShouldShow()
        
        style()
        layout()
        
        hideKeyboardWhenTappedAround()
        addGestureRecognizer()
        addObserver()
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
        selectedSegmentIndex = sender.selectedSegmentIndex
        findWhichNotesShouldShow()
    }
    
    //MARK: - Helpers
    
    private func  style() {
        configureNavigationBar()
        updateColors()
        
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        searchBar.updateTextField()
        
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        segmentedControl.setHeight(height: 50)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        segmentedControl.updateText(sn.fiveEmojies)
    }
    
    private func layout() {
        gradient.frame = view.layer.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
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
    
    private func findWhichNotesShouldShow() {
        let tag = sn.fiveEmojies[selectedSegmentIndex]
        noteArray = selectedSegmentIndex == 0 ? sn.normalNotes() : sn.filteredNormalNotes(tag: tag)
    }
    
    private func updateColors() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        gradient.colors = [UIColor(hex: currentTheme.backgroundColor)!.cgColor,
                           UIColor(hex: currentTheme.backgroundColorBottom)!.cgColor]
        
        tableView.backgroundColor = UIColor(hex: currentTheme.cellColor)
        searchBar.barTintColor = UIColor(hex: currentTheme.cellColor)
        segmentedControl.backgroundColor = UIColor(hex: currentTheme.cellColor)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = UIColor.white
            searchBar.searchTextField.textColor = UIColor(hex: currentTheme.textColor)
            overrideUserInterfaceStyle = .light
        }
    }
    
    private func goAdd(type: NoteType, note: Note? = nil) {
        let controller = AddController(noteType: type)
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.note = note
        present(controller, animated: true)
    }
    
    private func updateSearchBarPlaceholder() {
        let noteCount = noteArray.count
        searchBar.placeholder = noteCount > 0 ?
        noteCount == 1 ? "Search in \(noteCount) note" :
        "Search in \(noteCount) notes" :
        selectedSegmentIndex == 0 ?
        "You can add note using the + sign" :
        "Nothing to see here"
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.goAddPageIfNeed),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func refreshTable(){
        sn.saveItems()
        sn.loadItems()
        findWhichNotesShouldShow()
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate

extension HomeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        sn.searchNote(text: text)
        findWhichNotesShouldShow()
    }
}

//MARK: - UITableViewDataSource

extension HomeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sn.itemArray.count == 0 {updateColors()}
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        cell.note = noteArray[indexPath.row]
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
        let note = noteArray[indexPath.row]

        let deleteAction = makeAction(color: UIColor.red, image: Images.thrash) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.sn.tempDelete(note: note)
            self.refreshTable()
            success(true)
        }
        
        let hideAction = makeAction(color: Colors.gray, image: Images.hide) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.sn.hide(note: note)
            self.refreshTable()
            success(true)
        }
         
        return UISwipeActionsConfiguration(actions: [deleteAction, hideAction])
    }
    
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = noteArray[indexPath.row]
        
        let editAction = makeAction(color: Colors.blue, image: Images.edit) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .edit, note: note)
            success(true)
        }
        
        let lastNoteAction = makeAction(color: Colors.purple, image: Images.returN) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.goAdd(type: .previous, note: note)
            success(true)
        }
        
        let copyAction = makeAction(color: Colors.yellow, image: Images.copy) {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            UIPasteboard.general.string = String(note.note ?? "")
            self.showAlertWithTimer(title: "Copied to clipboard")
            success(true)
        }
        
        if (note.isEdited) == 0 {
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
        sn.loadItems()
        tagSize = UDM.tagSize.getCGFloat()
        textSize = UDM.textSize.getCGFloat()
        findWhichNotesShouldShow()
        segmentedControl.updateText(sn.fiveEmojies)
        updateColors()
    }
}

//MARK: - AddControllerDelegate

extension HomeController: AddControllerDelegate {
    func handleNewNote() {
        sn.loadItems()
        findWhichNotesShouldShow()
    }
}
