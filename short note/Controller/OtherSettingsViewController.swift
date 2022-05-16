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
    
    //texts
    @IBOutlet weak var text8: UILabel!
    @IBOutlet weak var text9: UILabel!
    @IBOutlet weak var text10: UILabel!
    @IBOutlet weak var text11: UILabel!
    @IBOutlet weak var text12: UILabel!
    @IBOutlet weak var text13: UILabel!
    @IBOutlet weak var text14: UILabel!
    @IBOutlet weak var text15: UILabel!
    
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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    var itemArray = [Item]()
    var sn = ShortNote()

    
    var onViewWillDisappear: (()->())?
    
    override func viewDidLoad() {
        
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        if UserDefaults.standard.integer(forKey: "textSize") == 0 {
            UserDefaults.standard.set(15, forKey: "textSize")
        }

        if UserDefaults.standard.integer(forKey: "tagSize") == 0 {
            UserDefaults.standard.set(10, forKey: "tagSize")
        }
        
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
        
        
        switch UserDefaults.standard.integer(forKey: "allNotes") {
        case 0:
            text14.text = "Show all notes"
            break
        case 1:
            text14.text = "Show last 100 notes"
            break
        case 2:
            text14.text = "Show last 1000 notes"
            break
        default:
            print("nothing")
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
        case 21:
            textSegmentedControl.selectedSegmentIndex = 6
            break
        default:
            print("nothing")
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
        case 14:
            tagSizeSegmentedControl.selectedSegmentIndex = 4
            break
        default:
            print("nothing")
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
        case 3:
            dateFormatLabel.text = (showHour == 0 ? "02/05/1999" : "10:00, 02/05/1999")
            break
        default:
            print("nothing")
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
        case 4:
            UserDefaults.standard.set(14, forKey: "tagSize")
            emojiText.font = emojiText.font.withSize(14)
            break
        default:
            print("nothing")
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
            text14.text = "Show all notes"
            break
        case 1:
            UserDefaults.standard.set(1, forKey: "allNotes")
            text14.text = "Show last 10 notes"
            break
        case 2:
            UserDefaults.standard.set(2, forKey: "allNotes")
            text14.text = "Show last 100 notes"
            break
        case 3:
            UserDefaults.standard.set(3, forKey: "allNotes")
            text14.text = "Show last 1000 notes"
            break
        default:
            print("nothing")
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
        case 6:
            UserDefaults.standard.set(21, forKey: "textSize")
            break
        default:
            print("nothing")
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
        case 6:
            UserDefaults.standard.set(6, forKey: "bgColor")
            break
        default:
            print("nothing")
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
    
    //segmented controls are different from other elements
    //if text size update firstly, only foregroundColor property being update, text size become default
    //for this reason, color and text size should updated same time
    func updateTextAndColorForSegmentedControls(){
        let textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            segmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            segmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellLightColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
            bgSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            bgSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellLightColor, .font: UIFont.systemFont(ofSize: 10),], for: .normal)
            textSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            textSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellLightColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
            allSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            allSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellLightColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
            tagSizeSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            tagSizeSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellLightColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
        } else {
            segmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            segmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
            bgSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            bgSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor, .font: UIFont.systemFont(ofSize: 10),], for: .normal)
            textSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            textSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
            allSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            allSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
            tagSizeSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor], for: .selected)
            tagSizeSegmentedControl.setTitleTextAttributes([.foregroundColor: sn.cellDarkColor, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
        }
    }

    
    func updateColor() {
        
        updateTextAndColorForSegmentedControls()
        if UserDefaults.standard.integer(forKey: "darkMode") == 1 {
            textView.backgroundColor = sn.dark

            showLabelView.backgroundColor = sn.cellDarkColor
            showDateView.backgroundColor = sn.cellDarkColor
            dateFormatView.backgroundColor = sn.cellDarkColor
            showHourView.backgroundColor = sn.cellDarkColor
            textSizeView.backgroundColor = sn.cellDarkColor
            bgColorView.backgroundColor = sn.cellDarkColor
            allView.backgroundColor = sn.cellDarkColor
            tagSizeView.backgroundColor = sn.cellDarkColor

            text8.textColor = sn.cellLightColor
            text9.textColor = sn.cellLightColor
            text10.textColor = sn.cellLightColor
            text11.textColor = sn.cellLightColor
            text12.textColor = sn.cellLightColor
            text13.textColor = sn.cellLightColor
            text14.textColor = sn.cellLightColor
            text15.textColor = sn.cellLightColor

        } else {
            textView.backgroundColor = UIColor.white

            showLabelView.backgroundColor = sn.e5e5ea
            showDateView.backgroundColor = sn.e5e5ea
            dateFormatView.backgroundColor = sn.e5e5ea
            showHourView.backgroundColor = sn.e5e5ea
            textSizeView.backgroundColor = sn.e5e5ea
            bgColorView.backgroundColor = sn.e5e5ea
            allView.backgroundColor = sn.e5e5ea
            tagSizeView.backgroundColor = sn.e5e5ea
            
            
            text8.textColor = sn.cellDarkColor
            text9.textColor = sn.cellDarkColor
            text10.textColor = sn.cellDarkColor
            text11.textColor = sn.cellDarkColor
            text12.textColor = sn.cellDarkColor
            text13.textColor = sn.cellDarkColor
            text14.textColor = sn.cellDarkColor
            text15.textColor = sn.cellDarkColor
       
        }
    }

    func updateTextSize() {

        let textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
        
        text8.font = text8.font.withSize(textSize)
        text9.font = text9.font.withSize(textSize)
        text10.font = text10.font.withSize(textSize)
        text11.font = text11.font.withSize(textSize)
        text12.font = text12.font.withSize(textSize)
        text13.font = text13.font.withSize(textSize)
        text14.font = text14.font.withSize(textSize)
        text15.font = text15.font.withSize(textSize)
        dateFormatText.font = dateFormatText.font.withSize(textSize-4)
        deleteAllNotesButton.titleLabel?.font =  deleteAllNotesButton.titleLabel?.font.withSize(textSize)
       
        emojiText.font = emojiText.font.withSize(CGFloat(UserDefaults.standard.integer(forKey: "tagSize")))
        
        updateTextAndColorForSegmentedControls()
    }


    @IBAction func deleteAllNotesPressed(_ sender: UIButton) {
    }
    

    
    @objc func diss(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
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
        case 3:
            UserDefaults.standard.set(3, forKey: "segmentIndexForDate")
            if showHour == 0 {
                dateFormatLabel.text = "02/05/1999"
                UserDefaults.standard.set("dd/MM/yyyy", forKey: "selectedDateFormat")
            } else {
                dateFormatLabel.text = "10:00, 02/05/1999"
                UserDefaults.standard.set("hh:mm a, dd/MM/yyyy", forKey: "selectedDateFormat")
            }
            break
        default:
            print("nothing")
        }
        onViewWillDisappear?()
    }

    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }
    
    @IBAction func bottomViewPressed(_ sender: UIButton) {
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    func checkAction(){
        self.dismiss(animated: true, completion: nil)
    }
}
