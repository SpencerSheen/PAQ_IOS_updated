//
//  TableViewCell.swift
//  PAQ
//
//  Created by Karan Sunil on 2/6/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class TableViewCell: UITableViewCell {
    @IBOutlet weak var time_lbl: UILabel!
    @IBOutlet weak var active_toggle: UISwitch!
    @IBOutlet weak var day_lbl: UILabel!
    
    @IBOutlet weak var inv_cell: UIView!
    
    var currCentral: CBCentralManager?
    var currPeripheral: CBPeripheral!
    var svc: TabBarController!
    var message: Home!
    
    var index = 0
    
    /*
     * Edits alarm data, saves to core data, and sends new edit through BLE
     */
    @IBAction func changeToggle(_ sender: UISwitch) {
        
        if (currPeripheral == nil || currPeripheral.state != .connected) {
            if(sender.isOn)
            {
                //active_toggle.setOn(false, animated: false)
            }
            else{
                active_toggle.setOn(true, animated: false)
            }
            message.showToast(message: "Connect to a PAQ device to make changes")
        }
        else{
            //let svc = self.tabBarController as! TabBarController
            svc.sendKey = 3
            svc.alarmIndex = index
            
            //retrieve core data
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
            do{
                let editedAlarm = try managedContext.fetch(request)
                let newAlarm = editedAlarm[index] as! NSManagedObject
                if(sender.isOn)
                {
                    newAlarm.setValue(true, forKeyPath: "active")
                }
                else{
                    newAlarm.setValue(false, forKeyPath: "active")
                }
                print(self.currPeripheral)
                
                //sends new data through bluetooth
                self.currCentral?.connect(self.currPeripheral, options: nil)
                do {
                    try managedContext.save()
                } catch {
                    print("Could not save")
                }
            } catch {
                print("Could not fetch")
            }
        }
        
    }
    
    /*
     * Set alarm string that will be displayed to user
     */
    func setAlarmLabel(alarm: NSManagedObject){
        time_lbl.text = alarm.value(forKeyPath: "time") as? String
    }
    
    /*
     * Set index of order of alarm
     */
    func setIndex(index: Int){
        self.index = index
    }
    
    /*
     * Move ble variables so toggle function can work properly
     */
    func setBLE(central: CBCentralManager, peripheral: CBPeripheral, svc: TabBarController, message: Home){
        self.currCentral = central
        self.currPeripheral = peripheral
        self.svc = svc
        self.message = message
    }
    
    /*
     * Goes through array to display active days
     */
    func setDayLabel(alarm: NSManagedObject){
        let days: [Bool] = alarm.value(forKeyPath: "days") as? Array<Bool> ?? []
        var totalText = ""
        if(days[0]){
            totalText += "M "
        }
        if(days[1]){
            totalText += "T "
        }
        if(days[2]){
            totalText += "W "
        }
        if(days[3]){
            totalText += "Th "
        }
        if(days[4]){
            totalText += "F "
        }
        if(days[5]){
            totalText += "Sa "
        }
        if(days[6]){
            totalText += "Su "
        }
        day_lbl.text = totalText;
    }
    
    /*
     * Set toggle depending on core data value
     */
    func setToggle(alarm: NSManagedObject){
        let toggle = alarm.value(forKeyPath: "active") as? Bool
        active_toggle.setOn(toggle!, animated: true)
    }
    
}

