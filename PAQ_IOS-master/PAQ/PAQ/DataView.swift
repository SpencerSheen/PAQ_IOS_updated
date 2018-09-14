//
//  DataView.swift
//  PAQ
//
//  Created by Spencer Sheen on 9/12/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataView: UIViewController{
    
    @IBOutlet weak var EntriesLabel: UILabel!
    
    @IBOutlet weak var alarmcreateLabel: UILabel!
    @IBOutlet weak var alarmeditLabel: UILabel!
    @IBOutlet weak var alarmdeleteLabel: UILabel!
    @IBOutlet weak var alarmtoggleLabel: UILabel!
    @IBOutlet weak var timerstartedLabel: UILabel!
    @IBOutlet weak var timercancelledLabel: UILabel!
    @IBOutlet weak var timertabLabel: UILabel!
    @IBOutlet weak var alarmstabLabel: UILabel!
    @IBOutlet weak var devicetabLabel: UILabel!
    @IBOutlet weak var batteryCheckedLabel: UILabel!
    @IBOutlet weak var launchLabel: UILabel!
    
    var entries: [NSManagedObject] = []
    var track: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Feedback")
        do {
            entries = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        var totalEntries = ""
        for entry in entries{
            totalEntries += (entry.value(forKey: "time") as! String) + " " + (entry.value(forKey: "entry") as! String) + "\n"
            //totalEntries += "\n"
        }
        EntriesLabel.text = totalEntries
        
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tracking")
        do {
            track = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        alarmcreateLabel.text = "Alarms Created: " + String(track[0].value(forKeyPath:"alarmcreated") as! Int)
        alarmeditLabel.text = "Alarms Edited: " + String(track[0].value(forKeyPath:"alarmedited") as! Int)
        alarmstabLabel.text = "Alarm Tab: " + String(track[0].value(forKeyPath:"alarmtab") as! Int)
        alarmdeleteLabel.text = "Alarm Delete: " + String(track[0].value(forKeyPath:"alarmdeleted") as! Int)
        alarmtoggleLabel.text = "Alarms Toggled: " + String(track[0].value(forKeyPath:"alarmtoggled") as! Int)
        launchLabel.text = "Number of Launches: " + String(track[0].value(forKeyPath:"applaunches") as! Int)
        timertabLabel.text = "Timer Tab: " + String(track[0].value(forKeyPath:"timertab") as! Int)
        devicetabLabel.text = "Device Tab: " + String(track[0].value(forKeyPath:"devicetab") as! Int)
        timerstartedLabel.text = "Timer Starts: " + String(track[0].value(forKeyPath:"timerstarted") as! Int)
        timercancelledLabel.text = "Timer Cancels: " + String(track[0].value(forKeyPath:"timercancelled") as! Int)
        batteryCheckedLabel.text = "Battery Checks: " + String(track[0].value(forKeyPath:"batterychecked") as! Int)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //segue to go to the BLE tableview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //goes back to more tab
        if segue.identifier == "DataBack"{
            let tabBarController = segue.destination as! TabBarController
            tabBarController.tabIndex = 2
            tabBarController.alreadySent = true
        }
    }
    
}
