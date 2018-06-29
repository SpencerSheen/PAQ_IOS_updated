//
//  Popup.swift
//  PAQ
//
//  Created by Spencer Sheen on 5/11/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit

class Popup: UIViewController{
    
    @IBOutlet weak var popupLabel: UILabel!
    @IBOutlet weak var popupTitle: UILabel!
    
    var labelMessage = ""
    var titleMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupLabel.text = labelMessage
        popupTitle.text = titleMessage
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }

}
