/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var rider: UILabel!
    @IBOutlet weak var driver: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @available(iOS 8.0, *)
    func displayAlertMessage(title:String,message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var signUpState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.username.delegate = self;
        self.password.delegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @available(iOS 8.0, *)
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlertMessage("Missing Fields(s)", message: "Username and Password is required")
            
            
        }
        else
        {
            
            
            if signUpState == true
            {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                
                
                user["isDriver"] = `switch`.on
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        let errorString = error.userInfo["error"] as? String
                        
                        self.displayAlertMessage("Sign Up Failed", message: errorString!)
                        
                    }
                    else
                    {
                        if (self.`switch`.on == true) {
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        }
                        else{
                            
                        self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                    }
                }
            }
            else{
                
                PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    
                    if let user = user {
                        
                        if user["isDriver"].boolValue == true {
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        }
                        else{
                            
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                        
                        
                    } else {
                        let errorString = error?.userInfo["error"] as? String
                        
                        self.displayAlertMessage("Login Failed", message: errorString!)
                    }
                }
            }
            
        }
        
    }
    
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        if signUpState == true{
            
            signupButton.setTitle("Log In", forState: UIControlState.Normal)
            
            loginButton.setTitle(" Switch to Sign Up", forState: UIControlState.Normal)
            
            signUpState = false
            
            rider.alpha = 0
            driver.alpha = 0
            `switch`.alpha = 0
        }
        else{
            signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            loginButton.setTitle(" Switch to Log In", forState: UIControlState.Normal)
            
            signUpState = true
            
            rider.alpha = 1
            driver.alpha = 1
            `switch`.alpha = 1
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil
        {
            if PFUser.currentUser()?["isDriver"].boolValue == true {
                self.performSegueWithIdentifier("loginDriver", sender: self)
            }
            else{
                
                self.performSegueWithIdentifier("loginRider", sender: self)
            }
        }
    }
    
    
}
