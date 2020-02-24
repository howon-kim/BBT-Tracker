//
//  InputVC.swift
//  Corona Check
//
//  Created by Howon Kim on 2/24/20.
//  Copyright © 2020 Howon Kim. All rights reserved.
//

import UIKit
import CoreData

class InputVC: ViewController {
    
    var symptoms: [NSManagedObject] = []
    
    
    @IBOutlet weak var tempText: UITextField!
    @IBOutlet weak var coughButton: UIButton!
    @IBOutlet weak var sputumButton: UIButton!
    @IBOutlet weak var chillButton: UIButton!
    @IBOutlet weak var soreThroatButton: UIButton!
    @IBOutlet weak var DyspneaButton: UIButton!
    
    var isCough = false
    var isSputum = false
    var isChills = false
    var isSoreThroat = false
    var isDyspnea = false
    
    @IBAction func checkCough(_ sender: UIButton) {
        let date = Date()
        print(date)
        print(date.description(with: .current))
        isCough = !isCough
        if isCough {
            sender.setTitle("✓ 기침있음 (Cough)", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else {
            sender.setTitle("X 기침없음 (No Cough)", for: .normal)
            sender.setTitleColor(.red, for: .normal)
        }
    }
    @IBAction func checkSputum(_ sender: UIButton) {
        isSputum = !isSputum
        if isSputum {
            sender.setTitle("✓ 가래있음 (Sputum)", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else {
            sender.setTitle("X 가래없음 (No Sputum)", for: .normal)
            sender.setTitleColor(.red, for: .normal)
        }
    }
    @IBAction func checkChill(_ sender: UIButton) {
        isChills = !isChills
        if isChills {
            sender.setTitle("✓ 오한있음 (Chill)", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else {
            sender.setTitle("X 오한없음 (No Chill)", for: .normal)
            sender.setTitleColor(.red, for: .normal)
        }
    }
    @IBAction func checkSoreThroat(_ sender: UIButton) {
        isSoreThroat = !isSoreThroat
        if isSoreThroat {
            sender.setTitle("✓ 목 쓰림/목 아픔 있음 (Sore Throat)", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else {
            sender.setTitle("X 목 쓰림/목 아픔 없음 (No Sore Throat)", for: .normal)
            sender.setTitleColor(.red, for: .normal)
        }
    }
    @IBAction func checkDyspnea(_ sender: UIButton) {
        isDyspnea = !isDyspnea
        if isDyspnea {
            sender.setTitle("✓ 호흡곤란 있음 (Dyspnea)", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else {
            sender.setTitle("X 호흡곤란 없음 (No Dyspnea)", for: .normal)
            sender.setTitleColor(.red, for: .normal)
        }
    }
    @IBAction func submitButton(_ sender: Any) {
        if (tempText.text == "") {
            self.makeAlert(titleInput: "오류", messageInput: "체온이 입력되지 않았습니다")
        } else {
            if let value = Double(tempText.text!)  {
                if value > 43 || value < 32 {
                    self.makeAlert(titleInput: "오류", messageInput: "체온의 범위는 32도부터 43도까지입니다")
                } else {
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    
                    // 1
                    let managedContext =
                        appDelegate.persistentContainer.viewContext
                    
                    // 2
                    let entity =
                        NSEntityDescription.entity(forEntityName: "Symptom",
                                                   in: managedContext)!
                    
                    let symptom = NSManagedObject(entity: entity,
                                                  insertInto: managedContext)
                    
                    // 3
                    symptom.setValue(Double(tempText.text!), forKeyPath: "temp")
                    symptom.setValue(isCough, forKeyPath: "cough")
                    symptom.setValue(isSputum, forKeyPath: "sputum")
                    symptom.setValue(isChills, forKeyPath: "chill")
                    symptom.setValue(isSoreThroat, forKeyPath: "sorethroat")
                    symptom.setValue(isDyspnea, forKeyPath: "dyspnea")
                    symptom.setValue(Date(), forKeyPath: "date")
                    
                    
                    // 4
                    do {
                        try managedContext.save()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserlistUpdate"), object: nil)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    // Alert //
                    let alert = UIAlertController(title: "기록완료", message: "본 기록은 사용자의 기기에만 저장됩니다", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "완료", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "unwindToStatusVC", sender: nil)
                    }))
                    self.present(alert, animated: true)
                }
            }
            else {
                self.makeAlert(titleInput: "오류", messageInput: "체온을 소숫점으로 입력해주세요")
                
            }
            
            
            
            
        }
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
        
        coughButton.layer.cornerRadius = 10;
        coughButton.layer.masksToBounds = true;
        coughButton.layer.borderWidth = 1
        coughButton.layer.borderColor = UIColor.gray.cgColor
        
        sputumButton.layer.cornerRadius = 10;
        sputumButton.layer.masksToBounds = true;
        sputumButton.layer.borderWidth = 1
        sputumButton.layer.borderColor = UIColor.gray.cgColor
        
        chillButton.layer.cornerRadius = 10;
        chillButton.layer.masksToBounds = true;
        chillButton.layer.borderWidth = 1
        chillButton.layer.borderColor = UIColor.gray.cgColor
        
        soreThroatButton.layer.cornerRadius = 10;
        soreThroatButton.layer.masksToBounds = true;
        soreThroatButton.layer.borderWidth = 1
        soreThroatButton.layer.borderColor = UIColor.gray.cgColor
        
        DyspneaButton.layer.cornerRadius = 10;
        DyspneaButton.layer.masksToBounds = true;
        DyspneaButton.layer.borderWidth = 1
        DyspneaButton.layer.borderColor = UIColor.gray.cgColor
        // Keyboard Dismiss Feature //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        tempText.resignFirstResponder()
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
