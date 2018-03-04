//
//  DataController.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit

class DataController: NSObject {
    
    var moodRecords: [MoodRecord] = []
    var nextId: Int64 = 1;

    func findRecordIndex(_ record: MoodRecord) -> Int {
        for (i, existingRecord) in moodRecords.enumerated() {
            if existingRecord.id == record.id {
                return i
            }
        }
        return -1
    }
    
    func saveMoodRecord(_ record: MoodRecord) {
        if record.id > 0 {
            moodRecords[findRecordIndex(record)] = record
            return
        }
        record.id = nextId
        nextId += 1
        moodRecords.append(record)
    }
    
    func deleteMoodRecord(_ record: MoodRecord) {
        moodRecords.remove(at: findRecordIndex(record))
    }
    
    func getMoodRecords() -> [MoodRecord] {
        return moodRecords
    }
}
