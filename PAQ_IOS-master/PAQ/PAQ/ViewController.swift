//
//  ViewController.swift
//  PAQ
//
//  Created by Karan Sunil on 2/6/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var duration_slider: UISlider!
    @IBOutlet weak var duration_lbl: UILabel!
    @IBOutlet weak var snoozes_num: UISlider!
    @IBOutlet weak var snoozes_num_lbl: UILabel!
    @IBOutlet weak var intensity_lbl: UILabel!
    @IBOutlet weak var intensity_slider: UISlider!
    @IBOutlet weak var length_lbl: UILabel!
    @IBOutlet weak var length_slider: UISlider!
    @IBOutlet weak var time_picker: UIDatePicker!
    
    //contains data from all alarms
    var alarms: [NSManagedObject] = []
    //var editedAlarm: Any
    
    //determines whether editing or making a new alarm
    var edit = false
    //determines the alarm that is going to be edited in the array
    var index = -1
    
    //BLE data
    var currCentral: CBCentralManager?
    var currPeripheral: CBPeripheral!
    
    /*
     * Handling when each day of the week button is clicked. Switches colors from yellow to grey.
     */
    @IBOutlet weak var monday_button: UIButton!
    var monday_clicked = false;
    @IBAction func monday_btn(_ sender: Any) {
        if monday_clicked == false{
            monday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            monday_button.setTitleColor(UIColor.black, for: .normal)
            monday_clicked = true
        } else {
            monday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            monday_button.setTitleColor(UIColor.white, for: .normal)
            monday_clicked = false
        }
    }
    
    @IBOutlet weak var tuesday_button: UIButton!
    var tuesday_clicked = false;
    @IBAction func tuesday_btn(_ sender: Any) {
        if tuesday_clicked == false{
            tuesday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            tuesday_button.setTitleColor(UIColor.black, for: .normal)
            tuesday_clicked = true
        } else {
            tuesday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            tuesday_button.setTitleColor(UIColor.white, for: .normal)
            tuesday_clicked = false
        }
    }
    
    @IBOutlet weak var wednesday_button: UIButton!
    var wednesday_clicked = false;
    @IBAction func wednesday_btn(_ sender: Any) {
        if wednesday_clicked == false{
            wednesday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            wednesday_button.setTitleColor(UIColor.black, for: .normal)
            wednesday_clicked = true
        } else {
            wednesday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            wednesday_button.setTitleColor(UIColor.white, for: .normal)
            wednesday_clicked = false
        }
    }
    
    @IBOutlet weak var thursday_button: UIButton!
    var thursday_clicked = false;
    @IBAction func thursday_btn(_ sender: Any) {
        if thursday_clicked == false{
            thursday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            thursday_button.setTitleColor(UIColor.black, for: .normal)
            thursday_clicked = true
        } else {
            thursday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            thursday_button.setTitleColor(UIColor.white, for: .normal)
            thursday_clicked = false
        }
    }
    
    @IBOutlet weak var friday_button: UIButton!
    var friday_clicked = false;
    @IBAction func friday_btn(_ sender: Any) {
        if friday_clicked == false{
            friday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            friday_button.setTitleColor(UIColor.black, for: .normal)
            friday_clicked = true
        } else {
            friday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            friday_button.setTitleColor(UIColor.white, for: .normal)
            friday_clicked = false
        }
    }
    
    @IBOutlet weak var saturday_button: UIButton!
    var saturday_clicked = false;
    @IBAction func saturday_btn(_ sender: Any) {
        if saturday_clicked == false{
            saturday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            saturday_button.setTitleColor(UIColor.black, for: .normal)
            saturday_clicked = true
        } else {
            saturday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            saturday_button.setTitleColor(UIColor.white, for: .normal)
            saturday_clicked = false
        }
    }
    
    @IBOutlet weak var sunday_button: UIButton!
    var sunday_clicked = false;
    @IBAction func sunday_btn(_ sender: Any) {
        if sunday_clicked == false{
            sunday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            sunday_button.setTitleColor(UIColor.black, for: .normal)
            sunday_clicked = true
        } else {
            sunday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            sunday_button.setTitleColor(UIColor.white, for: .normal)
            sunday_clicked = false
        }
    }
    
    @IBOutlet weak var snoozeToggleVar: UISwitch!
    var snoozeOn = 1
    
    /*
     * Track snooze toggle on
     */
    @IBAction func toggleSnooze(_ sender: UISwitch) {
        if(sender.isOn){
            snoozeOn = 1
        }
        else{
            snoozeOn = 0
        }
        
    }
    
    
    @IBOutlet weak var hard_button: UIButton!
    @IBOutlet weak var medium_button: UIButton!
    @IBOutlet weak var easy_button: UIButton!
    
    var easy_clicked = false
    var medium_clicked = false
    var hard_clicked = false
    var diffValue = 3
    
    /*
     * When easy button is clicked, set easy button to yellow and set rest of buttons to dark grey.
     */
    @IBAction func easy_click(_ sender: Any) {
        if easy_clicked == false{
            easy_button.borderColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            medium_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            hard_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            easy_clicked = true
            medium_clicked = false
            hard_clicked = false
            diffValue = 0
        }
        else{
            easy_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            easy_clicked = false
            diffValue = 3
        }
    }
    
    /*
     * When medium button is clicked, set medium button to yellow and set rest of buttons to dark grey.
     */
    @IBAction func medium_click(_ sender: Any) {
        if medium_clicked == false{
            medium_button.borderColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            easy_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            hard_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            medium_clicked = true
            easy_clicked = false
            hard_clicked = false
            diffValue = 1
        }
        else{
            medium_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            medium_clicked = false
            diffValue = 3
        }
    }
    
    /*
     * When hard button is clicked, set hard button to yellow and set rest of buttons to dark grey.
     */
    @IBAction func hard_click(_ sender: Any) {
        if hard_clicked == false{
            hard_button.borderColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            medium_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            easy_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            easy_clicked = false
            medium_clicked = false
            hard_clicked = true
            diffValue = 2
        }
        else{
            hard_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
            hard_clicked = false
            diffValue = 3
        }
    }


    /*
     * Segue back to tab bar controller
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "cancelSegue"{
            //send BLE data to tab bar, nothing is sent
            /*let homeController = segue.destination as! TabBarController
            homeController.currCentral = currCentral
            homeController.currPeripheral = currPeripheral*/
        }
        
        if segue.identifier == "saveSegue"{
            //send BLE data to tab bar
            let homeController = segue.destination as! TabBarController
            homeController.alreadySent = true
            //homeController.sendKey = 2
            //homeController.alarmIndex = index
            
            let time = get_time()
            let repeat_days = [monday_clicked,tuesday_clicked, wednesday_clicked,thursday_clicked,friday_clicked,saturday_clicked,sunday_clicked]
            //let alarm_o = ["time": time, "repeat": repeat_days, "duration":Int(duration_slider.value), "snoozes":Int(snoozes_num.value), "intensity":Int(intensity_slider.value), "length":Int(length_slider.value)] as [String : Any]
            
            //accessing core data
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "AlarmList", in: managedContext)
            //RUNS WHEN EDITING ALARM
            if(edit){
                var request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
                do{
                    let editedAlarm = try managedContext.fetch(request)
                    print("Edited length: " + String(editedAlarm.count))
                    //setting up edited contents
                    let newAlarm = editedAlarm[index] as! NSManagedObject
                    newAlarm.setValue(time, forKeyPath: "time")
                    newAlarm.setValue(repeat_days, forKeyPath: "days")
                    newAlarm.setValue(snoozeOn, forKeyPath: "snoozes")
                    newAlarm.setValue(diffValue, forKeyPath: "interactivity")
                    //newAlarm.setValue(Int(duration_slider.value), forKeyPath: "duration")
                    do {
                        //send new data through bluetooth
                        currCentral?.connect(currPeripheral, options: nil)
                        //saves changes to coredata
                        try managedContext.save()
                    } catch {
                        print("Could not save")
                    }
                } catch {
                    print("Could not fetch")
                }
                
                request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tracking")
                do{
                    let trackEdit = try managedContext.fetch(request)
                    
                    //setting up edited contents
                    let toggle = trackEdit[0] as! NSManagedObject
                    toggle.setValue(toggle.value(forKeyPath:"alarmedited") as! Int + 1, forKeyPath: "alarmedited")
                    do {
                        //saves changes to coredata
                        try managedContext.save()
                    } catch {
                        print("Could not save")
                    }
                } catch {
                    print("Could not fetch")
                }
            }
            //RUNS WHEN MAKING A NEW ALARM
            else{
                let alarm = NSManagedObject(entity: entity!, insertInto: managedContext)
                //setting up new alarm contents
                alarm.setValue(time, forKeyPath: "time")
                alarm.setValue(repeat_days, forKeyPath: "days")
                alarm.setValue(snoozeOn, forKeyPath: "snoozes")
                alarm.setValue(diffValue, forKeyPath: "interactivity")
                //alarm.setValue(Int(duration_slider.value), forKeyPath: "duration")
                
                alarm.setValue(true, forKeyPath: "active")
                var randomNum = Int(arc4random_uniform(1000))
                while(validID(randomNum) == false){
                    print(randomNum)
                    randomNum = Int(arc4random_uniform(1000))
                }
                print(randomNum)
                alarm.setValue(randomNum, forKeyPath: "id")
                do {
                    //tries to save and add to coredata
                    try managedContext.save()
                    alarms.append(alarm)
                    //sends new data to bluetooth
                    currCentral?.connect(currPeripheral, options: nil)
                    print("Alarm length: " + String(alarms.count))
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tracking")
                do{
                    let trackEdit = try managedContext.fetch(request)
                    
                    //setting up edited contents
                    let toggle = trackEdit[0] as! NSManagedObject
                    toggle.setValue(toggle.value(forKeyPath:"alarmcreated") as! Int + 1, forKeyPath: "alarmcreated")
                    do {
                        //saves changes to coredata
                        try managedContext.save()
                    } catch {
                        print("Could not save")
                    }
                } catch {
                    print("Could not fetch")
                }
            }
        }
    }
    
    /*
     * Tracks difficulty with slider. NOT CURRENTLY BEING USED
     */
    @IBAction func intensity_slider_change(_ sender: Any) {
        if Int(intensity_slider.value) == 0 {
            intensity_lbl.text = "Easy"
        }
        else if Int(intensity_slider.value) == 1 {
            intensity_lbl.text = "Medium"
        }
        else if Int(intensity_slider.value) == 2 {
            intensity_lbl.text = "Hard"
        }
    }
    
    /*
     * BOTH FUNCTIONS NOT CURRENTLY BEING USED
     */
    @IBAction func snoozes_num_change(_ sender: Any) {
        snoozes_num_lbl.text = String(Int(snoozes_num.value))
    }
    @IBAction func duration_slider_change(_ sender: Any) {
        duration_lbl.text = String(Int(duration_slider.value))
    }
    
    /*
     * Format alarm from timepicker
     */
    func get_time() -> String{
        let timeFormat = DateFormatter()
        timeFormat.timeStyle = .short
        return (timeFormat.string(from: time_picker.date))
    }
    
    //check to see if current ID number is different from existing ID numbers
    func validID(_ randomNum: Int) -> Bool{
        //getting alarm data
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
        
        do{
            let editedAlarm = try context.fetch(request)
            //loops through all alarm id values
            for alarms in editedAlarm{
                if(Int((alarms as AnyObject).value(forKeyPath: "id") as! Int) == randomNum){
                    return false
                }
            }
        } catch {
            print("Could not fetch")
        }
        return true
    }
    
    /*func setKeyValues(_ value: Int){
        let svc = tabBarController as! TabBarController
        svc.sendKey = value
        if value == 3 {
            svc.alarmIndex = index
        }
        else{
            svc.alarmIndex = -1
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        time_picker.setValue(UIColor.white, forKey: "textColor")
        
        //let svc = tabBarController as! TabBarController
        
        //if editing the alarm, retrieve data and change sliders/time to corresponding data
        if edit == true{
            titleLabel.title = "edit"
            //svc.alarmIndex = index
            //svc.sendKey = 3
            //setKeyValues(3)
            
            //accessing coredata
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
            
            do{
                //retrieves alarm data depending on index value
                var editedAlarm = try context.fetch(request)
                let oldAlarm = editedAlarm[index] as! NSManagedObject
                
                //INTENSITY, DURATION, AND SNOOZES NOT CURRENTLY BEING USED
                //intensity_slider.value = Float(oldAlarm.value(forKeyPath: "interactivity") as! Int)
                //duration_slider.value = Float(oldAlarm.value(forKeyPath: "duration") as! Int)
                //snoozes_num.value = Float(oldAlarm.value(forKeyPath: "snoozes") as! Int)
                
                //retrieve old difficulty value
                let oldDiff = Float(oldAlarm.value(forKeyPath: "interactivity") as! Int)
                if oldDiff == 0{
                    easy_button.borderColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    medium_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    hard_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    easy_clicked = true
                    medium_clicked = false
                    hard_clicked = false
                    diffValue = 0
                }
                else if oldDiff == 1{
                    medium_button.borderColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    easy_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    hard_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    medium_clicked = true
                    easy_clicked = false
                    hard_clicked = false
                    diffValue = 1
                }
                else if oldDiff == 2{
                    hard_button.borderColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    medium_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    easy_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    easy_clicked = false
                    medium_clicked = false
                    hard_clicked = true
                    diffValue = 2
                }
                else{
                    hard_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    medium_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    easy_button.borderColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
                    easy_clicked = false
                    medium_clicked = false
                    hard_clicked = false
                    diffValue = 3
                }
                
                //retreive old snooze value
                let snoozeVal = Float(oldAlarm.value(forKeyPath: "snoozes") as! Int)
                if snoozeVal == 0{
                    snoozeToggleVar.setOn(false, animated: true)
                }
                else{
                    snoozeToggleVar.setOn(true, animated: true)
                }
                
                //retrieve old date and reformat
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                let oldDate = dateFormatter.date(from: oldAlarm.value(forKeyPath:"time") as! String)
                time_picker.date = oldDate!
                
                //retreive old days of the week active
                let days: [Bool] = oldAlarm.value(forKeyPath: "days") as? Array<Bool> ?? []
                if(days[0]){
                    monday_clicked = true
                    monday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    monday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    monday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    monday_button.setTitleColor(UIColor.white, for: .normal)
                }
                
                if(days[1]){
                    tuesday_clicked = true
                    tuesday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    tuesday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    tuesday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    tuesday_button.setTitleColor(UIColor.white, for: .normal)
                }
                
                if(days[2]){
                    wednesday_clicked = true
                    wednesday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    wednesday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    wednesday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    wednesday_button.setTitleColor(UIColor.white, for: .normal)
                }
                
                if(days[3]){
                    thursday_clicked = true
                    thursday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    thursday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    thursday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    thursday_button.setTitleColor(UIColor.white, for: .normal)
                }
                
                if(days[4]){
                    friday_clicked = true
                    friday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    friday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    friday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    friday_button.setTitleColor(UIColor.white, for: .normal)
                }
                
                if(days[5]){
                    saturday_clicked = true
                    saturday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    saturday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    saturday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    saturday_button.setTitleColor(UIColor.white, for: .normal)
                }
                
                if(days[6]){
                    sunday_clicked = true
                    sunday_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
                    sunday_button.setTitleColor(UIColor.black, for: .normal)
                }
                else{
                    sunday_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
                    sunday_button.setTitleColor(UIColor.white, for: .normal)
                }
            } catch {
                print("Could not fetch")
            }
        }
        
        //setting all labels to default/retrived alarm values
        //intensity_lbl.text = "Easy"
        //snoozes_num_lbl.text = String(Int(snoozes_num.value))
        //duration_lbl.text = String(Int(duration_slider.value))
        
        //adjusting date picker to phone time
        time_picker.timeZone = TimeZone.current
        
        //let saved = UserDefaults.standard.dictionary(forKey: "saved alarm")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

