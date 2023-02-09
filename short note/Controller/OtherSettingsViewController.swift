//
//  OtherSettingsViewController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//
import UIKit
import CoreData

private let reuseIdentifier = "ExampleCell"

class OtherSettingsViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    
    private let tableView = UITableView()

    var sn = ShortNote()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    var segmentNumber = 0
    var goEdit = 0
    var editIndex = 0
    var labelName = ""
    var isOpen = false
    
    var onViewWillDisappear: (()->())?
    
    //MARK: - UserDefaults
    
    var textSize : CGFloat = 0.0
    var darkMode : Int = 0
    var segmentIndexForDate : Int = 0
    var segmentIndexForHour : Int = 0
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        style()
        layout()
        sn.loadItems()
        
        assignUserDefaults()
        setDefault()
        
        updateCornerRadius()
        updateTextSize()
        updateColor()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onViewWillDisappear?()
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
    
    //MARK: - IBAction
//
//    @IBAction func switchShowLabelPressed(_ sender: UISwitch) {
//        if sender.isOn {
//            sn.setValue(1, sn.switchShowLabel)
//            changeViewState(tagSizeView, 1, true)
//        } else {
//            sn.setValue(0, sn.switchShowLabel)
//            changeViewState(tagSizeView, 0.6, false)
//        }
//        onViewWillDisappear?()
//    }
//
//    @IBAction func tagSizeChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            sn.setValue(6, sn.tagSize)
//            emojiText.font = emojiText.font.withSize(6)
//            break
//        case 1:
//            sn.setValue(8, sn.tagSize)
//            emojiText.font = emojiText.font.withSize(8)
//            break
//        case 2:
//            sn.setValue(10, sn.tagSize)
//            emojiText.font = emojiText.font.withSize(10)
//            break
//        case 3:
//            sn.setValue(12, sn.tagSize)
//            emojiText.font = emojiText.font.withSize(12)
//            break
//        default:
//            sn.setValue(14, sn.tagSize)
//            emojiText.font = emojiText.font.withSize(14)
//        }
//        onViewWillDisappear?()
//    }
//
//    @IBAction func switchShowDatePressed(_ sender: UISwitch) {
//        if sender.isOn {
//            sn.setValue(1, sn.switchShowDate)
//            changeViewState(dateFormatView, 1, true)
//        } else {
//            sn.setValue(0, sn.switchShowDate)
//            changeViewState(dateFormatView, 0.6, false)
//        }
//        updateDateFormat()
//        onViewWillDisappear?()
//    }
//
//    @IBAction func dateFormatChanged(_ sender: UISegmentedControl) {
//        segmentIndexForDate = sender.selectedSegmentIndex
//        sn.setValue(segmentIndexForDate, sn.segmentIndexForDate)
//        updateDateFormat()
//    }
//
//    @IBAction func switchShowHourPressed(_ sender: UISwitch) {
//        if sender.isOn {
//            sn.setValue(1, sn.showHour)
//            changeViewState(hourFormatView, 1, true)
//        } else {
//            sn.setValue(0, sn.showHour)
//            changeViewState(hourFormatView, 0.6, false)
//        }
//        updateHourFormat()
//        onViewWillDisappear?()
//    }
//
//    @IBAction func hourFormatChanged(_ sender: UISegmentedControl) {
//        segmentIndexForHour = sender.selectedSegmentIndex
//        sn.setValue(segmentIndexForHour, sn.segmentIndexForHour)
//        updateHourFormat()
//    }
//
//    @IBAction func textSizeChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            sn.setValue(9, sn.textSize)
//            break
//        case 1:
//            sn.setValue(11, sn.textSize)
//            break
//        case 2:
//            sn.setValue(13, sn.textSize)
//            break
//        case 3:
//            sn.setValue(15, sn.textSize)
//            break
//        case 4:
//            sn.setValue(17, sn.textSize)
//            break
//        case 5:
//            sn.setValue(19, sn.textSize)
//            break
//        default:
//            sn.setValue(21, sn.textSize)
//        }
//        updateTextSize()
//    }
//
//    @IBAction func topViewPressed(_ sender: UIButton) {
//        checkAction()
//    }

    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Helpers
    
    private func style() {
        view.backgroundColor = .white
        
        
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, height: 120)
    }
    
    func assignUserDefaults(){
        textSize = UDM.getCGFloatValue(sn.textSize)
        darkMode = UDM.getIntValue(sn.darkMode)
        segmentIndexForDate = UDM.getIntValue(sn.segmentIndexForDate)
        segmentIndexForHour = UDM.getIntValue(sn.segmentIndexForHour)
    }
    
    func checkAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //segmented controls are different from other elements
    //if text size update firstly, only foregroundColor property being update, text size become default
    //for this reason, color and text size should updated same time
    func updateTextAndColorForSegmentedControls(){
//        updateSegmentedControlColor(dateFormatSegmentedControl)
//        updateSegmentedControlColor(hourFormatSegmentedControl)
//        updateSegmentedControlColor(textSegmentedControl)
//        updateSegmentedControlColor(tagSizeSegmentedControl)
    }
    
    func updateSegmentedControlColor(_ segmentedControl: UISegmentedControl) {
        let color = darkMode == 1 ? Colors.cellLight! : Colors.cellDark!
        segmentedControl.setTitleTextAttributes([.foregroundColor: color, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: Colors.cellDark!], for: .selected)
    }

    func updateCornerRadius(){
//        setViewCornerRadius(textView, 12)
//        setViewCornerRadius(showLabelView, 8)
//        setViewCornerRadius(showDateView, 8)
//        setViewCornerRadius(dateFormatView, 8)
//        setViewCornerRadius(hourFormatView, 8)
//        setViewCornerRadius(showHourView, 8)
//        setViewCornerRadius(textSizeView, 8)
//        setViewCornerRadius(tagSizeView, 8)
    }
    
    func updateColor() {
        updateTextAndColorForSegmentedControls()
//
//        updateViewColor(showLabelView)
//        updateViewColor(showDateView)
//        updateViewColor(dateFormatView)
//        updateViewColor(hourFormatView)
//        updateViewColor(showHourView)
//        updateViewColor(textSizeView)
//        updateViewColor(tagSizeView)
//
//        updateLabelColor(labelShowTag)
//        updateLabelColor(labelShowDate)
//        updateLabelColor(labelDateFormat)
//        updateLabelColor(labelHourFormat)
//        updateLabelColor(labelShowHour)
//        updateLabelColor(labelTextSize)
//        updateLabelColor(labelTagSize)
//
//        textView.backgroundColor = (darkMode == 1 ? Colors.textDark : .white)
    }
    
    func setViewCornerRadius(_ view: UIView, _ number: Int){
        view.layer.cornerRadius = CGFloat(number)
    }
    
    func updateViewColor(_ view:UIView){
        let color = (darkMode == 1 ? Colors.cellDark : Colors.cellLight)
        view.backgroundColor = color
    }
    
    func updateLabelColor(_ label:UILabel){
        let color = (darkMode == 1 ? Colors.textLight : Colors.textDark)
        label.textColor = color
    }

    func updateTextSize() {
        textSize = UDM.getCGFloatValue(sn.textSize) //textSizeChanged
        
//        updateLabelSize(labelShowTag)
//        updateLabelSize(labelShowDate)
//        updateLabelSize(labelDateFormat)
//        updateLabelSize(labelHourFormat)
//        updateLabelSize(labelShowHour)
//        updateLabelSize(labelTextSize)
//        updateLabelSize(labelTagSize)
//        updateLabelSize(dateFormatText)
//        updateLabelSize(labelShowTag)
//
//        deleteAllNotesButton.titleLabel?.font =  deleteAllNotesButton.titleLabel?.font.withSize(textSize)
//        emojiText.font = emojiText.font.withSize(sn.getCGFloatValue(sn.tagSize))
        updateTextAndColorForSegmentedControls()
    }
    
    func updateLabelSize(_ label:UILabel){
        label.font = label.font.withSize(textSize)
    }

    func updateDateFormat() {
//        switch segmentIndexForDate {
//        case 0:
//            dateFormatLabel.text = "Sunday, May 2, 1999"
//            sn.setValue("EEEE, MMM d, yyyy", sn.selectedDateFormat)
//            break
//        case 1:
//            dateFormatLabel.text = "Sunday, 2 May 1999"
//            sn.setValue("EEEE, d MMM yyyy", sn.selectedDateFormat)
//            break
//        case 2:
//            dateFormatLabel.text = "05/02/1999"
//            sn.setValue("MM/dd/yyyy", sn.selectedDateFormat)
//            break
//        default:
//            dateFormatLabel.text = "02/05/1999"
//            sn.setValue("dd/MM/yyyy", sn.selectedDateFormat)
//        }
        updateTimeFormat()
    }
    
    func updateHourFormat(){
        switch segmentIndexForHour {
        case 0:
            UDM.setValue("hh:mm a", sn.selectedHourFormat)
        default:
            UDM.setValue("HH:mm", sn.selectedHourFormat)
        }
        updateTimeFormat()
    }
    
    func updateTimeFormat() {
//        let hourFormat = sn.getStringValue(sn.selectedHourFormat)
//        let dateFormat = sn.getStringValue(sn.selectedDateFormat)
        
//        if switchShowDate.isOn {
//            if switchShowHour.isOn {
//                sn.setValue(hourFormat + ", " + dateFormat, sn.selectedTimeFormat)
//            } else {
//                sn.setValue(dateFormat, sn.selectedTimeFormat)
//            }
//        } else {
//            if switchShowHour.isOn {
//                sn.setValue(hourFormat, sn.selectedTimeFormat)
//            } else {
//                sn.setValue("", sn.selectedTimeFormat)
//            }
//        }
    }
    
    func setDefault(){
//        dateFormatSegmentedControl.selectedSegmentIndex = segmentIndexForDate
//        hourFormatSegmentedControl.selectedSegmentIndex = segmentIndexForHour
//
//        switch textSize {
//        case 9:
//            textSegmentedControl.selectedSegmentIndex = 0
//            break
//        case 11:
//            textSegmentedControl.selectedSegmentIndex = 1
//            break
//        case 13:
//            textSegmentedControl.selectedSegmentIndex = 2
//            break
//        case 15:
//            textSegmentedControl.selectedSegmentIndex = 3
//            break
//        case 17:
//            textSegmentedControl.selectedSegmentIndex = 4
//            break
//        case 19:
//            textSegmentedControl.selectedSegmentIndex = 5
//            break
//        default:
//            textSegmentedControl.selectedSegmentIndex = 6
//        }
//
//        switch sn.getIntValue(sn.tagSize) {
//        case 6:
//            tagSizeSegmentedControl.selectedSegmentIndex = 0
//            break
//        case 8:
//            tagSizeSegmentedControl.selectedSegmentIndex = 1
//            break
//        case 10:
//            tagSizeSegmentedControl.selectedSegmentIndex = 2
//            break
//        case 12:
//            tagSizeSegmentedControl.selectedSegmentIndex = 3
//            break
//        default:
//            tagSizeSegmentedControl.selectedSegmentIndex = 4
//        }
//
//        switch sn.getIntValue(sn.segmentIndexForDate) {
//        case 0:
//            dateFormatLabel.text = "Sunday, May 2, 1999"
//            break
//        case 1:
//            dateFormatLabel.text = "Sunday, 2 May 1999"
//            break
//        case 2:
//            dateFormatLabel.text = "05/02/1999"
//            break
//        default:
//            dateFormatLabel.text = "02/05/1999"
//        }
//
//        if sn.getIntValue(sn.switchShowLabel) == 1 {
//            switchShowLabel.isOn = true
//            changeViewState(tagSizeView, 1, true)
//        } else {
//            switchShowLabel.isOn = false
//            changeViewState(tagSizeView, 0.6, false)
//        }
//
//        if sn.getIntValue(sn.switchShowDate) == 1 {
//            switchShowDate.isOn = true
//            changeViewState(dateFormatView, 1, true)
//        } else {
//            switchShowDate.isOn = false
//            changeViewState(dateFormatView, 0.6, false)
//        }
//
//        if sn.getIntValue(sn.showHour) == 1 {
//            switchShowHour.isOn = true
//            changeViewState(hourFormatView, 1, true)
//        } else {
//            switchShowHour.isOn = false
//            changeViewState(hourFormatView, 0.6, false)
//        }
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

extension OtherSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        let note = sn.itemArray[indexPath.row]
        cell.note = note
        return cell
    }
    
    
}
