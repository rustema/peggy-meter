//
//  MainViewController.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import Charts
import PassiveDataKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //var user: User?
 
    var dataController: DataController!
    //var transmitter: PDKHttpTransmitter!
    let dateFormatter = DateFormatter()
    
    //var pdkListener: PDKFirebaseListener!

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet var moodButtons: [UIButton]!
    @IBOutlet weak var lineChartView: LineChartView!
    
    let smileys: [String] = ["😢", "☹️", "🙂", "😀", "😃"]


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the "Back" button.
        // The simple fix: "self.navigationItem.hidesBackButton = true"
        // is not working for some reason.
        // A more sophisticated solution per https://stackoverflow.com/questions/28091015/hide-back-button-in-navigation-bar-with-hidesbackbutton-in-swift
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
        
        // Sign in anonymously.
        //login()
        
        // Application logic setup.
        //dataController = SQLiteDataController(self.reloadViews)
        dataController = FirebaseDataController(self.reloadViews)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        for (index, moodButton) in moodButtons.enumerated() {
            moodButton.setTitle(smileys[index], for: .normal)
        }
        
        if let pdkListener = dataController as? PDKDataListener {
            startPDK(withListener: pdkListener)
        }
        
        //updateChart()
        
        self.lineChartView.chartDescription!.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startPDK(withListener listener: PDKDataListener) {
        /*
        let transOpts = [
            PDK_TRANSMITTER_UPLOAD_URL_KEY: "https://us-central1-peggy-192804.cloudfunctions.net/ingest-test",
            PDK_SOURCE_KEY: "test_ios",
            PDK_TRANSMITTER_ID_KEY: "test_user_ios"
        ]
        
        transmitter = PDKHttpTransmitter(options: transOpts)
        */
        //self.pdkListener = PDKFirebaseListener()
        let pdk = PassiveDataKit.sharedInstance()!
        
        
        let rl = pdk.register(listener, for: PDKDataGenerator.location, options: [:])
        print("registered for location --> \(rl)")
        
        let bl = pdk.register(listener, for: PDKDataGenerator.battery, options: [:])
        print("registered for battery --> \(bl)")
        
        let ahl = pdk.register(listener, for: PDKDataGenerator.appleHealthKit, options: [:])
        print("registered for apple health --> \(ahl)")
        /*
        pdk.register(transmitter, for: PDKDataGenerator.location)
        pdk.register(transmitter, for: PDKDataGenerator.battery)
        //pdk.register(transmitter, for: PDKDataGenerator.pedometer)
        pdk.register(transmitter, for: PDKDataGenerator.appleHealthKit)
        pdk.add(transmitter)
        */
        //print("pending size = \(transmitter.())")
    }

    class GraphValueFormatter: DefaultValueFormatter {
        
        var smileys: [String] = []
        
        init(_ smileys: [String]) {
            super.init()
            self.smileys = smileys
        }
        
        override func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            return self.smileys[Int(value) - 1]
        }
    }
    
    func updateChart() {
        var points: [ChartDataEntry] = []
        let now = Date()
        for moodRecord in self.dataController.getMoodRecords() {
            if moodRecord.timestamp >= now.addingTimeInterval(-3 * 24 * 3600) {
                points.append(ChartDataEntry(x: Double((moodRecord.timestamp.timeIntervalSince1970 - now.timeIntervalSince1970) / 60), y: Double(moodRecord.moodLevel)))
            }
        }
        if points.count > 0 {
            let dataSet = LineChartDataSet(values: points, label: "")
            dataSet.valueFormatter = GraphValueFormatter(smileys)
            lineChartView.data = LineChartData(dataSet: dataSet)
        } else {
            lineChartView.data?.clearValues()
        }
        lineChartView.notifyDataSetChanged()
    }
    
    func reloadViews() {
        self.historyTableView.reloadData()
        self.updateChart()
    }

    @IBAction func toggleGraphButtonClicked(_ sender: Any) {
        self.lineChartView.isHidden = !self.lineChartView.isHidden
        self.historyTableView.isHidden = !self.historyTableView.isHidden
    }
    
    @IBAction func moodLevelButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Feeling \((sender as! UIButton).titleLabel!.text ?? "normal")", message: "Enter a comment (optional)", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Just god a job offer!"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            print("Text field: \(String(describing: textField.text))")
            
            let record: MoodRecord = MoodRecord()
            record.moodLevel = (sender as! UIButton).tag
            record.comment = textField.text!
            self.dataController.saveMoodRecord(record)
            
            //
            //self.reloadViews()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.dataController.getMoodRecords().count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MoodRecordCell")!
        let record: MoodRecord = self.dataController.getMoodRecords()[indexPath.row]
        (cell.viewWithTag(1) as! UILabel).text = dateFormatter.string(from: record.timestamp)
        (cell.viewWithTag(2) as! UILabel).text = self.smileys[record.moodLevel - 1]
        (cell.viewWithTag(3) as! UILabel).text = record.comment
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dataController.deleteMoodRecord(self.dataController.getMoodRecords()[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.updateChart()
        }
    }
    
    @IBAction func feedbackButtonClicked(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.peggyjo.io")!)
    }
}
