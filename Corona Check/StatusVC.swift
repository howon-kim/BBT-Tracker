//
//  StatusVC.swift
//  Corona Check
//
//  Created by Howon Kim on 2/24/20.
//  Copyright © 2020 Howon Kim. All rights reserved.
//

import UIKit
import SwiftChart
import CoreData


class StatusVC: UIViewController, ChartDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        symptoms.count
    }
    // AUTO CELL RESIZE: START //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatusTableViewCell
        let symptom = symptoms[indexPath.row]
        let temp = symptom.value(forKeyPath: "temp") as? Double
        let date = symptom.value(forKeyPath: "date") as? Date
        
        let cough = symptom.value(forKeyPath: "cough") as? Bool
        let sputum = symptom.value(forKeyPath: "sputum") as? Bool
        let chill = symptom.value(forKeyPath: "chill") as? Bool
        let sorethroat = symptom.value(forKeyPath: "sorethroat") as? Bool
        let dyspnea = symptom.value(forKeyPath: "dyspnea") as? Bool
        var descText = ""
        if cough! {
            descText.append(contentsOf: "기침 | ")
        }
        if sputum! {
            descText.append(contentsOf: "가래 | ")
        }
        if chill! {
            descText.append(contentsOf: "오한 | ")
        }
        if sorethroat! {
            descText.append(contentsOf: "목아픔 | ")
        }
        if dyspnea! {
            descText.append(contentsOf: "호흡곤란 | ")
        }
        if (descText.hasSuffix(" | ")) {
            descText.removeLast()
            descText.removeLast()
            descText.removeLast()
            
        }
        cell.tempLabel.text = String(temp!.description + "ºC")
        if (temp! >= 37.5) {
            cell.tempLabel.textColor = .red
        } else if (temp! < 37.0) {
            cell.tempLabel.textColor = .blue
        } else {
            cell.tempLabel.textColor = .black
        }
        if descText == "" {
            cell.statusLabel.text = "증상없음"
        } else {
            cell.statusLabel.text = descText
        }
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, h:mm a"
        let dateString = dateFormatterPrint.string(from: date!)
        
        cell.dateLabel.text = dateString
        
        let evaluate = evaluateCorona(temp: temp!, cough: cough!, sputum: sputum!, chill: chill!, sorethroatt: sorethroat!, dyspnea: dyspnea!)
        cell.evaluateLabel.text = evaluate
        if (evaluate == "양호") {
            cell.evaluateLabel.textColor = .blue
        } else if (evaluate == "관찰요망") {
            cell.evaluateLabel.textColor = .black
        } else if (evaluate == "주의") {
            cell.evaluateLabel.textColor = .orange
        } else {
            cell.evaluateLabel.textColor = .red
        }
        
        return cell
    }
    func evaluateCorona(temp: Double, cough: Bool, sputum: Bool, chill: Bool, sorethroatt: Bool, dyspnea: Bool) -> String {
        var result = "양호"
        var count = 0
        if (cough) {count += 1}
        if (sputum) {count += 1}
        if (chill) {count += 1}
        if (sorethroatt) {count += 1}
        
        if (temp >= 38.5) {
            result = "의심"
        } else if (temp >= 37.5) {
            if (dyspnea) {
                result = "의심"
            } else {
                if (count >= 1) {
                    result = "의심"
                } else {
                    result = "주의"
                }
            }
        } else if (temp >= 37.0) {
            if (dyspnea) {
                result = "의심"
            } else {
                if (count >= 2) {
                    result = "주의"
                } else {
                    result = "관찰요망"
                }
            }
        } else {
            if (dyspnea) {
                result = "의심"
            } else {
                if (count >= 3) {
                    result = "주의"
                } else if (count >= 2) {
                    result = "관찰요망"
                } else {
                    result = "양호"
                }
            }
        }
        return result
    }
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        print("end")
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chart: Chart!
    var symptoms: [NSManagedObject] = []
    
    
    @objc func refreshTable(notification: NSNotification) {
        
        print("Received Notification")
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "Binggrae", size: 17)!]
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "UserlistUpdate"), object: nil)
        
        
        // Do any additional setup after loading the view.
        chart.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Symptom")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        // How many to fetch //
        //fetchRequest.fetchLimit = 1
        
        //3
        do {
            symptoms = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print(symptoms.count)
        self.tableView.reloadData()
        
        // CHART VIEW //
        chart.removeAllSeries()
        var data: [Double] = []
        var date: [Date] = []
        
        for symptom in symptoms {
            if (data.count <= 30) {
                data.append(symptom.value(forKeyPath: "temp") as! Double)
                print(data)
                date.append(symptom.value(forKeyPath: "date") as! Date)
            }
        }
        data.reverse()
        date.reverse()
        
        let series = ChartSeries(data)
        series.area = true
        
        chart.add(series)
        chart.labelFont = UIFont.init(name: "Kohinoor Bangla", size: 12)
        
        
        
        // Set minimum and maximum values for y-axis
        chart.minY = 32
        chart.maxY = 43
        
        // Format y-axis, e.g. with units
        chart.showXLabelsAndGrid = false
        series.colors = (
            above: ChartColors.redColor(),
            below: ChartColors.blueColor(),
            zeroLevel: 37.5
        )
        
        
    }
    @IBAction func addButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddSymptom", sender: nil)
    }
    /*
     @IBAction func addName(_ sender: Any) {
     
     let alert = UIAlertController(title: "New Name",
     message: "Add a new name",
     preferredStyle: .alert)
     
     let saveAction = UIAlertAction(title: "Save",
     style: .default) {
     [unowned self] action in
     
     guard let textField = alert.textFields?.first,
     let nameToSave = textField.text else {
     return
     }
     
     
     self.save(name: nameToSave)
     self.tableView.reloadData()
     }
     
     let cancelAction = UIAlertAction(title: "Cancel",
     style: .cancel)
     
     alert.addTextField()
     
     alert.addAction(saveAction)
     alert.addAction(cancelAction)
     
     present(alert, animated: true)
     }
     
     func save(name: String) {
     
     guard let appDelegate =
     UIApplication.shared.delegate as? AppDelegate else {
     return
     }
     
     // 1
     let managedContext =
     appDelegate.persistentContainer.viewContext
     
     // 2
     let entity =
     NSEntityDescription.entity(forEntityName: "Status",
     in: managedContext)!
     
     let person = NSManagedObject(entity: entity,
     insertInto: managedContext)
     
     // 3
     person.setValue(name, forKeyPath: "temp")
     
     // 4
     do {
     try managedContext.save()
     temps.append(person)
     } catch let error as NSError {
     print("Could not save. \(error), \(error.userInfo)")
     }
     }
     */
    @IBAction func unwindToStatusVC (segue: UIStoryboardSegue)
       {
           // Back으로 올때 호출되는 함수
           // segue를 통해서, 어느 뷰컨트롤러에서 오는 것인지 구분할 수 있다.
           // 내부코드 필요 없음
           if segue.source is InputVC {
               print("Coming from Admin View Controller")
           }
       }
}
