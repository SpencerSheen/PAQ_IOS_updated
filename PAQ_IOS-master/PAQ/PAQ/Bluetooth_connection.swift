//
//  Bluetooth_connection.swift
//  PAQ
//
//  Created by Karan Sunil on 2/26/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class Bluetooth_connection: UIViewController,UITableViewDelegate {
    @IBOutlet weak var table_view: UITableView!
    
    var peripherals:[CBPeripheral] = []
    var centralManager: CBCentralManager?
    var oldCentral: CBCentralManager?
    var alarmPeripheral: CBPeripheral!
    var device: CBPeripheral!
    var BLEList: [NSManagedObject] = []
    var CBUUIDList: [CBUUID] = []
    
    //Initializes a new centralManager object, the object isn't used if the user
    //does not select a BLE device
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print(centralManager ?? "centralManager is NIL")
        // Do any additional setup after loading the view.
    }
    
    //segues for when user goes back or when user actually selects a BLE device
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //when no Bluno is selected, old central and peripheral is sent to TabBarController
        if segue.identifier == "backSegue"{
            stopBLEScan()
            let tabBar = segue.destination as! TabBarController
            tabBar.currPeripheral = device
            tabBar.currCentral = oldCentral
        }
        //when Bluno is selected, take peripheral value of where the row was selected.
        //send new peripheral and central to TabBarController
        if segue.identifier == "returnSegue"{
            stopBLEScan()
            //NEW DISCONNECT FEATURE NEEDS TO BE TESTED
            //centralManager?.cancelPeripheralConnection(device)
            let tabBar = segue.destination as! TabBarController
            device = peripherals[table_view.indexPathForSelectedRow!.row]
            tabBar.sendKey = 2
            tabBar.currPeripheral = device
            centralManager?.connect(device, options: nil)
            tabBar.currCentral = centralManager
            //tabBar.CBUUIDList = CBUUIDList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        scanBLE()
    }
    
    func scanBLE(){
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopBLEScan(){
        centralManager?.stopScan()
        print("Scan stopped")
    }
    
    //takes every alarm from coredata and converts it to a string
    func getAlarm(alarms: NSManagedObject) -> String{
        var totalAlarmString = "A"
        let ID = extractID(id: String(alarms.value(forKeyPath: "id") as! Int))
        let time = extractTime(time: String(alarms.value(forKeyPath: "time") as! String))
        let days = extractDays(days: alarms.value(forKeyPath: "days") as? Array<Bool> ?? [])
        
        let misc = String(alarms.value(forKeyPath: "duration") as! Int) +
            String(alarms.value(forKeyPath: "snoozes") as! Int) +
            String(alarms.value(forKeyPath: "intensity") as! Int) +
            String(alarms.value(forKeyPath: "length") as! Int)
        
        
        let active = extractActive(active: alarms.value(forKeyPath: "active") as! Bool)
        //order of alarm string
        totalAlarmString += ID + time + days + misc + active
        return totalAlarmString
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

extension Bluetooth_connection: UITableViewDataSource {
    //number of available peripherals
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return peripherals.count
    }
    
    //loops through all peripherals to add cells to tableview
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath)
        let device = peripherals[indexPath.row]
        cell.textLabel?.text = device.name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let device = peripherals[indexPath.row]
        //centralManager?.connect(device, options: nil)
        //stopBLEScan()
    }
    
}

extension Bluetooth_connection: CBCentralManagerDelegate{
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        alarmPeripheral = peripheral
        alarmPeripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!peripherals.contains(peripheral) && peripheral.name != nil){
            peripherals.append(peripheral)
        }
        self.table_view.reloadData()
        
    }
    
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
            centralManager?.scanForPeripherals(withServices: nil)
        }
    }
}

extension Bluetooth_connection: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            
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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        //may need to add loop back to go through characteristics
        for characteristic in characteristics {
        
        //Get all existing alarms
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
        var totalAlarmString = ""
        do{
            let allAlarms = try context.fetch(request)
            
            //loop through alarms
            for alarms in allAlarms{
                //convert alarm info into a string
                totalAlarmString = getAlarm(alarms: alarms as! NSManagedObject)
                //convert alarm string to data type that is sendable
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


