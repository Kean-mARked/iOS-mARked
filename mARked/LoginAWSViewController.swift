//
//  ViewController.swift
//  loginCognito
//
//  Created by Carlos A Flores on 2/13/18.
//  Copyright © 2018 Carlos A Flores. All rights reserved.
//

import UIKit
import AWSAuthUI
import AWSAPIGateway
import AWSMobileClient
import AWSUserPoolsSignIn
import CoreLocation

class LoginAWSViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var textField: UILabel!
    @IBOutlet weak var longTextField: UITextView!
    @IBOutlet weak var postTextField: UITextView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var newPostText: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let identityId = AWSIdentityManager.default().identityId
    var userName: String = ""
    var allUsersPosts = [String]()
    
    let locationManager = CLLocationManager()
    let client = MARKED_APIMARkedAPIClient.default()
    var myUserName: String = ""
    var myLat: Double = 0
    var myLon: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestAlwaysAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            print("reached the cllocationmanager code i think location services are enabled")
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            presentAuthUIViewController()
        } else {
            print("\n\n\nyoure logged in actually lol\n\n")
        }
        
        longTextField.text = identityId
        locationManager.requestLocation()
        
        AWSCognitoIdentityUserPool.default().currentUser()?.getDetails().continueWith { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: " + (task.error?.localizedDescription)!)
                
            } else {
                //                let cognitoId = task.result!
                //                print("\(cognitoId)")
                let response: AWSCognitoIdentityUserGetDetailsResponse? = task.result
                //let userAttributes = response?.userAttributes
                self.myUserName = (response?.username)!
                print("YOUR USERNAME: \(response?.username)")
            }
            return nil
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
//            print("location:: \(locations.first?.coordinate)")
//            postTextField.text = "\(String(describing: locations.first?.coordinate))"
//            let mylatstring = locations.first?.coordinate.latitude
            myLat = (locations.first?.coordinate.latitude)!
            myLon = (locations.first?.coordinate.longitude)!
        }
        
    }
    
    
    func showResult(task: AWSTask<AnyObject>) {
        if let error = task.error {
            print("Error: \(error)")
        } else if let result = task.result {
             if result is NSDictionary {
                let res = result as! NSDictionary
                print("printing keys\n\n")
                let keys = res.allKeys as! [String]
                print(type(of: keys))
                print(keys)
                allUsersPosts = res.object(forKey: userName) as! [String] // array<String>
                print("in show results going to print posts \(allUsersPosts)")                
                print("\n\nleaving showResult task")
            }
        } else {
            print("\n\n\nWOW WTF DID I GET BACK FROM AWS??\n\n\n")
        }
    }
    
    func presentAuthUIViewController() {
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.22, alpha:1.0)
        config.font = UIFont (name: "Helvetica Neue", size: 20)
        config.logoImage = #imageLiteral(resourceName: "MarkerLogo")
        config.canCancel = true
        
        AWSAuthUIViewController.presentViewController(
            with: self.navigationController!,
            configuration: config, completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                if error == nil {
                    // SignIn succeeded.
                } else {
                    // end user faced error while loggin in, take any required action here.
                }
        })
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    // MARK: Actions
    @IBAction func callAPILambda(_ sender: UIButton) {
        userName = userNameField.text!
       
        print("about to call rootGet()API for marked\n\n\n")
        
        let group = DispatchGroup()
        group.enter()
        
        if (userName == "*") {
            client.postsGet(username: "*", radius: "4", lat: "\(myLat)", lon: "\(myLon)").continueWith {(task:AWSTask) -> AnyObject? in // creates another thread
                print("about to print the task \n\n")
                print(task.result as Any)
                self.showResult(task: task )
                group.leave()
                return nil
            }
        } else {
            client.postsUsernameGet(username: userName).continueWith {(task:AWSTask) -> AnyObject? in // creates another thread
                print("about to print the task \n\n")
                print(task.result as Any)
                self.showResult(task: task )
                group.leave()
                return nil
            }
        }

        group.notify(queue: .main) {
            print("printing allUserPosts in group code")
            let postString = self.allUsersPosts.joined(separator: "\n\n")
            self.postTextField.text = postString

        }
    }
    
    @IBAction func makeNewPost(_ sender: UIButton) {
        print("\n\n\nMAKENEWPOST\n\n")
        let postText = newPostText.text
        print("about to make a post with username: \(myUserName)")
        print("message: \(postText)")
        print("lat: \(myLat) lon: \(myLon)")
        
        client.postsUsernamePost(username: myUserName   , message: postText, lat: "\(myLat)", lon: "\(myLon)").continueWith {(task:AWSTask) -> AnyObject? in // creates another thread
            print("result from trying to post")
            print(task.result as Any)
            return nil
        }
        showToast(message: "Post successful!")
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        AWSSignInManager.sharedInstance().logout { (result: Any?, error: Error?) in
            print("\nUser logged out\n")
        }
        presentAuthUIViewController()
    }
    
    @IBAction func cloudSync(_ sender: UIButton) {
        print("sync to cloud dummy text")
    }
    
}
