//
//  ConfigViewController.swift
//  hsm-test
//
//  Created by François Schauber on 29/10/2015.
//  Copyright © 2015 François Schauber. All rights reserved.
//

import UIKit
import Foundation

class ConfigViewController: UIViewController {

    @IBOutlet weak var textFieldHsmIP: UITextField!
    @IBOutlet weak var textFieldLogin: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonNext: UIButton!

    
    @IBAction func saveData(sender: UIButton) {
        print("Save")
        
        if (self.textFieldHsmIP.text == "" ||
            self.textFieldLogin.text == "" ||
            self.textFieldPassword.text == "") {
                let alertView = UIAlertController(title: "Saving problem",
                    message: "Set all fields." as String, preferredStyle:.Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
                return;
        }
        
        NSUserDefaults.standardUserDefaults().setValue(self.textFieldHsmIP.text, forKey: "hsmIp")
        NSUserDefaults.standardUserDefaults().setValue(self.textFieldLogin.text, forKey: "login")
        
        KeychainWrapper.setString(self.textFieldPassword.text!, forKey: "password")
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isDataSaved")
        
        self.textFieldHsmIP.resignFirstResponder()
        self.textFieldLogin.resignFirstResponder()
        self.textFieldPassword.resignFirstResponder()
        
        self.performSegueWithIdentifier("segueHelpdesk", sender: nil)
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldPassword.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
        self.textFieldLogin.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
        self.textFieldHsmIP.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
        
        let hasHsmIpKey = NSUserDefaults.standardUserDefaults().boolForKey("isDataSaved")
        if hasHsmIpKey == true {
            self.textFieldHsmIP.text = (NSUserDefaults.standardUserDefaults().valueForKey("hsmIp") as! String)
            self.textFieldLogin.text = (NSUserDefaults.standardUserDefaults().valueForKey("login") as! String)
            self.textFieldPassword.text = KeychainWrapper.stringForKey("password")!
            
            textFieldDidChange()
            
        }

    }
    
    func textFieldDidChange() {
        if self.textFieldHsmIP.text?.characters.count != 0 &&
            self.textFieldLogin.text?.characters.count != 0 &&
            self.textFieldPassword.text?.characters.count != 0 {
            self.buttonNext.hidden = false
        } else {
            self.buttonNext.hidden = true
        }
    }
    
}
