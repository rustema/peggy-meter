//
//  DataController.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import SQLite
import FirebaseDatabase
import FirebaseAuth

protocol DataController {
    func getMoodRecords() -> [MoodRecord]
    func saveMoodRecord(_ record: MoodRecord)
    func deleteMoodRecord(_ record: MoodRecord)
}

class FirebaseDataController: NSObject, DataController {
    var nextId: Int64 = 1
    var ref: DatabaseReference!
    override init() {
        super.init()
        
        ref = Database.database().reference()
    }

    private func readData(completion: @escaping ([MoodRecord]) -> ()) {
        let uid = Auth.auth().currentUser?.uid
        print("uid = \(uid)")
        let moodRecords = ref.child("users").child(uid!).child("moods").queryOrdered(byChild: "timestamp")
        moodRecords.observeSingleEvent(of: .value, with: { (snapshot) in
            var result: [MoodRecord] = []
            let values = snapshot.value as? NSArray
            var i = 0
            if (values) != nil {
                for record in values! {
                    let value = record as? NSDictionary
                    let moodRecord = MoodRecord()
                    moodRecord.id = Int64(i)
                    i = i + 1
                    moodRecord.timestamp = Date(timeIntervalSince1970: TimeInterval(value?["timestamp"] as? Int ?? 0))
                    moodRecord.moodLevel = value?["moodLevel"] as? Int ?? 0
                    moodRecord.comment = value?["comment"] as? String ?? ""
                    result.append(moodRecord)
                }
            }
            completion(result)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func getMoodRecords() -> [MoodRecord] {

        readData{ result in
            print("result.count = \(result.count)")
            
        }
        return []
    }
    
    func saveMoodRecord(_ record: MoodRecord) {
        let uid = Auth.auth().currentUser?.uid
        // TODO: implement.
        let recordDict = [
            "timestamp": Int(record.timestamp.timeIntervalSince1970),
            "moodLevel": record.moodLevel,
            "comment": record.comment] as [String : Any]
        let record_ref = ref.child("users").child(uid!).child("moods").childByAutoId()
        record_ref.setValue(recordDict)
        let childautoID = record_ref.key
        print("new record: \(childautoID)")
    }
    
    func deleteMoodRecord(_ record: MoodRecord) {
        // TODO: implement.
    }
}

class SQLiteDataController: NSObject, DataController {
    
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
        
        var documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        if documentsDirectory.last! != "/" {
            documentsDirectory.append("/")
        }
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
