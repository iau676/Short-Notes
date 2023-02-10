//
//  NoteSettingsController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "ExampleCell"

class NoteSettingsController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    
    private let scrollView = UIScrollView()
    
    private let tableView = UITableView()
    
    private let showTagView = SettingView()
    private let tagSwitch = UISwitch()
    private let tagSizeView = SettingView()
    private let tagSizeSegmentedControl = UISegmentedControl()
    
    private let showDateView = SettingView()
    private let dateSwitch = UISwitch()
    private let dateFormatView = SettingView()
    private let dateFormatSegmentedControl = UISegmentedControl()
    
    private let showHourView = SettingView()
    private let hourSwitch = UISwitch()
    private let hourFormatView = SettingView()
    private let hourFormatSegmentedControl = UISegmentedControl()
    
    private let textSizeView = SettingView()
    private let textSizeSegmentedControl = UISegmentedControl()
    
    private let deleteAllNotesButton = UIButton()

    var sn = ShortNote()
    var onViewWillDisappear: (()->())?
    private let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    private lazy var exampleNote = Note(context: self.childContext)
    
    //MARK: - UserDefaults
    
    var textSize : CGFloat = 0.0
    var darkMode : Int = 0
    var segmentIndexForDate : Int = 0
    var segmentIndexForHour : Int = 0
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        assignUserDefaults()
        setDefault()
        
        style()
        layout()
        
        configureSegmentedControls()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onViewWillDisappear?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.frame.width, height: 777)
    }
    
    //MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDelete" {
            if segue.destination is DeleteAllNotesViewController {
                (segue.destination as? DeleteAllNotesViewController)?.onViewWillDisappear = {
                    self.onViewWillDisappear?()
                }
            }
        }
    }

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Selectors
    
    @objc private func tagSwitchChanged(sender: UISwitch) {
        if sender.isOn {
            UDM.setValue(1, UDM.switchShowLabel)
            changeViewState(tagSizeView, 1, true)
        } else {
            UDM.setValue(0, UDM.switchShowLabel)
            changeViewState(tagSizeView, 0.6, false)
        }
        
        tableView.reloadData()
        onViewWillDisappear?()
    }
    
    @objc private func tagSizeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  UDM.setValue(6, UDM.tagSize)
        case 1:  UDM.setValue(8, UDM.tagSize)
        case 2:  UDM.setValue(10, UDM.tagSize)
        case 3:  UDM.setValue(12, UDM.tagSize)
        default: UDM.setValue(14, UDM.tagSize)
        }
        tableView.reloadData()
        onViewWillDisappear?()
    }
    
    @objc private func dateSwitchChanged(sender: UISwitch) {
        if sender.isOn {
            UDM.setValue(1, UDM.switchShowDate)
            changeViewState(dateFormatView, 1, true)
        } else {
            UDM.setValue(0, UDM.switchShowDate)
            changeViewState(dateFormatView, 0.6, false)
        }
        updateDateFormat()
        onViewWillDisappear?()
    }
    
    @objc private func dateFormatChanged(sender: UISegmentedControl) {
        segmentIndexForDate = sender.selectedSegmentIndex
        UDM.setValue(segmentIndexForDate, UDM.segmentIndexForDate)
        updateDateFormat()
    }
    
    @objc private func hourSwitchChanged(sender: UISwitch) {
        if sender.isOn {
            UDM.setValue(1, UDM.showHour)
            changeViewState(hourFormatView, 1, true)
        } else {
            UDM.setValue(0, UDM.showHour)
            changeViewState(hourFormatView, 0.6, false)
        }
        updateHourFormat()
        onViewWillDisappear?()
    }
    
    @objc private func hourFormatChanged(sender: UISegmentedControl) {
        segmentIndexForHour = sender.selectedSegmentIndex
        UDM.setValue(segmentIndexForHour, UDM.segmentIndexForHour)
        updateHourFormat()
    }
    
    @objc private func textSizeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  UDM.setValue(9, UDM.textSize)
        case 1:  UDM.setValue(11, UDM.textSize)
        case 2:  UDM.setValue(13, UDM.textSize)
        case 3:  UDM.setValue(15, UDM.textSize)
        case 4:  UDM.setValue(17, UDM.textSize)
        case 5:  UDM.setValue(19, UDM.textSize)
        default: UDM.setValue(21, UDM.textSize)
        }
        tableView.reloadData()
        updateTextSize()
    }
    
    @objc private func deleteAllNotesButtonPressed() {
        let controller = DeleteAllNotesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = .darkGray
        
        scrollView.backgroundColor = darkMode == 1 ? UIColor.black : UIColor.white
        
        tableView.backgroundColor = .white
        tableView.rowHeight = 77
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        
        showTagView.label.text = "Show Tag"
        tagSwitch.addTarget(self, action: #selector(tagSwitchChanged), for: .valueChanged)
        tagSizeView.label.text = "  Tag Size"
        tagSizeSegmentedControl.replaceSegments(segments: ["I", "II", "III", "IV", "V"])
        tagSizeSegmentedControl.addTarget(self, action: #selector(tagSizeChanged), for: UIControl.Event.valueChanged)
        
        showDateView.label.text = "Show Date"
        dateSwitch.addTarget(self, action: #selector(dateSwitchChanged), for: .valueChanged)
        dateFormatView.label.text = "  Date Format"
        dateFormatSegmentedControl.replaceSegments(segments: ["I", "II", "III", "IV"])
        dateFormatSegmentedControl.addTarget(self, action: #selector(dateFormatChanged), for: UIControl.Event.valueChanged)
        
        showHourView.label.text = "Show Hour"
        hourSwitch.addTarget(self, action: #selector(hourSwitchChanged), for: .valueChanged)
        hourFormatView.label.text = "  Hour Format"
        hourFormatSegmentedControl.replaceSegments(segments: ["I", "II"])
        hourFormatSegmentedControl.addTarget(self, action: #selector(hourFormatChanged), for: UIControl.Event.valueChanged)
        
        textSizeView.label.text = "Text Size"
        textSizeView.layer.maskedCorners = [.layerMinXMaxYCorner]
        textSizeSegmentedControl.replaceSegments(segments: ["I", "II", "III", "IV", "V", "VI", "VII"])
        textSizeSegmentedControl.addTarget(self, action: #selector(textSizeChanged), for: UIControl.Event.valueChanged)
        
        deleteAllNotesButton.setTitle("Delete All Notes", for: .normal)
        deleteAllNotesButton.setTitleColor(UIColor.red, for: .normal)
        deleteAllNotesButton.titleLabel?.font =  deleteAllNotesButton.titleLabel?.font.withSize(textSize)
        deleteAllNotesButton.backgroundColor = .clear
        deleteAllNotesButton.addTarget(self, action: #selector(deleteAllNotesButtonPressed), for: .touchUpInside)
    }
    
    private func layout() {
        
        //scrollView
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        //tableView
        
        scrollView.addSubview(tableView)
        tableView.anchor(top: scrollView.topAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 32, paddingLeft: 32,
                         paddingRight: 32, height: 77)
        
        //tag
        
        scrollView.addSubview(showTagView)
        showTagView.anchor(top: tableView.bottomAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, paddingTop: 8, paddingLeft: 32,
                           paddingRight: 32, height: 50)
        
        showTagView.addSubview(tagSwitch)
        tagSwitch.centerY(inView: showTagView)
        tagSwitch.anchor(right: showTagView.rightAnchor, paddingRight: 16)
        
        scrollView.addSubview(tagSizeView)
        tagSizeView.anchor(top: showTagView.bottomAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, paddingTop: 0.3, paddingLeft: 32,
                           paddingRight: 32, height: 90)
        
        tagSizeView.addSubview(tagSizeSegmentedControl)
        tagSizeSegmentedControl.centerY(inView: tagSizeView, constant: 18)
        tagSizeSegmentedControl.anchor(left: tagSizeView.leftAnchor, right: tagSizeView.rightAnchor,
                                       paddingLeft: 23, paddingRight: 16)
        
        //date
        
        scrollView.addSubview(showDateView)
        showDateView.anchor(top: tagSizeView.bottomAnchor, left: view.leftAnchor,
                            right: view.rightAnchor, paddingTop: 8, paddingLeft: 32,
                            paddingRight: 32, height: 50)
        
        showDateView.addSubview(dateSwitch)
        dateSwitch.centerY(inView: showDateView)
        dateSwitch.anchor(right: showDateView.rightAnchor, paddingRight: 16)
        
        scrollView.addSubview(dateFormatView)
        dateFormatView.anchor(top: showDateView.bottomAnchor, left: view.leftAnchor,
                              right: view.rightAnchor, paddingTop: 0.9, paddingLeft: 32,
                              paddingRight: 32, height: 90)
        
        dateFormatView.addSubview(dateFormatSegmentedControl)
        dateFormatSegmentedControl.centerY(inView: dateFormatView, constant: 18)
        dateFormatSegmentedControl.anchor(left: dateFormatView.leftAnchor, right: tagSizeView.rightAnchor,
                                          paddingLeft: 23, paddingRight: 16)
        
        //hour
        
        scrollView.addSubview(showHourView)
        showHourView.anchor(top: dateFormatView.bottomAnchor, left: view.leftAnchor,
                            right: view.rightAnchor, paddingTop: 8, paddingLeft: 32,
                            paddingRight: 32, height: 50)
        
        showHourView.addSubview(hourSwitch)
        hourSwitch.centerY(inView: showHourView)
        hourSwitch.anchor(right: showDateView.rightAnchor, paddingRight: 16)
        
        scrollView.addSubview(hourFormatView)
        hourFormatView.anchor(top: showHourView.bottomAnchor, left: view.leftAnchor,
                              right: view.rightAnchor, paddingTop: 0.3, paddingLeft: 32,
                              paddingRight: 32, height: 90)
        
        hourFormatView.addSubview(hourFormatSegmentedControl)
        hourFormatSegmentedControl.centerY(inView: hourFormatView, constant: 18)
        hourFormatSegmentedControl.anchor(left: dateFormatView.leftAnchor, right: tagSizeView.rightAnchor,
                                          paddingLeft: 23, paddingRight: 16)
        
        //text
        
        scrollView.addSubview(textSizeView)
        textSizeView.anchor(top: hourFormatView.bottomAnchor, left: view.leftAnchor,
                            right: view.rightAnchor, paddingTop: 8, paddingLeft: 32,
                            paddingRight: 32, height: 99)
        
        textSizeView.addSubview(textSizeSegmentedControl)
        textSizeSegmentedControl.centerY(inView: textSizeView, constant: 18)
        textSizeSegmentedControl.anchor(left: dateFormatView.leftAnchor, right: tagSizeView.rightAnchor,
                                        paddingLeft: 16, paddingRight: 16)
        
        //button
        
        scrollView.addSubview(deleteAllNotesButton)
        deleteAllNotesButton.centerX(inView: scrollView)
        deleteAllNotesButton.anchor(top: textSizeView.bottomAnchor, paddingTop: 16)
    }
    
    func assignUserDefaults(){
        textSize = UDM.getCGFloatValue(UDM.textSize)
        darkMode = UDM.getIntValue(UDM.darkMode)
        segmentIndexForDate = UDM.getIntValue(UDM.segmentIndexForDate)
        segmentIndexForHour = UDM.getIntValue(UDM.segmentIndexForHour)
    }
    
    func checkAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //segmented controls are different from other elements
    //if text size update firstly, only foregroundColor property being update, text size become default
    //for this reason, color and text size should updated same time
    func configureSegmentedControls(){
        updateSegmentedControlColor(dateFormatSegmentedControl)
        updateSegmentedControlColor(hourFormatSegmentedControl)
        updateSegmentedControlColor(textSizeSegmentedControl)
        updateSegmentedControlColor(tagSizeSegmentedControl)
    }
    
    func updateSegmentedControlColor(_ segmentedControl: UISegmentedControl) {
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        let color = darkMode == 1 ? Colors.cellLight! : Colors.cellDark!
        segmentedControl.setTitleTextAttributes([.foregroundColor: color, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: Colors.cellDark!], for: .selected)
    }

    func updateTextSize() {
        textSize = UDM.getCGFloatValue(UDM.textSize) //textSizeChanged
        updateLabelSize(showTagView.label)
        updateLabelSize(tagSizeView.label)
        updateLabelSize(showDateView.label)
        updateLabelSize(dateFormatView.label)
        updateLabelSize(showHourView.label)
        updateLabelSize(hourFormatView.label)
        updateLabelSize(textSizeView.label)
        deleteAllNotesButton.titleLabel?.font =  deleteAllNotesButton.titleLabel?.font.withSize(textSize)
    }
    
    func updateLabelSize(_ label:UILabel){
        label.font = label.font.withSize(textSize)
    }

    func updateDateFormat() {
        switch segmentIndexForDate {
        case 0:  UDM.setValue("EEEE, MMM d, yyyy", UDM.selectedDateFormat)
        case 1:  UDM.setValue("EEEE, d MMM yyyy", UDM.selectedDateFormat)
        case 2:  UDM.setValue("MM/dd/yyyy", UDM.selectedDateFormat)
        default: UDM.setValue("dd/MM/yyyy", UDM.selectedDateFormat)
        }
        updateTimeFormat()
    }
    
    func updateHourFormat(){
        switch segmentIndexForHour {
        case 0:  UDM.setValue("hh:mm a", UDM.selectedHourFormat)
        default: UDM.setValue("HH:mm", UDM.selectedHourFormat)
        }
        updateTimeFormat()
    }
    
    func updateTimeFormat() {
        let hourFormat = UDM.getStringValue(UDM.selectedHourFormat)
        let dateFormat = UDM.getStringValue(UDM.selectedDateFormat)
        
        if dateSwitch.isOn {
            if hourSwitch.isOn {
                UDM.setValue(hourFormat + ", " + dateFormat, UDM.selectedTimeFormat)
            } else {
                UDM.setValue(dateFormat, UDM.selectedTimeFormat)
            }
        } else {
            if hourSwitch.isOn {
                UDM.setValue(hourFormat, UDM.selectedTimeFormat)
            } else {
                UDM.setValue("", UDM.selectedTimeFormat)
            }
        }
        tableView.reloadData()
    }
    
    func setDefault(){
        dateFormatSegmentedControl.selectedSegmentIndex = segmentIndexForDate
        hourFormatSegmentedControl.selectedSegmentIndex = segmentIndexForHour

        switch textSize {
        case 9:  textSizeSegmentedControl.selectedSegmentIndex = 0
        case 11: textSizeSegmentedControl.selectedSegmentIndex = 1
        case 13: textSizeSegmentedControl.selectedSegmentIndex = 2
        case 15: textSizeSegmentedControl.selectedSegmentIndex = 3
        case 17: textSizeSegmentedControl.selectedSegmentIndex = 4
        case 19: textSizeSegmentedControl.selectedSegmentIndex = 5
        default: textSizeSegmentedControl.selectedSegmentIndex = 6
        }

        switch UDM.getIntValue(UDM.tagSize) {
        case 6:  tagSizeSegmentedControl.selectedSegmentIndex = 0
        case 8:  tagSizeSegmentedControl.selectedSegmentIndex = 1
        case 10: tagSizeSegmentedControl.selectedSegmentIndex = 2
        case 12: tagSizeSegmentedControl.selectedSegmentIndex = 3
        default: tagSizeSegmentedControl.selectedSegmentIndex = 4
        }

        if UDM.getIntValue(UDM.switchShowLabel) == 1 {
            tagSwitch.isOn = true
            changeViewState(tagSizeView, 1, true)
        } else {
            tagSwitch.isOn = false
            changeViewState(tagSizeView, 0.6, false)
        }

        if UDM.getIntValue(UDM.switchShowDate) == 1 {
            dateSwitch.isOn = true
            changeViewState(dateFormatView, 1, true)
        } else {
            dateSwitch.isOn = false
            changeViewState(dateFormatView, 0.6, false)
        }

        if UDM.getIntValue(UDM.showHour) == 1 {
            hourSwitch.isOn = true
            changeViewState(hourFormatView, 1, true)
        } else {
            hourSwitch.isOn = false
            changeViewState(hourFormatView, 0.6, false)
        }
    }
    
    func changeViewState(_ uiview: UIView, _ alpha: CGFloat, _ bool: Bool){
        UIView.transition(with: uiview, duration: 0.4,
                          options: (alpha < 1 ? .transitionFlipFromTop : .transitionFlipFromBottom),
                          animations: {
            uiview.isUserInteractionEnabled = bool
            uiview.alpha = alpha
        })
    }
}

//MARK: - UITableViewDataSource

extension NoteSettingsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        exampleNote.note = "Example of Short Note"
        exampleNote.date = Date()
        exampleNote.label = "🌸"
        cell.note = exampleNote
        return cell
    }
}
