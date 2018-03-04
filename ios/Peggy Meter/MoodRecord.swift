//
//  MoodRecord.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit

class MoodRecord: NSObject {
    var id: Int64 = 0
    var timestamp: Date = Date()
    var moodLevel: Int = 0
    var comment: String = ""
}
