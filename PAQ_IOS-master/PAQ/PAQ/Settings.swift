//
//  Settings.swift
//  PAQ
//
//  Created by Spencer Sheen on 8/13/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import Foundation

import UIKit
import CoreBluetooth

class Settings: UIViewController{
    let random_string = "xferfervs"
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var howToButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    @IBAction func showAbout(_ sender: Any){
    }
    
    /*
     * Opens PAQ on facebook app, if there is no app, opens on website
     */
    @IBAction func openFB(_ sender: Any) {
        
        let Username =  "paqwear" // Your Instagram Username here
        let appURL = NSURL(string: "fb://profile/158751901522631")!
        let webURL = NSURL(string: "https://facebook.com/\(Username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            application.open(webURL as URL)
        }
    }
    
    /*
     * Opens PAQ on instagram app, if there is no app, opens on website
     */
    @IBAction func openIG(_ sender: Any) {
        let Username = "paqwear"
        let appURL = NSURL(string: "instagram://user?username=\(Username)")!
        let webURL = NSURL(string: "https://instagram.com/\(Username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            application.open(webURL as URL)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tried to set up border(probably not working properly here)
        let goldBorder = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
        aboutButton.layer.borderColor = goldBorder.cgColor
        reportButton.layer.borderColor = goldBorder.cgColor
        howToButton.layer.borderColor = goldBorder.cgColor
    }
    
    //segue to go to the BLE tableview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass old alarm data objects
        //connectSegue not being used here
        if segue.identifier == "connectSegue"{
            let svc = tabBarController as! TabBarController
            let alarmController = segue.destination as! Bluetooth_connection
            alarmController.oldCentral = svc.currCentral
            alarmController.device = svc.currPeripheral
        }
        //sets text for about popup
        if segue.identifier == "aboutPopup"{
            let popupController = segue.destination as! Popup
            popupController.titleMessage = "About PAQ"
            popupController.labelMessage = "Thank you for downloading our app! We are serious about bringing the best start to people's days, and we're happy that you're on the same page. We would love for you to share your thoughts on anything, from our product to the quality of your mornings. \n \n Please reach out to us at social@paqwear.com, and be sure to follow us @paqwear"
        }
        //sets text for report popup
        if segue.identifier == "reportPopup"{
            let popupController = segue.destination as! Popup
            popupController.titleMessage = "Report a Problem"
            popupController.labelMessage = "Has something gone wrong? Could we be doing something better? We are continually working to deliver the best product possible and so we encourage you to share your experience with us. \n \n You can reach us at social@paqwear.com"
        }
        //goes back to more tab
        if segue.identifier == "backSegue"{
            let tabBarController = segue.destination as! TabBarController
            tabBarController.tabIndex = 2
            tabBarController.alreadySent = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
     advertisementData: [String: Any], rssi RSSI: NSNumber) {
     print(peripheral)
     }*/
}


/*
 extension BLE_signals: CBPeripheralManagerDelegate{
 func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
 switch peripheral.state{
 case .unknown:
 print("central.state is .unknown")
 case .resetting:
 print("central.state is .resetting")
 case .unsupported:
 print("central.state is .unsupported")
 case .unauthorized:
 print("central.state is .unauthorized")
 case .poweredOff:
 print("central.state is .poweredOff")
 case .poweredOn:
 print("central.state is .poweredOn")
 }
 }
 }
 */
/*extension BLE_signals: CBCentralManagerDelegate{
 func centralManagerDidUpdateState(_ central: CBCentralManager) {
 switch central.state{
 case .unknown:
 print("central.state is .unknown")
 case .resetting:
 print("central.state is .resetting")
 case .unsupported:
 print("central.state is .unsupported")
 case .unauthorized:
 print("central.state is .unauthorized")
 case .poweredOff:
 print("central.state is .poweredOff")
 case .poweredOn:
 print("central.state is .poweredOn")
 centralManager?.scanForPeripherals(withServices: nil)
 }
 }
 }*/

