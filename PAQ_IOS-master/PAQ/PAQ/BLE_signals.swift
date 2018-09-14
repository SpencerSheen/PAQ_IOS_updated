//
//  BLE_signals.swift
//  PAQ
//
//  Created by Karan Sunil on 2/25/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

class BLE_signals: UIViewController{
    let random_string = "xferfervs"
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    @IBOutlet weak var connectButton: UIButton!

    @IBOutlet weak var more: UIBarButtonItem!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func connect_btn(_ sender: Any) {
        //centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func showAbout(_ sender: Any) {
        
    }
    
    @IBAction func settings(_ sender: Any) {
    
    }
    
    @IBAction func batteryClick(_ sender: Any) {
        let svc = tabBarController as! TabBarController
        svc.sendKey = 1
        svc.timerString = "B"
        svc.currCentral?.connect(svc.currPeripheral, options: nil)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tracking")
        do{
            let trackEdit = try managedContext.fetch(request)
            
            //setting up edited contents
            let toggle = trackEdit[0] as! NSManagedObject
            toggle.setValue(toggle.value(forKeyPath:"batterychecked") as! Int + 1, forKeyPath: "batterychecked")
            do {
                //saves changes to coredata
                try managedContext.save()
            } catch {
                print("Could not save")
            }
        } catch {
            print("Could not fetch")
        }
    }
    /*
     * FACEBOOK AND INSTAGRAM FUNCTIONS NOT BEING USED HERE, SEE Settings.swift
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
        moreButton.isHidden = true
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tracking")
        do{
            let trackEdit = try managedContext.fetch(request)
            
            //setting up edited contents
            let toggle = trackEdit[0] as! NSManagedObject
            toggle.setValue(toggle.value(forKeyPath:"devicetab") as! Int + 1, forKeyPath: "devicetab")
            do {
                //saves changes to coredata
                try managedContext.save()
            } catch {
                print("Could not save")
            }
        } catch {
            print("Could not fetch")
        }
        
        let goldBorder = UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1)
        //connectButton.layer.borderColor = goldBorder.cgColor
        
        //yellow underline current tab
        let tabBar = self.tabBarController?.tabBar
        tabBar?.selectionIndicatorImage = UIImage().createSelectionIndicator(color: UIColor(red: (252/255), green: 220/255, blue: 61/255, alpha: 1), size: CGSize(width: (tabBar?.frame.width)!/CGFloat((tabBar?.items!.count)!), height: (tabBar?.frame.height)!), lineWidth: 2.0)
    }
    
    //segue to go to the BLE tableview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass old alarm data objects
        if segue.identifier == "connectSegue"{
            let svc = tabBarController as! TabBarController
            let alarmController = segue.destination as! Bluetooth_connection
            alarmController.oldCentral = svc.currCentral
            alarmController.device = svc.currPeripheral
        }
        //ABOUT AND REPORT SEGUES NOT CURRENTLY BEING USED HERE
        if segue.identifier == "aboutPopup"{
            let popupController = segue.destination as! Popup
            popupController.titleMessage = "About PAQ"
            popupController.labelMessage = "Thank you for downloading our app! We are serious about bringing the best start to people's days, and we're happy that you're on the same page. We would love for you to share your thoughts on anything, from our product to the quality of your mornings. \n \n Please reach out to us at social@paqwear.com, and be sure to follow us @paqwear"
        }
        if segue.identifier == "reportPopup"{
            let popupController = segue.destination as! Popup
            popupController.titleMessage = "Report a Problem"
            popupController.labelMessage = "Has something gone wrong? Could we be doing something better? We are continually working to deliver the best product possible and so we encourage you to share your experience with us. \n \n You can reach us at social@paqwear.com"
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
 * Formatting code for rounding buttons, setting border width, and border color
 */
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
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

