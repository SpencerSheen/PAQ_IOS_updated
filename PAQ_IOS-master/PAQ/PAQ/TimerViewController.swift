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
    
    @IBOutlet weak var timerbar: UINavigationBar!
    @IBOutlet weak var difficultyview: UIView!
    @IBOutlet weak var timepickerview: UIView!
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
        }
    }
    
    /*
     * When start button is pressed, hide everything except the time ring circle, time label. Start button becomes
     * the cancel button.
     * Send time that timer will end through BLE
     */
    @IBAction func start_btn(_ sender: Any) {
        if (currPeripheral == nil || currPeripheral.state != .connected) {
            showToast(message: "Connect to a PAQ device to make changes")
        }
        else{
            if state == false {
                time = time_picker.countDownDuration
                time_picker.isHidden = true
                timepickerview.isHidden = true
                difficultyview.isHidden = true
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
                
                //find which difficulty is selected
                var diff = 0
                if easy_clicked == true{
                    diff = 0
                } else if medium_clicked == true{
                    diff = 1
                } else if hard_clicked == true{
                    diff = 2
                }
                
                //send time through BLE
                let svc = tabBarController as! TabBarController
                svc.sendKey = 1
                svc.timerString = getTimeString(timeHour: hours, timeMin: minutes, timeSec: seconds) + String(diff)
                //String(Int(intensity_slider.value))
                currCentral?.connect(currPeripheral, options: nil)
                //svc.sendKey = 0
                //svc.timerSend = false
                
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(clock), userInfo: nil, repeats: true)
            }
                //When cancel button is pressed, show everything except the time ring circle, time label, and cancel button
            else {
                timer.invalidate()
                time = time_picker.countDownDuration
                time_picker.isHidden = false
                timepickerview.isHidden = false
                difficultyview.isHidden = false
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
                
                //send cancel message through BLE
                let svc = tabBarController as! TabBarController
                svc.sendKey = 1
                svc.timerString = "C"
                currCentral?.connect(currPeripheral, options: nil)
            }
        }
    }
    
    /*
     * Animates the time ring and counts down time
     */
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
    

    /*
     * old difficulty slider. NOT CURRENTLY BEING USED
     */
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
        
        //bring top bar to front so layout is better
        self.view.bringSubview(toFront: timerbar)
        //take CBCentral and CBPeripheral value from TabBarController
        let svc = tabBarController as! TabBarController
        currCentral = svc.currCentral
        currPeripheral = svc.currPeripheral
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        intensity_lbl.text = "Easy"
        //length_lbl.text = String(Int(length_slider.value))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Organizing time string in proper form to be sent through BLE
     */
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
     * Send toast message as notification
     */
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/16, y: self.view.frame.size.height-100, width: self.view.frame.size.width*7/8, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
