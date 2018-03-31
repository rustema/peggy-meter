//
//  PeggyWidgetViewController.swift
//  Peggy Meter WIdget
//
//  Created by Artem Iglikov on 3/31/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import NotificationCenter

class PeggyWidgetViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var moodButtons: [UIButton]!
    let smileys: [String] = ["😢", "☹️", "😐", "🙂", "😀"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        for (index, moodButton) in moodButtons.enumerated() {
            moodButton.setTitle(smileys[index], for: .normal)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func moodLevelButtonClicked(_ sender: Any) {
        extensionContext?.open(URL(string: "peggy-meter://\((sender as! UIButton).tag)")! , completionHandler: nil)
    }
}
