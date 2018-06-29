//
//  HowTo.swift
//  PAQ
//
//  Created by Spencer Sheen on 5/24/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit

class HowTo: UIViewController{
    
    
    var labelMessage = ""
    var titleMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func `return`(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

