//
//  DateVC.swift
//  WidgetApp
//
//  Created by Faraz_Ahmed on 07/10/2020.
//

import UIKit
import WidgetKit

class DateVC: UIViewController {
    
    var dat: String?
    
    @IBOutlet weak var datePick: UIDatePicker!
    @IBOutlet weak var textData: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if textData.text!.isEmpty {
            let alert = UIAlertController(title: "", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            switch action.style{
                                            case .default:
                                                print("default")
                                                
                                            case .cancel:
                                                print("cancel")
                                                
                                            case .destructive:
                                                print("destructive")
                                            }}))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dat = dateFormatter.string(from: datePick.date)
            self.dat = dat
            print(self.dat ?? "")
            self.present(alert, animated: true, completion: nil)
        }else{
            UserDefaults.group.set(self.dat ?? "", forKey: "date")
            UserDefaults.group.set(self.textData.text ?? "", forKey: "text")
            NotificationCenter.default.post(name: Notification.Name("text"), object: self.textData.text ?? "")
            NotificationCenter.default.post(name: Notification.Name("date"), object: self.dat)
            let alert = UIAlertController(title: "", message: "Saved!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            switch action.style{
                                            case .default:
                                                print("default")
                                                
                                            case .cancel:
                                                print("cancel")
                                                
                                            case .destructive:
                                                print("destructive")
                                            }}))
            print(self.dat ?? "")
            self.present(alert, animated: true, completion: nil)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @IBAction func dataPickerPicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dat = dateFormatter.string(from: datePick.date)
        self.dat = dat
    }
    
}
extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.com.soup.ios.app")!
}
