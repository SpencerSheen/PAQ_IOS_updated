//
//  TimerViewController.swift
//  
//
//  Created by Karan Sunil on 4/15/18.
//

import UIKit
import UICircularProgressRing
import CoreBluetooth

class TimerViewController: UIViewController {
    var currCentral: CBCentralManager?
    var currPeripheral: CBPeripheral!
    
    @IBOutlet weak var time_picker: UIDatePicker!
    
    @IBOutlet weak var length_lbl: UILabel!
    @IBOutlet weak var length_slider: UISlider!
    @IBOutlet weak var intensity_lbl: UILabel!
    @IBOutlet weak var intensity_slider: UISlider!
    @IBOutlet weak var progress_ring: UICircularProgressRingView!
    @IBOutlet weak var start_b: UIButton!
    @IBOutlet weak var interact_lbl: UILabel!
    @IBOutlet weak var inten_lbl: UILabel!
    @IBOutlet weak var len_lbl: UILabel!
    @IBOutlet weak var time_lbl: UILabel!
    
    @IBOutlet weak var hard_button: UIButton!
    @IBOutlet weak var medium_button: UIButton!
    @IBOutlet weak var easy_button: UIButton!
    var seconds = 0
    var minutes = 0
    var hours = 0
    var timer = Timer()
    var time = 0.0
    var temp = 0

    var state = false
    
    var easy_clicked = true
    var medium_clicked = false
    var hard_clicked = false
    @IBAction func easy_click(_ sender: Any) {
        if easy_clicked == false{
            easy_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            easy_button.setTitleColor(UIColor.black, for: .normal)
            medium_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            medium_button.setTitleColor(UIColor.white, for: .normal)
            hard_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            hard_button.setTitleColor(UIColor.white, for: .normal)
            easy_clicked = true
            medium_clicked = false
            hard_clicked = false
        }
    }
    @IBAction func medium_click(_ sender: Any) {
        if medium_clicked == false{
            medium_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            medium_button.setTitleColor(UIColor.black, for: .normal)
            easy_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            easy_button.setTitleColor(UIColor.white, for: .normal)
            hard_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            hard_button.setTitleColor(UIColor.white, for: .normal)
            medium_clicked = true
            easy_clicked = false
            hard_clicked = false
        }
    }
    @IBAction func hard_click(_ sender: Any) {
        if hard_clicked == false{
            hard_button.backgroundColor = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
            hard_button.setTitleColor(UIColor.black, for: .normal)
            medium_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            medium_button.setTitleColor(UIColor.white, for: .normal)
            easy_button.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            easy_button.setTitleColor(UIColor.white, for: .normal)
            easy_clicked = false
            medium_clicked = false
            hard_clicked = true
        }
    }
    
    
    @IBAction func start_btn(_ sender: Any) {
        if state == false {
            time = time_picker.countDownDuration
            time_picker.isHidden = true
            //length_slider.isHidden = true
            //length_lbl.isHidden = true
            intensity_lbl.isHidden = true
            intensity_slider.isHidden = true
            progress_ring.isHidden = false
            interact_lbl.isHidden = true
            easy_button.isHidden = true
            medium_button.isHidden = true
            hard_button.isHidden = true
            //inten_lbl.isHidden = true
            //len_lbl.isHidden = true
            time_lbl.isHidden = false
            start_b.setTitle("Cancel", for: .normal)
        
            progress_ring.maxValue = CGFloat(time)
            print(progress_ring.maxValue)
            progress_ring.minValue = 0.0
            progress_ring.value = CGFloat(time)

            hours = (Int(time)) / 3600
            temp = (Int(time)) % 3600
            minutes = temp / 60
            temp = temp % 60
            seconds = temp
            progress_ring.shouldShowValueText = false
            time_lbl.text = String(format: "%02d:%02d:%02d", hours,minutes,seconds)
            state = true

            var diff = 0
            if easy_clicked == true{
                diff = 0
            } else if medium_clicked == true{
                diff = 1
            } else if hard_clicked == true{
                diff = 2
            }
            
            let svc = tabBarController as! TabBarController
            svc.sendKey = 1
            svc.timerString = getTimeString(timeHour: hours, timeMin: minutes, timeSec: seconds) + String(diff)
                //String(Int(intensity_slider.value))
            currCentral?.connect(currPeripheral, options: nil)
            //svc.sendKey = 0
            //svc.timerSend = false

            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(clock), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            time = time_picker.countDownDuration
            time_picker.isHidden = false
            //length_slider.isHidden = false
            //length_lbl.isHidden = false
            //intensity_lbl.isHidden = false
            //intensity_slider.isHidden = false
            progress_ring.isHidden = true
            interact_lbl.isHidden = false
            easy_button.isHidden = false
            medium_button.isHidden = false
            hard_button.isHidden = false
            //inten_lbl.isHidden = false
            //len_lbl.isHidden = false
            time_lbl.isHidden = true
            start_b.setTitle("Start", for: .normal)
            state = false
            
            let svc = tabBarController as! TabBarController
            svc.sendKey = 1
            svc.timerString = "C"
            currCentral?.connect(currPeripheral, options: nil)
        }
        
        
    }
    
    @objc func clock(){
        if((progress_ring.currentValue!) == 0.0){
            timer.invalidate()
            progress_ring.value = progress_ring.currentValue! - CGFloat(0.01)
        }
        hours = (Int(progress_ring.value)) / 3600
        temp = (Int(progress_ring.value)) % 3600
        minutes = temp / 60
        temp = temp % 60
        seconds = temp
        progress_ring.shouldShowValueText = false
        time_lbl.text = String(format: "%02d:%02d:%02d", hours,minutes,seconds)

        
        progress_ring.value = progress_ring.currentValue! - CGFloat(0.01)
    }
    

    
    @IBAction func intensity_action(_ sender: Any) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        time_picker.setValue(UIColor.white, forKey: "textColor")
        time_picker.timeZone = TimeZone.current
        progress_ring.isHidden = true
        progress_ring.shouldShowValueText = false
        time_lbl.isHidden = true
        intensity_lbl.isHidden = true
        intensity_slider.isHidden = true
        
        let svc = tabBarController as! TabBarController
        currCentral = svc.currCentral
        currPeripheral = svc.currPeripheral
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        intensity_lbl.text = "Easy"
        //length_lbl.text = String(Int(length_slider.value))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getTimeString(timeHour:Int, timeMin:Int, timeSec:Int) -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        var hour = components.hour! + timeHour
        var minute = components.minute! + timeMin
        var second = components.second! + timeSec
        
        if(second >= 60){
            second -= 60
            minute += 1
        }
        
        if(minute >= 60){
            minute -= 60
            hour += 1
        }
        
        if(hour >= 24){
            hour -= 24
        }
        
        var hourString = String(hour)
        var minuteString = String(minute)
        var secondString = String(second)
        
        if(hour < 10){
            hourString = "0" + String(hour)
        }
        if(minute < 10){
            minuteString = "0" + String(minute)
        }
        if(second < 10){
            secondString = "0" + String(second)
        }
        
        let today_string = "T" + hourString + minuteString + secondString
        
        return today_string
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
