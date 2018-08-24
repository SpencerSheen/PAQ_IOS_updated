//
//  Home.swift
//  PAQ
//
//  Created by Karan Sunil on 2/6/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class Home: UIViewController{


    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var tableFormat: UITableView!
    
    //contains data from all alarms
    var alarms: [NSManagedObject] = []
    var BLEList: [NSManagedObject] = []
    
    //bluetooth objects
    var currCentral: CBCentralManager?
    var currPeripheral: CBPeripheral!
    var CBUUIDList: [CBUUID] = []
    var isBLE = false;
    
    //index used to send data to TableViewCell for the alarm toggle
    var index = 0
    var isConnected = false
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        index = 0
        
        //CLEARS ALL EXISTING DATA
        
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
        
        tableView.allowsSelectionDuringEditing = true
        if(currPeripheral == nil){
            let svc = tabBarController as! TabBarController
            currCentral = svc.currCentral
            //CBUUID CODE
            /*CBUUIDList = svc.CBUUIDList
             print(CBUUIDList.count)
             let connectedPeripherals = currCentral?.retrievePeripherals(withIdentifiers: CBUUIDList as! [UUID])
             if(connectedPeripherals != nil){
             print(connectedPeripherals?.count)
             currPeripheral = connectedPeripherals![0]
             }*/
            currPeripheral = svc.currPeripheral
        }
        
        if(currPeripheral != nil && currPeripheral.state == .connecting){
            print("true")
        }
        // Do any additional setup after loading the view.
        
        //currCentral?.connect(currPeripheral, options: nil)
        
        let tabBar = self.tabBarController?.tabBar
        tabBar?.selectionIndicatorImage = UIImage().createSelectionIndicator(color: UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1), size: CGSize(width: (tabBar?.frame.width)!/CGFloat((tabBar?.items!.count)!), height: (tabBar?.frame.height)!), lineWidth: 2.0)
        self.view.bringSubview(toFront: bar)
        self.view.sendSubview(toBack: tableFormat)
        print(currPeripheral)
    }
    
    //segue sends information to ViewController, for editing alarms
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = tabBarController as! TabBarController
        if segue.identifier == "editSegue"{
            let alarmController = segue.destination as! ViewController
            alarmController.edit = true
            alarmController.index = tableView.indexPathForSelectedRow!.row
            alarmController.currCentral = currCentral
            alarmController.currPeripheral = currPeripheral
            
            //let svc = tabBarController as! TabBarController
            svc.alarmIndex = tableView.indexPathForSelectedRow!.row
            svc.sendKey = 3
            svc.currPeripheral = currPeripheral
            svc.currCentral = currCentral
        }
        if segue.identifier == "addSegue"{
            let alarmController = segue.destination as! ViewController
            alarmController.currCentral = currCentral
            alarmController.currPeripheral = currPeripheral
            
            //let svc = tabBarController as! TabBarController
            svc.alarmIndex = -1
            svc.sendKey = 3
            svc.currPeripheral = currPeripheral
            svc.currCentral = currCentral
        }
        //svc.sendKey = 0
    }
    
    //Stops user from being able to edit or add alarms if ble is not connected
    // NEED TO TEST
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        //let svc = tabBarController as! TabBarController
        if(currPeripheral == nil){
            isConnected = false
        }
        else{
            //svc.sendKey = 3
            //currCentral?.connect(currPeripheral, options: nil)
        }
    
        if let ident = identifier {
            print(currPeripheral)
            if (currPeripheral == nil || currPeripheral.state != .connected) {
                isConnected = false
            }
            else{
                isConnected = true
            }
            if (ident == "editSegue" || ident == "addSegue") {
                //svc.sendKey = 3
                return isConnected
            }
            else{
                return !isConnected
            }
        }
        return false
    }
    
    //retrieves data from coredata
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AlarmList")
        do {
            alarms = try managedContext.fetch(fetchRequest)
            //print(alarms.capacity)
            //self.alarmTable.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BLE")
        do {
            BLEList = try managedContext.fetch(fetchRequest)
            //print(alarms.capacity)
            //self.alarmTable.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension Home: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return alarms.count
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    
    //loops through alarms array to add cells to tableview
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let alarm = alarms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        //print(index)
        self.tableView.rowHeight = 100
        //set time/day/toggle value based on alarm data
        cell.setAlarmLabel(alarm: alarm)
        cell.setDayLabel(alarm: alarm)
        cell.setToggle(alarm: alarm)
        
        if(self.currPeripheral != nil){
            let svc = tabBarController as! TabBarController
            cell.setBLE(central: self.currCentral!, peripheral: self.currPeripheral, svc: svc)
        }
        
        //index used to send data to TableViewCell for the alarm toggle
        cell.setIndex(index: index)
        index = index + 1
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        index = 0;
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // DELETES ON LEFT SWIPE
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //
    //        if editingStyle == UITableViewCellEditingStyle.delete
    //        {
    //            guard let appDelegate =
    //                UIApplication.shared.delegate as? AppDelegate else {
    //                    return
    //            }
    //
    //            let managedContext = appDelegate.persistentContainer.viewContext
    //            managedContext.delete(alarms[indexPath.row])
    //            do{
    //                try managedContext.save()
    //                print("deleting item from context")
    //            } catch let error as NSError {
    //                print("Could not save \(error), \(error.userInfo)")
    //            }
    //            print("deleting item")
    //            self.alarms.remove(at: indexPath.row)
    //            self.tableView.reloadData()
    //        }
    //    }
    
    // Limit swipe so that it requires user to press delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let svc = tabBarController as! TabBarController
        if currPeripheral != nil {
            svc.sendKey = 0
            currCentral?.connect(currPeripheral, options: nil)
        }
        print(currPeripheral)
        if (currPeripheral != nil && (currPeripheral.state == .connected /*|| currPeripheral.state == .connecting*/)) {
            
            let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { (
                action, sourceView, completionHandler) in
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                
                svc.idString = self.extractID(id: String((self.alarms[indexPath.row]).value(forKeyPath: "id") as! Int))
                svc.sendKey = 4
                // sends new alarm data since alarm is deleted
                self.currCentral?.connect(self.currPeripheral, options: nil)
                
                let managedContext = appDelegate.persistentContainer.viewContext
                managedContext.delete(self.alarms[indexPath.row])
                do{
                    try managedContext.save()
                    print("deleting item from context")
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                }
                print("deleting item")
                self.alarms.remove(at: indexPath.row)
                self.index = 0
                // delete the table view row
                tableView.reloadData()
                
                completionHandler(true)
            })
            let swipeAction = UISwipeActionsConfiguration(actions: [delete])
            swipeAction.performsFirstActionWithFullSwipe = false
            return swipeAction
        }
        return nil
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
}
