//
//  ConsentTask.swift
//  Peggy Meter
//
//  Created by Rustem Arzymbetov on 3/15/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import ResearchKit

public var ConsentTask: ORKOrderedTask {
    let Document = ORKConsentDocument()
    Document.title = "Peggy Meter Consent"
    
    let sectionTypes: [ORKConsentSectionType] = [
        .overview,
        //.dataGathering,
        .privacy,
        //.dataUse,
        //.timeCommitment,
        //.studySurvey,
        //.studyTasks,
        //.withdrawing
    ]
    
    let consentSections: [ORKConsentSection] = sectionTypes.map { contentSectionType in
        let consentSection = ORKConsentSection(type: contentSectionType)
        if contentSectionType == ORKConsentSectionType.overview {
            consentSection.summary = "Welcome to PeggyJo Mood Meter Alpha!"
            consentSection.htmlContent = "Our mission is to help you to better understand yourself and improve your wellbeing. You can register your mood with our widget or application and if you agree we'll anonymously collect passive mobile data to give you additional insights in the future <a href='http://www.peggyjo.io'>learn why you should believe in us and our privacy promise</a>.<br><br>This is our Alpha product and we really appreciate your feedback!<br><br>Help us with our mission by sharing your anonymized data?"
            
        } else if contentSectionType == ORKConsentSectionType.privacy {
            consentSection.summary = "Privacy Policy"
            consentSection.htmlContent = "By tapping Agree you agree to the terms of our privacy policy: <a href='http://www.peggyjo.io/privacy'>www.peggyjo.io/privacy</a>."
        }
        return consentSection
    }
    
    Document.sections = consentSections
    /*
    Document.addSignature(ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "UserSignature"))
    */
    var steps = [ORKStep]()
    
    //Visual Consent
    /*
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsent", document: Document)
    steps += [visualConsentStep]
    */
    //Signature
    
    //let signature = Document.signatures!.first! as ORKConsentSignature
    let reviewConsentStep = ORKConsentReviewStep(identifier: "Review", signature: nil, in: Document)
    reviewConsentStep.text = "Review the consent"
    reviewConsentStep.reasonForConsent = "Consent to join the Research Study."
    
    steps += [reviewConsentStep]
    
    //Completion
    let completionStep = ORKCompletionStep(identifier: "CompletionStep")
    completionStep.title = "Welcome"
    completionStep.text = "Thank you for joining this study."
    steps += [completionStep]
    
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
