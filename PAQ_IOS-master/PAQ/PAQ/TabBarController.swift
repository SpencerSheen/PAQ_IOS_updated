//
//  TabBarController.swift
//  PAQ
//
//  Created by Spencer Sheen on 3/27/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

class TabBarController: UITabBarController{
    var currCentral: CBCentralManager?
    var currPeripheral: CBPeripheral!
    var CBUUIDList: [NSUUID] = []
    var peripherals:[CBPeripheral] = []
    
    //Key: 0 for sending nothing
    //Key: 1 for timer
    //Key: 2 for adding all alarms
    //Key: 3 for editing alarm
    //Key: 4 for deleting alarm
    var sendKey = 6
    var timerString = ""
    var alarmIndex = 8
    var idString = ""
    var alreadySent = false
    
    //index of which tab its in (defaults to alarm page)
    var tabIndex = 1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.selectedIndex = 1
        //CLEARS PERIPHERAL ID DATA
        /*let delegate = UIApplication.shared.delegate as! AppDelegate
         let context = delegate.persistentContainer.viewContext
         
         let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BLE")
         let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
         
         do {
         try context.execute(deleteRequest)
         try context.save()
         } catch {
         print ("There was an error")
         }*/
        
        //if central and peripheral values already exist, save them into coredata
        if(currCentral != nil && currPeripheral != nil){
            //currCentral = CBCentralManager(delegate: self, queue: nil)
            sendKey = 2
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BLE")
            let entity = NSEntityDescription.entity(forEntityName: "BLE", in: context)
            do{
                let peripherals = try context.fetch(request)
                if(peripherals.count == 0){
                    let newPeripheral = NSManagedObject(entity: entity!, insertInto: context)
                    newPeripheral.setValue(currPeripheral.identifier, forKey: "peripheralID")
                }
                else{
                    (peripherals[0] as! NSManagedObject).setValue(currPeripheral.identifier,
                                                                  forKeyPath: "peripheralID")
                }
            } catch {
                print("Could not fetch")
            }
            do {
                //saves changes to coredata
                try context.save()
            } catch {
                print("Could not save")
            }
            //currCentral?.connect(currPeripheral, options: nil)
            currCentral = nil
            currPeripheral = nil
        }
        
        //if central and peripheral data do not exist, initialize a new central and get peripheral ID from coredata
        if(currCentral == nil && currPeripheral == nil){
            sendKey = 5
            currCentral = CBCentralManager(delegate: self, queue: nil)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BLE")
            do{
                let peripherals = try context.fetch(request)
                for peripheral in peripherals{
                    let ID = (peripheral as! NSManagedObject).value(forKey: "peripheralID") as! UUID
                    print(ID)
                    CBUUIDList.append(ID as NSUUID)
                }
            } catch {
                print("Could not fetch")
            }
            
            print(CBUUIDList.count)
            //get peripheral object from peripheral id
            let connectedPeripherals = currCentral?.retrievePeripherals(withIdentifiers: CBUUIDList as [UUID])
            //central does not actually connect to peripheral until later
            if(connectedPeripherals?.count != 0){
                print(connectedPeripherals?.count ?? "nil")
                currPeripheral = connectedPeripherals![0]
                if currPeripheral.state == .connected {
                    alreadySent = true
                }
                print(currPeripheral)
            }
        }
        self.selectedIndex = tabIndex
        
    }
    
    
    //takes every alarm from coredata and converts it to a string
    func getAlarm(alarms: NSManagedObject) -> String{
        var totalAlarmString = ""
        let ID = extractID(id: String((alarms).value(forKeyPath: "id") as! Int))
        let time = extractTime(time: String((alarms).value(forKeyPath: "time") as! String))
        let days = extractDays(days: (alarms).value(forKeyPath: "days") as? Array<Bool> ?? [])
        let duration = extractDuration(value: String((alarms).value(forKeyPath: "duration") as! Int))
        
        let misc = String((alarms).value(forKeyPath: "snoozes") as! Int) +
            duration + String((alarms).value(forKeyPath: "interactivity") as! Int)
        
        let active = extractActive(active: alarms.value(forKeyPath: "active") as! Bool)
        //order of alarm string
        totalAlarmString += ID + time + days + misc + active
        return totalAlarmString
    }
    
    func extractDuration(value: String) -> String{
        if(value.count == 1){
            return "0" + value
        }
        else{
            return value
        }
    }
    
    func extractID(id: String) -> String {
        var newId = id
        //adds missing 0s if the Id value is too low
        if(id.count == 1){
            newId = "00" + id
        }
        else if(id.count == 2){
            newId = "0" + id
        }
        return newId
    }
    
    //converts time to 24 hour format HHmm
    func extractTime(time: String) -> String {
        //print(time + "\n")
        let dateAsString = time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)
        
        dateFormatter.dateFormat = "HHmm"
        let date24 = dateFormatter.string(from: date!)
        //print(String(date24))
        return String(date24)
    }
    
    //takes active days in forms of 0 and 1 and converts them
    //from binary to decimal
    // Ex: 0000111 (Fri, Sat, Sun alarm) converts to a value of 7
    func extractDays(days: [Bool]) -> String{
        //bit shifting shenanigans
        /*var magicBitShifting = UInt8(0)
         var shiftVal = 7
         for day in days{
         magicBitShifting = magicBitShifting | ((day ? 1 : 0) << shiftVal)
         shiftVal -= 1;
         }*/
        
        var dayPower = Float(5)
        var daysToDec = 0
        for day in days{
            if(day){
                daysToDec += Int(powf(2, dayPower))
            }
            dayPower -= 1
            if(dayPower < 0){
                dayPower = Float(6)
            }
        }
        
        if(daysToDec < 10){
            return "00" + String(daysToDec)
        }
        else if(daysToDec < 100){
            return "0" + String(daysToDec)
        }
        return String(daysToDec)
    }
    
    //whether alarm is toggled on or off
    func extractActive(active: Bool) -> String{
        if(active){
            return "1"
        }
        return "0"
    }
    
}

