//
//  DataController.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import SQLite
import Firebase
import FirebaseDatabase
import FirebaseAuth
import PassiveDataKit

protocol DataController {
    func getMoodRecords() -> [MoodRecord]
    func saveMoodRecord(_ record: MoodRecord)
    func deleteMoodRecord(_ record: MoodRecord)
}

class FirebaseDataController: NSObject, DataController, PDKDataListener {
    var nextId: Int64 = 1
    var ref: DatabaseReference!
    var db: Firestore!
    var records: [MoodRecord] = []
    var completionHandler:(() -> Void)!
    var user: User!
    
    private func setupMoodAddedObserver() {
        let uid = self.user.uid
        // Set up read handler.
        self.ref.child("users").child(uid).child("moods").observe(.childAdded, with: { (snapshot) in
            let recordDict = snapshot.value as? [String : AnyObject] ?? [:]
            let moodRecord = MoodRecord()
            moodRecord.id = 0
            
            let ts = recordDict["timestamp"] as? Int ?? 0
            // Default to 1 since mood levels are 1-based.
            let moodLevel = recordDict["moodLevel"] as? Int ?? 1
            let comment = recordDict["comment"] as? String ?? ""
            moodRecord.timestamp = Date(timeIntervalSince1970: TimeInterval(ts))
            moodRecord.moodLevel = moodLevel
            moodRecord.comment = comment
            self.records.append(moodRecord)
            self.completionHandler()
        })
    }
    private func setupFirebase() {
        ref = Database.database().reference()
        db = Firestore.firestore()
        
        // If already authenticated, reuse the existing auth info.
        if Auth.auth().currentUser != nil {
            self.user = Auth.auth().currentUser!
            print("reusing existing user id: \(self.user.uid)")
            self.setupMoodAddedObserver()
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                guard error == nil else {
                    print("failed to authenticate: \(String(describing: error))")
                    exit(0)
                }
                print("Successfully logged in to FB: \(String(describing: user!.uid))")
                self.user = user!
                
                self.setupMoodAddedObserver()
            }
        }
    }
    
    init(_ completionHandler: @escaping (() -> Void)) {
        super.init()
        
        self.completionHandler = completionHandler
        setupFirebase()
    }

    func getMoodRecords() -> [MoodRecord] {
        return self.records
    }
    
    func saveMoodRecord(_ record: MoodRecord) {
        let uid = self.user.uid
        // TODO: implement.
        let recordDict = [
            "timestamp": Int(record.timestamp.timeIntervalSince1970),
            "moodLevel": record.moodLevel,
            "comment": record.comment] as [String : Any]
        let record_ref = ref.child("users").child(uid).child("moods").childByAutoId()
        record_ref.setValue(recordDict)
        let childautoID = record_ref.key
        print("new record: \(childautoID)")
    }
    
    func deleteMoodRecord(_ record: MoodRecord) {
        // TODO: implement.
    }
    
    // PDKDataListener methods.
    func receivedData(_ data: [AnyHashable : Any]!, forCustomGenerator generatorId: String!) {
        //
        print("custom generator --> \(generatorId)")
        print("custom data --> \(data)")
    }
    
    func receivedData(_ data: [AnyHashable : Any]!, for dataGenerator: PDKDataGenerator) {
        print("pdk data generator --> \(dataGenerator)")
        let generatorId2Name = [
            PDKDataGenerator.battery: "battery",
            PDKDataGenerator.location: "location",
            PDKDataGenerator.appleHealthKit: "healthkit",
            PDKDataGenerator.events: "events",
            PDKDataGenerator.googlePlaces: "places"
        ]
        let genName = generatorId2Name[dataGenerator] ?? "UNK"
        print("pdk data --> \(data)")
        if data.isEmpty {
            print("empty data dictionary for \(genName)")
            return
        }
        // Handle a special case for googlePlaces: a lot of de-facto empty events.
        if dataGenerator == PDKDataGenerator.googlePlaces, data.count == 1 {
            let v = data["PDKGooglePlacesInstance"] as? Array<Any> ?? []
            if v.isEmpty {
                print("no data for \(genName), key: PDKGooglePlacesInstance")
                return
            }
        }
        if let records = data as? [String: Any] {
            let uid = self.user.uid
            let batch = self.db.batch()
            
            let d = Int(Date().timeIntervalSince1970)
            let docKey = "\(uid)-\(String(describing: genName))-\(d)"
            let docRef = self.db.collection("pdk").document(docKey)
            batch.setData(records, forDocument: docRef)

            // Commit the batch
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    print("Batch write succeeded.")
                }
            }
        } else {
            print("PDK Listener - couldn't convert \(data) to [String: Any] :-(")
        }
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
    
    var completionHandler:(() -> Void)!
    
    init(_ completionHandler: @escaping (() -> Void)) {
        super.init()
        
        self.completionHandler = completionHandler
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
        self.completionHandler()
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
