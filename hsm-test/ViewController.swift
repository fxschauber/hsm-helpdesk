//
//  ViewController.swift
//  hsm-test
//
//  Created by François Schauber on 12/10/2015.
//  Copyright © 2015 François Schauber. All rights reserved.
//

import UIKit
import Foundation



class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerHelpdeskType: UIPickerView!
    
    var pickerData = [String]()
    var helpdeskType = "001"
    var text:NSString = ""
    
    var password:String = ""
    var hsmIp:String = ""
    var login:String = ""
    
    @IBAction func typeLockCode(sender: UITextField) {
        if(sender.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 19) {
            return
        }
        self.display.text = ""
        sender.resignFirstResponder()
        let str = sender.text!;
        let k1 = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(3), end: str.startIndex.advancedBy(3 + 4)))
        let k2 = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(7), end: str.startIndex.advancedBy(7 + 4)))
        let k3 = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(11), end: str.startIndex.advancedBy(11 + 4)))
        let k4 = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(15), end: str.startIndex.advancedBy(15 + 4)))
        
        let urlString = String(format: "http://" + self.hsmIp + "/sc_hsm/unlocker.php?cliente=1&k1=%@&k2=%@&k3=%@&k4=%@&k5=%@&merchant_name=&zip_code=&city=&country=&company_name=&tech_first_name=&tech_last_name=&device_type=&device_number=&pn=&device_sn=&comment=", helpdeskType, k1, k2, k3, k4);
//        NSLog(urlString);
        
        let url = NSURL(string: urlString )
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            data, response, error in
            if error != nil {
                NSLog("error=\(error)")
                return
            }
            
//            NSLog("**** response=\(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if(responseString == nil) {
                NSLog("**** responseString == nil !")
                return
            }
            
            // Regex for unlock code in <body>
            let unlockCodePattern = "\\d{4}\\s\\d{3}\\s\\d{3}"
            
            do {
                let responseDataString = responseString as! String
//                NSLog("responseDataString=\(responseDataString)")
                
                let stringSize = Int(strlen(responseDataString))
                let regex = try NSRegularExpression(pattern: unlockCodePattern, options: [])
                let matchRange = regex.firstMatchInString(responseDataString, options: [], range: NSMakeRange(0, stringSize))
                
                if(matchRange != nil) {
                    let unlockCode = responseString!.substringWithRange(matchRange!.range)
//                    NSLog("\(unlockCode)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.display.text = unlockCode
                    })
                    
                }
            } catch {
                NSLog("error:\(error)")
            }
            
        }
        task.resume()
        
    }

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.textField.clearsOnBeginEditing = true
        self.textField.clearButtonMode = UITextFieldViewMode.UnlessEditing
        self.pickerHelpdeskType.delegate = self
        self.pickerHelpdeskType.dataSource = self
        self.pickerData = ["Antiremoval", "Disable Antiremoval", "Internal Sensors", "Pairing"]
        
        // Config View
        let hasHsmIpKey = NSUserDefaults.standardUserDefaults().boolForKey("isDataSaved")
        if hasHsmIpKey == true {
            hsmIp = NSUserDefaults.standardUserDefaults().valueForKey("hsmIp") as! String
            login = NSUserDefaults.standardUserDefaults().valueForKey("login") as! String
            password = KeychainWrapper.stringForKey("password")!
        }
        
        
        // Logs
        let docDirectory: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
        let logpath = docDirectory.stringByAppendingPathComponent("log.txt")
        freopen(logpath.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
//        do {
//            text = try NSString(contentsOfFile: logpath, encoding: NSUTF8StringEncoding)
//        }
//        catch {/* error handling here */}
        let urlString = "http://" + self.hsmIp + "/sc_hsm/checklogin.php"
        let url = NSURL(string: urlString);
        let request = NSMutableURLRequest(URL: url!);
        request.HTTPMethod = "POST";

//        NSLog("App start")
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "didBeginEditing:",
            name: UITextFieldTextDidBeginEditingNotification,
            object: nil)
        
        let postString = "myusername1=" + self.login + "&mypassword1=" + self.password + "&myusername2=" + self.login + "&mypassword2=" + self.password + "&Submit=Login";
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                NSLog("error=\(error)")
                return
            }
            
//            NSLog("**** response=\(response)")
            
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            NSLog("**** response data=\(responseString)")
            
            
            // login_fail.php
        }
        task.resume()
        
    }
    
    @objc func didBeginEditing(notification: NSNotification) {
        self.textField.text = self.helpdeskType
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        NSLog("Selection: \(pickerData[row])")
        helpdeskType = String(format: "%03d", row + 1)
//        NSLog("\(helpdeskType)")
        
        if(self.textField.text?.isEmpty == false) {
            self.textField.text = helpdeskType
        }
    }
    
}

