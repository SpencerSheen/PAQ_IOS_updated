//
//  Stopwatch.swift
//  PAQ
//
//  Created by Karan Sunil on 3/5/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit

class Stopwatch: UIViewController {
    
    var seconds = 0
    var minutes = 0
    var hours = 0
    var timer = Timer()
    var is_on = false

    @IBOutlet weak var start_btn: UIButton!
    @IBOutlet weak var stop_btn: UIButton!
    @IBOutlet weak var time_lbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func start_btn(_ sender: Any) {

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clock), userInfo: nil, repeats: true)
        is_on = true
        start_btn.isEnabled = false
        stop_btn.isEnabled = true
        //print(timer)
    }
    
    @objc func clock(){
        time_lbl.text = String(format: "%02d:%02d:%02d", hours,minutes,seconds)
        seconds += 1
        print(seconds)
        if seconds == 60{
            seconds = 0
            minutes += 1
        }
        if minutes == 60{
            minutes = 0
            hours += 1
        }

        
    }
    
    @IBAction func stop_btn(_ sender: Any) {

        timer.invalidate()
        is_on = false
        stop_btn.isEnabled = false
        start_btn.isEnabled = true
    }
    
    @IBAction func reset_btn(_ sender: Any) {
        time_lbl.text = "00:00:00"
        timer.invalidate()
        seconds = 0
        minutes = 0
        hours = 0
        start_btn.isEnabled = true
        stop_btn.isEnabled = true
    }
    
}
