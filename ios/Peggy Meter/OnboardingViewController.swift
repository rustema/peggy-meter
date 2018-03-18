//
//  OnboardingViewController.swift
//  Peggy Meter
//
//  Created by Rustem Arzymbetov on 3/15/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//
//  This VC conditionally guides the user through the consent flow and

import ResearchKit
import UIKit

class OnboardingViewController: UIViewController, ORKTaskViewControllerDelegate {
    let consentObtained = "consent_obtained"

    // Handles ORK (consent) flow results.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
        
        // Handle results.
        let taskResult = taskViewController.result
        print("task view controller returned with \(reason) - \(taskResult) - \(String(describing: error))")
        let result = taskResult.stepResult(forStepIdentifier: "Review")?.results![0]
        print("v = \(String(describing: result))")
        
        let agreed = (result as? ORKConsentSignatureResult)?.consented
        if agreed! {
            // Memorize that we've obtained the consent.
            let standardDefaults = UserDefaults.standard
            standardDefaults.setValue("consent_obtained", forKey: consentObtained)
            // Go to the main logic.
            toMainVC()
        } else {
            // close the app
            print("closing the app; user didn't give consent")
            exit(0)
        }
    }
    
    // Jumps to the MainVC.
    func toMainVC() {
        print("segueing to main")
        performSegue(withIdentifier: "toMainVC", sender: nil)
    }
    
    func presentConsentFlow() {
        let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // If we haven't obtained user's consent yet, start ORK.
        // Otherwise, proceed to the main app logic.
        let standardDefaults = UserDefaults.standard
        if standardDefaults.object(forKey: consentObtained) == nil {
            presentConsentFlow()
        } else {
            toMainVC()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
