//
//  FeedbackView.swift
//  PAQ
//
//  Created by Spencer Sheen on 9/12/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FeedbackView: UIViewController{
    @IBOutlet weak var Text: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Text.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedbackView.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    //segue to go to the BLE tableview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //goes back to more tab
        if segue.identifier == "submitSegue"{
            print(Text.text)
            
            //accessing core data
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Feedback", in: managedContext)
            let alarm = NSManagedObject(entity: entity!, insertInto: managedContext)
            //setting up new alarm contents
            alarm.setValue(Text.text, forKeyPath: "entry")
            alarm.setValue(getTimeString(), forKeyPath: "time")
            do {
                //tries to save and add to coredata
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            let tabBarController = segue.destination as! TabBarController
            tabBarController.tabIndex = 2
            tabBarController.alreadySent = true
        }
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Organizing time string in proper form to be sent through BLE
     */
    func getTimeString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let monthString = String(components.month!)
        let dayString = String(components.day!)
        let hourString = String(components.hour!)
        let minuteString = String(components.minute!)
        let secondString = String(components.second!)
        
        let today_string = monthString + "/" + dayString + " " + hourString + ":" + minuteString + ":" + secondString
        
        return today_string
        
    }
}

extension FeedbackView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
