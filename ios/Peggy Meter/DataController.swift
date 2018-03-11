//
//  DataController.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import SQLite

class DataController: NSObject {
    
    var nextId: Int64 = 1;
    var pathToDatabase: String = "";
    var database: Connection! = nil;
    
    let moodRecordsTable = Table("mood_records")
    let moodRecordId = Expression<Int64>("id")
    let moodRecordTimestamp = Expression<Int>("timestamp")
    let moodRecordMoodLevel = Expression<Int>("mood_level")
    let moodRecordComment = Expression<String>("comment")
    
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        self.pathToDatabase = documentsDirectory.appending("database.sqlite")
        createDatabaseIfNeeded()
    }
    
    func openDatabase() -> Bool {
        if database != nil {
            return true
        }

        if FileManager.default.fileExists(atPath: pathToDatabase) {
            do {
                try database = Connection(pathToDatabase)
                return true
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return false
    }

    func createDatabaseIfNeeded() {
        if !FileManager.default.fileExists(atPath: self.pathToDatabase) {
            do {
                try database = Connection(pathToDatabase)
                try database.run(moodRecordsTable.create { t in
                    t.column(moodRecordId, primaryKey: .autoincrement)
                    t.column(moodRecordTimestamp)
                    t.column(moodRecordMoodLevel)
                    t.column(moodRecordComment)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveMoodRecord(_ record: MoodRecord) {
        if self.openDatabase() {
            do {
                if record.id > 0 {
                    // TODO: Update the record
                } else {
                    let insert = moodRecordsTable.insert(moodRecordTimestamp <- Int(record.timestamp.timeIntervalSince1970), moodRecordMoodLevel <- record.moodLevel, moodRecordComment <- record.comment)
                    try database.run(insert)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteMoodRecord(_ record: MoodRecord) {
        if self.openDatabase() {
            do {
                try database.run(moodRecordsTable.filter(moodRecordId == record.id).delete())
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getMoodRecords() -> [MoodRecord] {
        var moodRecords: [MoodRecord] = []
        if self.openDatabase() {
            do {
                for record in try database.prepare(moodRecordsTable) {
                    let moodRecord = MoodRecord()
                    moodRecord.id = record[moodRecordId]
                    moodRecord.timestamp = Date(timeIntervalSince1970: TimeInterval(record[moodRecordTimestamp]))
                    moodRecord.moodLevel = record[moodRecordMoodLevel]
                    moodRecord.comment = record[moodRecordComment]
                    moodRecords.append(moodRecord)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return moodRecords
    }
}
