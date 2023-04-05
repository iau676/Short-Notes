//
//  AddController.swift
//  short note
//
//  Created by ibrahim uysal on 20.02.2022.
//

import UIKit
import CoreData

private let reuseIdentifier = "TagCell"

protocol AddControllerDelegate: AnyObject {
    func handleNewNote()
}

final class AddController: UIViewController {
    
    //MARK: - Properties
    
    var note: Note?
    weak var delegate: AddControllerDelegate?
    
    private let noteType: NoteType
    private var sn = ShortNote()
    
    private let centerView = UIView()
    private let noteTextView = UITextView()
    private let selectTagButton = UIButton()
    private let saveButton = UIButton()
    private let checkButton = UIButton()
    
    private var tag = ""
    private var textSize: CGFloat = 0.0
    private var segmentAt1: String = ""
    private var segmentAt2: String = ""
    private var segmentAt3: String = ""
    private var segmentAt4: String = ""
    private var segmentAt5: String = ""
    
    private var alertController = UIAlertController()
    private var tableView = UITableView()
    private var tagDict = [String: Int]()
    private var sortedTagDict = [Dictionary<String, Int>.Element]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle
    
    init(noteType: NoteType) {
        self.noteType = noteType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        assignUserDefaults()
        style()
        layout()
        sn.loadItems()
        configureUI()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noteTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.handleNewNote()
    }

    //MARK: - Selectors
    
    @objc private func selectTagButtonPressed() {
        showTags()
    }
    
