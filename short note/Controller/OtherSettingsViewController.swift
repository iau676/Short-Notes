//
//  OtherSettingsViewController.swift
//  short note
//
//  Created by ibrahim uysal on 8.03.2022.
//
import UIKit
import CoreData

class OtherSettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstView: UIView!
    
    @IBOutlet weak var darkView: UIView!
    var tapGesture = UITapGestureRecognizer()
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var showLabelView: UIView!
    @IBOutlet weak var showDateView: UIView!
    @IBOutlet weak var dateFormatView: UIView!
    @IBOutlet weak var showHourView: UIView!
    @IBOutlet weak var bgColorView: UIView!
    @IBOutlet weak var textSizeView: UIView!
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var tagSizeView: UIView!
    
    @IBOutlet weak var labelShowTag: UILabel!
    @IBOutlet weak var labelShowDate: UILabel!
    @IBOutlet weak var labelDateFormat: UILabel!
    @IBOutlet weak var labelShowHour: UILabel!
    @IBOutlet weak var labelBgColor: UILabel!
    @IBOutlet weak var labelTextSize: UILabel!
    @IBOutlet weak var labelAllNotes: UILabel!
    @IBOutlet weak var labelTagSize: UILabel!
    
    @IBOutlet weak var emojiText: UILabel!
    @IBOutlet weak var dateFormatText: UILabel!
    @IBOutlet weak var deleteAllNotesButton: UIButton!
    
    @IBOutlet weak var switchShowLabel: UISwitch!
    @IBOutlet weak var switchShowDate: UISwitch!
    @IBOutlet weak var switchShowHour: UISwitch!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var bgSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textSegmentedControl: UISegmentedControl!
    @IBOutlet weak var allSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tagSizeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var dateFormatLabel: UILabel!
    
    var segmentIndexForUpdateHour = 0
    var segmentNumber = 0
    var goEdit = 0
    var editIndex = 0
    var labelName = ""
    var isOpen = false
    
    var itemArray = [Item]()
    var sn = ShortNote()
    var onViewWillDisappear: (()->())?
    
    var textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
    let darkMode = UserDefaults.standard.integer(forKey: "darkMode")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        textView.layer.cornerRadius = 12
        showLabelView.layer.cornerRadius = 8
        showDateView.layer.cornerRadius = 8
        dateFormatView.layer.cornerRadius = 8
        showHourView.layer.cornerRadius = 8
        bgColorView.layer.cornerRadius = 8
        textSizeView.layer.cornerRadius = 8
        allView.layer.cornerRadius = 8
        tagSizeView.layer.cornerRadius = 8
                
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "segmentIndexForDate")
        segmentIndexForUpdateHour = UserDefaults.standard.integer(forKey: "segmentIndexForDate")
        bgSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "bgColor")
        allSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "allNotes")
        
        setupDefault()
        updateTextSize()
        updateColor()
    }

    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onViewWillDisappear?()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        if segue.identifier == "goDelete" {
            if segue.destination is DeleteNotesViewController {
                (segue.destination as? DeleteNotesViewController)?.onViewWillDisappear = {
                    self.onViewWillDisappear?()
                }
            }
        }
    }
    
    //MARK: - IBAction

    @IBAction func switchShowLabelPressed(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "switchShowLabel")
            UIView.transition(with: tagSizeView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.tagSizeView.isHidden = false
                          })
        } else {
            UserDefaults.standard.set(1, forKey: "switchShowLabel")
            UIView.transition(with: tagSizeView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.tagSizeView.isHidden = true
                          })
        }
        onViewWillDisappear?()
    }
    
    @IBAction func tagSizeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(6, forKey: "tagSize")
            emojiText.font = emojiText.font.withSize(6)
            break
        case 1:
            UserDefaults.standard.set(8, forKey: "tagSize")
            emojiText.font = emojiText.font.withSize(8)
            break
        case 2:
            UserDefaults.standard.set(10, forKey: "tagSize")
            emojiText.font = emojiText.font.withSize(10)
            break
        case 3:
            UserDefaults.standard.set(12, forKey: "tagSize")
            emojiText.font = emojiText.font.withSize(12)
            break
        default:
            UserDefaults.standard.set(14, forKey: "tagSize")
            emojiText.font = emojiText.font.withSize(14)
        }
        onViewWillDisappear?()
    }
    
    
    @IBAction func switchShowDatePressed(_ sender: UISwitch) {

        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "switchShowDate")
            UIView.transition(with: dateFormatView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.dateFormatView.isHidden = false
                          })

        } else {
            UserDefaults.standard.set(1, forKey: "switchShowDate")
            UIView.transition(with: dateFormatView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.dateFormatView.isHidden = true
                          })
        }
        onViewWillDisappear?()

    }
    
    @IBAction func dateFormatChanged(_ sender: UISegmentedControl) {
        segmentIndexForUpdateHour = sender.selectedSegmentIndex
        updateDateFormat(segmentIndexForUpdateHour)
    }
    
    @IBAction func allChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(0, forKey: "allNotes")
            labelAllNotes.text = "Show all notes"
            break
        case 1:
            UserDefaults.standard.set(1, forKey: "allNotes")
            labelAllNotes.text = "Show last 10 notes"
            break
        case 2:
            UserDefaults.standard.set(2, forKey: "allNotes")
            labelAllNotes.text = "Show last 100 notes"
            break
        default:
            UserDefaults.standard.set(3, forKey: "allNotes")
            labelAllNotes.text = "Show last 1000 notes"
        }
    }
    
    
    @IBAction func textSizeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(9, forKey: "textSize")
            break
        case 1:
            UserDefaults.standard.set(11, forKey: "textSize")
            break
        case 2:
            UserDefaults.standard.set(13, forKey: "textSize")
            break
        case 3:
            UserDefaults.standard.set(15, forKey: "textSize")
            break
        case 4:
            UserDefaults.standard.set(17, forKey: "textSize")
            break
        case 5:
            UserDefaults.standard.set(19, forKey: "textSize")
            break
        default:
            UserDefaults.standard.set(21, forKey: "textSize")
        }
        
        updateTextSize()
    }
    
    @IBAction func bgColorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(0, forKey: "bgColor")
            break
        case 1:
            UserDefaults.standard.set(1, forKey: "bgColor")
            break
        case 2:
            UserDefaults.standard.set(2, forKey: "bgColor")
            break
        case 3:
            UserDefaults.standard.set(3, forKey: "bgColor")
            break
        case 4:
            UserDefaults.standard.set(4, forKey: "bgColor")
            break
        case 5:
            UserDefaults.standard.set(5, forKey: "bgColor")
            break
        default:
            UserDefaults.standard.set(6, forKey: "bgColor")
        }
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "bgColor"), forKey: "lastBgColor")
        onViewWillDisappear?()
    }
    
    @IBAction func switchShowHourPressed(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(1, forKey: "showHour")
        } else {
            UserDefaults.standard.set(0, forKey: "showHour")
        }
        updateDateFormat(segmentIndexForUpdateHour)
    }
    

    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }
    
    @IBAction func bottomViewPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Other Functions
    
    func checkAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //segmented controls are different from other elements
    //if text size update firstly, only foregroundColor property being update, text size become default
    //for this reason, color and text size should updated same time
    func updateTextAndColorForSegmentedControls(){
            updateSegmentedControlColor(segmentedControl)
            updateSegmentedControlColor(bgSegmentedControl)
            updateSegmentedControlColor(textSegmentedControl)
            updateSegmentedControlColor(allSegmentedControl)
            updateSegmentedControlColor(tagSizeSegmentedControl)
    }
    
    func updateSegmentedControlColor(_ segmentedControl: UISegmentedControl) {
        
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(named: "colorCellDark")!], for: .selected)
        
        let color = darkMode == 1 ? UIColor(named: "colorCellLight")! : UIColor(named: "colorCellDark")!
        
        if darkMode == 1 {
            segmentedControl.setTitleTextAttributes([.foregroundColor: color, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
        } else {
            segmentedControl.setTitleTextAttributes([.foregroundColor:color, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
        }
    }

    
    func updateColor() {
        
        updateTextAndColorForSegmentedControls()
        
        updateViewColor(showLabelView)
        updateViewColor(showDateView)
        updateViewColor(dateFormatView)
        updateViewColor(showHourView)
        updateViewColor(textSizeView)
        updateViewColor(bgColorView)
        updateViewColor(allView)
        updateViewColor(tagSizeView)
        
        updateLabelColor(labelShowTag)
        updateLabelColor(labelShowDate)
        updateLabelColor(labelDateFormat)
        updateLabelColor(labelShowHour)
        updateLabelColor(labelBgColor)
        updateLabelColor(labelTextSize)
        updateLabelColor(labelAllNotes)
        updateLabelColor(labelTagSize)
        
        textView.backgroundColor = (darkMode == 1 ? UIColor(named: "colorTextDark") : .white)
   
    }
    
    func updateViewColor(_ view:UIView){
        let color = (darkMode == 1 ? UIColor(named: "colorCellDark") : UIColor(named: "colorCellLight"))
        view.backgroundColor = color
    }
    
    func updateLabelColor(_ label:UILabel){
        let color = (darkMode == 1 ? UIColor(named: "colorTextLight") : UIColor(named: "colorTextDark"))
        label.textColor = color
    }

    func updateTextSize() {
        
        textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize")) //textSizeChanged
        
        updateLabelSize(labelShowTag)
        updateLabelSize(labelShowDate)
        updateLabelSize(labelDateFormat)
        updateLabelSize(labelShowHour)
        updateLabelSize(labelBgColor)
        updateLabelSize(labelTextSize)
        updateLabelSize(labelAllNotes)
        updateLabelSize(labelTagSize)
        updateLabelSize(dateFormatText)
        updateLabelSize(labelShowTag)
     
        deleteAllNotesButton.titleLabel?.font =  deleteAllNotesButton.titleLabel?.font.withSize(textSize)
        emojiText.font = emojiText.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "tagSize")))
        updateTextAndColorForSegmentedControls()
    }
    
    func updateLabelSize(_ label:UILabel){
        label.font = label.font.withSize(textSize)
    }

    
    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - updateDateFormat
    func updateDateFormat(_ index: Int) {
        let showHour = UserDefaults.standard.integer(forKey: "showHour")

        switch segmentIndexForUpdateHour {
        case 0:
            UserDefaults.standard.set(0, forKey: "segmentIndexForDate")
            if showHour == 0 {
                dateFormatLabel.text = "Sunday, May 2, 1999"
                UserDefaults.standard.set("EEEE, MMM d, yyyy", forKey: "selectedDateFormat")
            } else {
                dateFormatLabel.text = "10:00, Sunday, May 2, 1999"
                UserDefaults.standard.set("hh:mm a, EEEE, MMM d, yyyy", forKey: "selectedDateFormat")
            }
            break
        case 1:
            UserDefaults.standard.set(1, forKey: "segmentIndexForDate")
            if showHour == 0 {
                dateFormatLabel.text = "Sunday, 2 May 1999"
                UserDefaults.standard.set("EEEE, d MMM, yyyy", forKey: "selectedDateFormat")
            } else {
                dateFormatLabel.text = "10:00, Sunday, 2 May 1999"
                UserDefaults.standard.set("hh:mm a, EEEE, d MMM, yyyy", forKey: "selectedDateFormat")
            }
            break
        case 2:
            UserDefaults.standard.set(2, forKey: "segmentIndexForDate")
            if showHour == 0 {
                dateFormatLabel.text = "05/02/1999"
                UserDefaults.standard.set("MM/dd/yyyy", forKey: "selectedDateFormat")
            } else {
                dateFormatLabel.text = "10:00, 05/02/1999"
                UserDefaults.standard.set("hh:mm a, MM/dd/yyyy", forKey: "selectedDateFormat")
            }
            break
        default:
            UserDefaults.standard.set(3, forKey: "segmentIndexForDate")
            if showHour == 0 {
                dateFormatLabel.text = "02/05/1999"
                UserDefaults.standard.set("dd/MM/yyyy", forKey: "selectedDateFormat")
            } else {
                dateFormatLabel.text = "10:00, 02/05/1999"
                UserDefaults.standard.set("hh:mm a, dd/MM/yyyy", forKey: "selectedDateFormat")
            }
        }
        onViewWillDisappear?()
    }
    
    //MARK: - setupDefault
    func setupDefault(){
        
        if UserDefaults.standard.integer(forKey: "textSize") == 0 {
            UserDefaults.standard.set(15, forKey: "textSize")
        }

        if UserDefaults.standard.integer(forKey: "tagSize") == 0 {
            UserDefaults.standard.set(10, forKey: "tagSize")
        }
        
        switch UserDefaults.standard.integer(forKey: "allNotes") {
        case 0:
            labelAllNotes.text = "Show all notes"
            break
        case 1:
            labelAllNotes.text = "Show last 10 notes"
            break
        case 2:
            labelAllNotes.text = "Show last 100 notes"
            break
        default:
            labelAllNotes.text = "Show last 1000 notes"
        }
        
        switch UserDefaults.standard.integer(forKey: "textSize") {
        case 9:
            textSegmentedControl.selectedSegmentIndex = 0
            break
        case 11:
            textSegmentedControl.selectedSegmentIndex = 1
            break
        case 13:
            textSegmentedControl.selectedSegmentIndex = 2
            break
        case 15:
            textSegmentedControl.selectedSegmentIndex = 3
            break
        case 17:
            textSegmentedControl.selectedSegmentIndex = 4
            break
        case 19:
            textSegmentedControl.selectedSegmentIndex = 5
            break
        default:
            textSegmentedControl.selectedSegmentIndex = 6
        }
        
        switch UserDefaults.standard.integer(forKey: "tagSize") {
        case 6:
            tagSizeSegmentedControl.selectedSegmentIndex = 0
            break
        case 8:
            tagSizeSegmentedControl.selectedSegmentIndex = 1
            break
        case 10:
            tagSizeSegmentedControl.selectedSegmentIndex = 2
            break
        case 12:
            tagSizeSegmentedControl.selectedSegmentIndex = 3
            break
        default:
            tagSizeSegmentedControl.selectedSegmentIndex = 4
        }
        
        
        let showHour =  UserDefaults.standard.integer(forKey: "showHour")

        switch UserDefaults.standard.integer(forKey: "segmentIndexForDate") {
        case 0:
            dateFormatLabel.text = (showHour == 0 ? "Sunday, May 2, 1999" : "10:00, Sunday, May 2, 1999")
            break
        case 1:
            dateFormatLabel.text =  (showHour == 0 ? "Sunday, 2 May 1999" : "10:00, Sunday, 2 May 1999")
            break
        case 2:
            dateFormatLabel.text =  (showHour == 0 ? "05/02/1999" : "10:00, 05/02/1999")
            break
        default:
            dateFormatLabel.text = (showHour == 0 ? "02/05/1999" : "10:00, 02/05/1999")
        }
        
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchShowDate") == 1 {
            switchShowDate.isOn = false
            dateFormatView.isHidden = true
        } else {
            switchShowDate.isOn = true
            dateFormatView.isHidden = false
        }
        
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchShowLabel") == 1 {
            switchShowLabel.isOn = false
            tagSizeView.isHidden = true
        } else {
            switchShowLabel.isOn = true
            tagSizeView.isHidden = false
        }
        
        // 1 is false, 0 is true
        if UserDefaults.standard.integer(forKey: "switchShowLabel") == 1 {
            switchShowLabel.isOn = false
        } else {
            switchShowLabel.isOn = true
        }
        
        // 1 is true, 0 is false
        if UserDefaults.standard.integer(forKey: "showHour") == 1 {
            switchShowHour.isOn = true
        } else {
            switchShowHour.isOn = false
        }
    }
}