extension UIImage {
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: size.height - lineWidth, width: size.width, height: lineWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension TabBarController: CBCentralManagerDelegate{
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        currPeripheral = peripheral
        currPeripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!peripherals.contains(peripheral) && peripheral.name != nil){
            peripherals.append(peripheral)
        }
        
    }
    
    //checks to see if central state is poweredOn. If it is, connect central and peripheral
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("central.state is unknown")
        case .resetting:
            print("central.state is resetting")
        case .unsupported:
            print("central.state is unsupported")
        case .unauthorized:
            print("central.state is unauthorized")
        case .poweredOff:
            print("central.state is poweredOff")
        case .poweredOn:
            print("central.state is poweredOn")
            if(currPeripheral != nil){
                //sendKey = 5
                currCentral?.connect(currPeripheral, options: nil)
                //sendKey = 0
            }
        }
    }
}

extension TabBarController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            //print(service)
            //CBUUIDList.append(service.uuid)
            //print(service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didModifyServices invalidatedServices: [CBService]){
        print("DID MODIFY SERVICES")
        //print(peripheral)
        //print(invalidatedServices)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueForCharacteristic descriptor: CBDescriptor, error: Error?) {
        print("Error: ")
        print(error ?? "unknown error")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let cval = characteristic.value else{ return }
        let BATTERY_SVC     = CBUUID(string: "180F")    //battery services UUID
        let BATTERY_UUID    = CBUUID(string: "2A19")    //battery CBUUID
        if (characteristic.uuid == BATTERY_UUID) || (characteristic.uuid == BATTERY_SVC){
            let value = cval
            let batteryVal = value[0]
            let batteryLevel = Int32(bitPattern: UInt32(batteryVal))
            print("\(batteryLevel)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        let BATTERY_SVC     = CBUUID(string: "180F")    //battery services UUID
        let BATTERY_UUID    = CBUUID(string: "2A19")    //battery CBUUID
        if service.uuid == BATTERY_SVC {
            for char in service.characteristics!{
                if char.uuid == BATTERY_UUID {
                    print("BATTERY LEVEL: \(char.properties.rawValue)")
                }
            }
        }
        
        
        //may need to add loop back to go through characteristics
        for characteristic in characteristics {
            print("found \(characteristic.uuid)")
            
            //Get all existing alarms
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
            var totalAlarmString = ""
            do{
                print(sendKey)
                let allAlarms = try context.fetch(request)
                
                if(sendKey == 5 && !alreadySent){   //sending out system time to RTC over BLE
                    let date = Date()
                    let calendar = Calendar.current
                    
                    let currSec     = calendar.component(.second, from: date)
                    let currMin     = calendar.component(.minute, from: date)
                    let currHr      = calendar.component(.hour, from: date)
                    let dayOfWeek   = calendar.component(.weekday, from: date)
                    let dayOfMonth  = calendar.component(.day, from: date)
                    let month       = calendar.component(.month, from: date)
                    let year        = calendar.component(.year, from: date)
                    
                    let keyString = "S"
                    let secString   = (currSec  < 10 ? "0" : "") + String(currSec)
                    let minString   = (currMin  < 10 ? "0" : "") + String(currMin)
                    let hourString  = (currHr   < 10 ? "0" : "") + String(currHr)
                    let DOMString   = (dayOfMonth < 10 ? "0" : "") + String(dayOfMonth)
                    let monString   = (month    < 10 ? "0" : "") + String(month)
                    
                    let dataToSend = (keyString + secString + minString + hourString + String(dayOfWeek) + DOMString + monString + String(year)).data(using: .utf8)!
                    peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }else if(sendKey == 1){
                    let dataToSend = timerString.data(using: String.Encoding.utf8)
                    peripheral.writeValue(dataToSend!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    //timerSend = false
                }else if(sendKey == 2){
                    //loop through alarms
                    for alarms in allAlarms{
                        //convert alarm info into a string
                        totalAlarmString = getAlarm(alarms: alarms as! NSManagedObject)
                        //convert alarm string to data type that is sendable
                        let dataToSend = totalAlarmString.data(using: String.Encoding.utf8)
                        //send data to arduino
                        peripheral.writeValue(dataToSend!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    }
                }else if(sendKey == 3){
                    var tempAlarmIndex = alarmIndex
                    totalAlarmString = "E"
                    //adding alarm
                    if tempAlarmIndex == -1 {
                        tempAlarmIndex = allAlarms.count-1
                        totalAlarmString = "A"
                    }
                    
                    totalAlarmString += getAlarm(alarms: allAlarms[tempAlarmIndex] as! NSManagedObject)
                    let dataToSend = totalAlarmString.data(using: String.Encoding.utf8)
                    //send data to arduino
                    peripheral.writeValue(dataToSend!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }else if(sendKey == 4){
                    totalAlarmString += "D" + idString
                    let dataToSend = totalAlarmString.data(using: String.Encoding.utf8)
                    //send data to arduino
                    peripheral.writeValue(dataToSend!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                
            } catch {
                print("Could not fetch")
            }
            
        }
    }
    
}