    @objc private func saveButtonPressed() {
        guard let text = noteTextView.text else { return }
        if text.count > 0 {
            
            switch noteType {
            case .new:
                sn.appendItem(noteTextView.text!, tag)
                noteTextView.text = ""
            case .edit:
                guard let note = note else { return }
                note.isEdited = 1
                note.lastLabel = note.label
                note.lastNote = note.note
                note.note = text
                note.label = tag
            case .previous:
                guard let note = note else { return }
                note.lastLabel = note.label
                note.lastNote = note.note
                note.note = text
                note.label = tag
            }

            delegate?.handleNewNote()

            scheduledTimer(timeInterval: 0.0, #selector(flipCheckButton))
            scheduledTimer(timeInterval: 0.3, #selector(flipCheckButtonSecond))
            scheduledTimer(timeInterval: 0.6, #selector(dismissView))
        }
    }
    
    @objc private func flipCheckButton() {
        checkButton.setBackgroundImage(Images.checkGreen, for: .normal)
        checkButton.flip(duration: 0.2)
    }
    
    @objc private func flipCheckButtonSecond() {
        checkButton.flip(duration: 0.4)
    }
    
    @objc private func dismissView() {
        view.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        
        centerView.layer.cornerRadius = 10
        centerView.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)?.darker()
        
        noteTextView.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        noteTextView.textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        noteTextView.layer.cornerRadius = 6
        noteTextView.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        
        selectTagButton.backgroundColor = .clear
        selectTagButton.setTitle("Select a Tag", for: .normal)
        selectTagButton.setTitleColor(.darkGray, for: .normal)
        selectTagButton.titleLabel?.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        selectTagButton.addTarget(self, action: #selector(selectTagButtonPressed), for: .touchUpInside)
        
        saveButton.backgroundColor = .darkGray
        saveButton.layer.cornerRadius = 6
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: Fonts.AvenirNextRegular, size: textSize)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
        checkButton.setBackgroundImage(nil, for: .normal)
    }
    
    private func layout() {
        view.addSubview(centerView)
        centerView.setHeight(height: 266)
        centerView.centerY(inView: view, constant: -30)
        centerView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                          paddingLeft: 32, paddingRight: 32)
        
        centerView.addSubview(noteTextView)
        noteTextView.setHeight(height: 140)
        noteTextView.anchor(top: centerView.topAnchor, left: centerView.leftAnchor,
                            right: centerView.rightAnchor, paddingTop: 16,
                            paddingLeft: 16, paddingRight: 16)
        
        centerView.addSubview(selectTagButton)
        selectTagButton.setHeight(height: 40)
        selectTagButton.anchor(top: noteTextView.bottomAnchor, left: centerView.leftAnchor,
                               right: centerView.rightAnchor, paddingTop: 8,
                               paddingLeft: 16, paddingRight: 16)
        
        centerView.addSubview(saveButton)
        saveButton.setHeight(height: 40)
        saveButton.anchor(top: selectTagButton.bottomAnchor, left: centerView.leftAnchor,
                          right: centerView.rightAnchor, paddingTop: 8,
                          paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(checkButton)
        checkButton.setDimensions(height: 90, width: 90)
        checkButton.centerX(inView: view)
        checkButton.anchor(bottom: centerView.topAnchor, paddingBottom: 16)
    }
    
    private func configureUI() {
        guard let note = note else { return }
        
        switch noteType {
        case .new: break
        case .edit:
            noteTextView.text = note.note
            tag = note.label ?? ""
            setButtonTitle()
        case .previous:
            noteTextView.text = note.lastNote
            tag = note.lastLabel ?? ""
            setButtonTitle()
        }
    }
    
    private func assignUserDefaults() {
        textSize = UDM.textSize.getCGFloat()
        segmentAt1 = UDM.segmentAt1.getString()
        segmentAt2 = UDM.segmentAt2.getString()
        segmentAt3 = UDM.segmentAt3.getString()
        segmentAt4 = UDM.segmentAt4.getString()
        segmentAt5 = UDM.segmentAt5.getString()
    }
    
    private func setButtonTitle() {
        selectTagButton.setTitle(tag.count > 0 ? tag : "Select a Tag", for: .normal)
    }
    
    private func checkAction() {
        guard let text = noteTextView.text else { return }
        
        if text.count > 0 {
            switch noteType {
            case .new:
                presentNotSavedAlert()
            case .edit:
                if note?.note == text && note?.label == tag {
                    dismiss(animated: true, completion: nil)
                } else {
                    presentNotSavedAlert()
                }
            case .previous:
                if note?.lastNote == text && note?.lastLabel == tag {
                    dismiss(animated: true, completion: nil)
                } else {
                    presentNotSavedAlert()
                }
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func scheduledTimer(timeInterval: Double, _ selector : Selector) {
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: selector, userInfo: nil, repeats: false)
    }
    
    private func presentNotSavedAlert() {
        showAlertWithCancel(title: "Your changes could not be saved", message: "") { OK in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - UITextFieldDelegate

extension AddController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == noteTextView {
        } else {
            noteTextView.becomeFirstResponder()
        }
        return true
    }
}

//MARK: - Swipe Gesture

extension AddController {
    private func addGestureRecognizer() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeDownGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func respondToSwipeDownGesture(gesture: UISwipeGestureRecognizer) {
        checkAction()
    }
}

//MARK: - Tag Action

extension AddController {
    
    private func showTags() {
        let alert = UIAlertController(title: "Select a Tag", message: "", preferredStyle: .alert)

        let first = UIAlertAction(title: self.segmentAt1, style: .default) { (action) in
            self.tag = self.segmentAt1
            self.setButtonTitle()
        }
        let second = UIAlertAction(title: self.segmentAt2, style: .default) { (action) in
            self.tag = self.segmentAt2
            self.setButtonTitle()
        }
        let third = UIAlertAction(title: self.segmentAt3, style: .default) { (action) in
            self.tag = self.segmentAt3
            self.setButtonTitle()
        }
        let fourth = UIAlertAction(title: self.segmentAt4, style: .default) { (action) in
            self.tag = self.segmentAt4
            self.setButtonTitle()
        }
        let fifth = UIAlertAction(title: self.segmentAt5, style: .default) { (action) in
            self.tag = self.segmentAt5
            self.setButtonTitle()
        }
        
        let all = UIAlertAction(title: "All", style: .default) { (action) in
            self.findTags()
            self.showAll()
        }
        
        let new = UIAlertAction(title: "New", style: .default) { (action) in
            self.showNew()
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }

        if tag != self.segmentAt1 { alert.addAction(first) }
        if tag != self.segmentAt2 { alert.addAction(second) }
        if tag != self.segmentAt3 { alert.addAction(third) }
        if tag != self.segmentAt4 { alert.addAction(fourth) }
        if tag != self.segmentAt5 { alert.addAction(fifth) }
        if tag != "" {
            let removeLabel = UIAlertAction(title: "Remove Tag", style: .default) { (action) in
                self.selectTagButton.setTitle("Select a Tag", for: .normal)
                self.tag = ""
            }
            alert.addAction(removeLabel)
        }
        alert.addAction(all)
        alert.addAction(new)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAll() {
        let alert = UIViewController.init()
            let rect = CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0)
            alert.preferredContentSize = rect.size
            
            tableView = UITableView(frame: rect)
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.separatorStyle = .singleLine
            tableView.register(AllCell.self, forCellReuseIdentifier: reuseIdentifier)
            alert.view.addSubview(tableView)
            alert.view.bringSubviewToFront(tableView)
            alert.view.isUserInteractionEnabled = true
            tableView.isUserInteractionEnabled = true
            tableView.allowsSelection = true
            
            self.alertController = UIAlertController(title: "All", message: nil, preferredStyle: .alert)
            alertController.setValue(alert, forKey: "contentViewController")
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    private func showNew() {
        let alert = UIAlertController(title: "New Tag", message: "", preferredStyle: .alert)
        
        alert.addTextField { tf in tf.placeholder = "New" }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let select = UIAlertAction(title: "Select", style: .default) { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            alert.dismiss(animated: true) {
                if text.count > 0 {
                    self.tag = text
                    self.selectTagButton.setTitle(text, for: .normal)
                }
            }
        }
        alert.addAction(cancel)
        alert.addAction(select)
        present(alert, animated: true, completion: nil)
    }
    
    private func findTags() {
        for i in 0..<sn.itemArray.count {
            guard let label = sn.itemArray[i].label else { return }
            if sn.itemArray[i].isHiddenn == 0 && sn.itemArray[i].isDeletedd == 0 && label.count > 0 {
                tagDict.updateValue((tagDict[label] ?? 0)+1, forKey: label)
                sortedTagDict = tagDict.sorted{$0.value > $1.value}
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension AddController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTagDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AllCell
        let key = Array(sortedTagDict)[indexPath.row].key
        cell.label.text = key
        return cell
    }
}

//MARK: - UITableViewDelegate

extension AddController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        alertController.dismiss(animated: true) {
            let key = Array(self.sortedTagDict)[indexPath.row].key
            self.tag = key
            self.selectTagButton.setTitle(key, for: .normal)
        }
    }
}

//MARK: - AllCell

private class AllCell: UITableViewCell {
    
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        label.textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        label.numberOfLines = 0
        
        addSubview(label)
        label.centerY(inView: self)
        label.anchor(left: leftAnchor, right: rightAnchor,
                     paddingLeft: 16, paddingRight: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
