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
    
    var index = 0
    @IBAction func changeToggle(_ sender: UISwitch) {
        
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
    
    func setAlarmLabel(alarm: NSManagedObject){
        time_lbl.text = alarm.value(forKeyPath: "time") as? String!
    }
    
    func setIndex(index: Int){
        self.index = index
    }
    
    func setBLE(central: CBCentralManager, peripheral: CBPeripheral){
        self.currCentral = central
        self.currPeripheral = peripheral
    }
    
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
    
    func setToggle(alarm: NSManagedObject){
        let toggle = alarm.value(forKeyPath: "active") as? Bool!
        active_toggle.setOn(toggle!, animated: true)
    }
    
}

