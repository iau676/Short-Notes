//
//  NoteSettingsController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "ExampleCell"

final class NoteSettingsController: UIViewController, UITextFieldDelegate {
    
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
    
    private let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    private lazy var exampleNote = Note(context: self.childContext)
    
    //MARK: - UserDefaults
    
    var textSize : CGFloat = 0.0
    var segmentIndexForDate : Int = 0
    var segmentIndexForHour : Int = 0
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        style()
        layout()
        setDefault()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.frame.width, height: 777)
    }
    
    //MARK: - Selectors
    
    @objc private func tagSwitchChanged(sender: UISwitch) {
        UDM.switchShowLabel.set(sender.isOn)
        tagSizeView.updateUserInteractionEnabled(sender.isOn)
        tableView.reloadData()
    }
    
    @objc private func tagSizeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  UDM.tagSize.set(6)
        case 1:  UDM.tagSize.set(8)
        case 2:  UDM.tagSize.set(10)
        case 3:  UDM.tagSize.set(12)
        default: UDM.tagSize.set(14)
        }
        tableView.reloadData()
    }
    
    @objc private func dateSwitchChanged(sender: UISwitch) {
        UDM.switchShowDate.set(sender.isOn)
        dateFormatView.updateUserInteractionEnabled(sender.isOn)
        updateDateFormat()
    }
    
    @objc private func dateFormatChanged(sender: UISegmentedControl) {
        segmentIndexForDate = sender.selectedSegmentIndex
        UDM.segmentIndexForDate.set(segmentIndexForDate)
        updateDateFormat()
    }
    
    @objc private func hourSwitchChanged(sender: UISwitch) {
        UDM.showHour.set(sender.isOn)
        hourFormatView.updateUserInteractionEnabled(sender.isOn)
        updateHourFormat()
    }
    
    @objc private func hourFormatChanged(sender: UISegmentedControl) {
        segmentIndexForHour = sender.selectedSegmentIndex
        UDM.segmentIndexForHour.set(segmentIndexForHour)
        updateHourFormat()
    }
    
    @objc private func textSizeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  UDM.textSize.set(9)
        case 1:  UDM.textSize.set(11)
        case 2:  UDM.textSize.set(13)
        case 3:  UDM.textSize.set(15)
        case 4:  UDM.textSize.set(17)
        case 5:  UDM.textSize.set(19)
        default: UDM.textSize.set(21)
        }
        tableView.reloadData()
        updateTextSize()
    }
    
    //MARK: - Helpers
    
    private func style() {
        scrollView.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)?.darker()
        
        tableView.backgroundColor = .white
        tableView.rowHeight = 77
        tableView.register(NoteCell.self, forCellReuseIdentifier: reuseIdentifier)
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
        tagSizeSegmentedControl.addTarget(self, action: #selector(tagSizeChanged), for: .valueChanged)
        
        showDateView.label.text = "Show Date"
        dateSwitch.addTarget(self, action: #selector(dateSwitchChanged), for: .valueChanged)
        dateFormatView.label.text = "  Date Format"
        dateFormatSegmentedControl.replaceSegments(segments: ["I", "II", "III", "IV"])
        dateFormatSegmentedControl.addTarget(self, action: #selector(dateFormatChanged), for: .valueChanged)
        
        showHourView.label.text = "Show Hour"
        hourSwitch.addTarget(self, action: #selector(hourSwitchChanged), for: .valueChanged)
        hourFormatView.label.text = "  Hour Format"
        hourFormatSegmentedControl.replaceSegments(segments: ["I", "II"])
        hourFormatSegmentedControl.addTarget(self, action: #selector(hourFormatChanged), for: .valueChanged)
        
        textSizeView.label.text = "Text Size"
        textSizeView.layer.maskedCorners = [.layerMinXMaxYCorner]
        textSizeSegmentedControl.replaceSegments(segments: ["I", "II", "III", "IV", "V", "VI", "VII"])
        textSizeSegmentedControl.addTarget(self, action: #selector(textSizeChanged), for: .valueChanged)
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
    }

    func updateTextSize() {
        textSize = UDM.textSize.getCGFloat() //textSizeChanged
        updateLabelSize(showTagView.label)
        updateLabelSize(tagSizeView.label)
        updateLabelSize(showDateView.label)
        updateLabelSize(dateFormatView.label)
        updateLabelSize(showHourView.label)
        updateLabelSize(hourFormatView.label)
        updateLabelSize(textSizeView.label)
    }
    
    func updateLabelSize(_ label:UILabel){
        label.font = label.font.withSize(textSize)
    }

    func updateDateFormat() {
        switch segmentIndexForDate {
        case 0:  UDM.selectedDateFormat.set("EEEE, MMM d, yyyy")
        case 1:  UDM.selectedDateFormat.set("EEEE, d MMM yyyy")
        case 2:  UDM.selectedDateFormat.set("MM/dd/yyyy")
        default: UDM.selectedDateFormat.set("dd/MM/yyyy")
        }
        updateTimeFormat()
    }
    
    func updateHourFormat(){
        switch segmentIndexForHour {
        case 0:  UDM.selectedHourFormat.set("hh:mm a")
        default: UDM.selectedHourFormat.set("HH:mm")
        }
        updateTimeFormat()
    }
    
    func updateTimeFormat() {
        let hourFormat = hourSwitch.isOn ? UDM.selectedHourFormat.getString() : ""
        let dateFormat = dateSwitch.isOn ? UDM.selectedDateFormat.getString() : ""
        let dot = hourFormat.count > 0 && dateFormat.count > 0 ? " ・ " : ""
        UDM.selectedTimeFormat.set(hourFormat + dot + dateFormat)
        tableView.reloadData()
    }
    
    func setDefault() {
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light } 
        textSize = UDM.textSize.getCGFloat()
        segmentIndexForDate = UDM.segmentIndexForDate.getInt()
        segmentIndexForHour = UDM.segmentIndexForHour.getInt()
        
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

        switch UDM.tagSize.getInt() {
        case 6:  tagSizeSegmentedControl.selectedSegmentIndex = 0
        case 8:  tagSizeSegmentedControl.selectedSegmentIndex = 1
        case 10: tagSizeSegmentedControl.selectedSegmentIndex = 2
        case 12: tagSizeSegmentedControl.selectedSegmentIndex = 3
        default: tagSizeSegmentedControl.selectedSegmentIndex = 4
        }
        
        tagSwitch.isOn = UDM.switchShowLabel.getBool()
        tagSizeView.updateUserInteractionEnabled(UDM.switchShowLabel.getBool())
        
        dateSwitch.isOn = UDM.switchShowDate.getBool()
        dateFormatView.updateUserInteractionEnabled(UDM.switchShowDate.getBool())
        
        hourSwitch.isOn = UDM.showHour.getBool()
        hourFormatView.updateUserInteractionEnabled(UDM.showHour.getBool())
    }
}

//MARK: - UITableViewDataSource

extension NoteSettingsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoteCell
        exampleNote.note = "Example of Short Note"
        exampleNote.date = Date()
        exampleNote.label = "🌸"
        cell.note = exampleNote
        return cell
    }
}
