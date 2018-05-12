//
//  ViewController.swift
//  mARked
//
//  Created by Katherine Cabrera, Carlos Flores, Arian Gonzalez, on 3/26/18.
//  Copyright © 2018 AGlez. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import AWSCore
import AWSAPIGateway
import AWSAuthUI
import AWSMobileClient
import AWSUserPoolsSignIn
import CoreLocation
import Foundation

public class AppState {
    public var message: String? = nil
    public var longitude:Double? = nil
    public var latitude:Double? = nil
    public var username:String? = nil
    public var myFollowers: [String] = []
    public static let shared = AppState()
    public  var flagPost = false
    public var friendsAreReady = false
    

}

class ViewController: UIViewController, ARSKViewDelegate, UITextViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var markerTextField: UITextView!
    @IBOutlet weak var markerImg: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var buttonMaker: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sceneView: ARSKView!
    
    var location:CLLocation!
    let locationManager = CLLocationManager()
    let client = MARKED_APIMARkedAPIClient.default()
    var postID = NSMutableSet ()
    var responseUsername: String = ""
    var myFollowersLocal: [String] = []
    var savedTask: AWSTask =  AWSTask<AnyObject>(result: nil)
    
    /*Button Functions
     * This functions costumize the funcionality of each button.
     *
     */
    
    @IBAction func cancelFunc(_ sender: Any) {
        performUIChange(didChange: false)
    }
    
    @IBAction func markerButton(_ sender: Any) {
        performUIChange(didChange: true)
    }
    
    @IBAction func SubmitMarker(_ sender: Any) {
        AppState.shared.message = markerTextField.text
        performUIChange(didChange: false)
        createMarker()
    }
    
    /* View Controller Extensions
     * This functions will control the the view loads
     *
     */

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set the view's delegate
        sceneView.delegate = self
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        // Show statistics such as fps and node count
//        sceneView.showsFPS = true
//        sceneView.showsNodeCount = true
        
       
        if !AWSSignInManager.sharedInstance().isLoggedIn {
//            AppState.shared.flagPost = false
//                self.sceneView.session.pause()
                self.presentAuthUIViewController()
        } else {
            print("User is logged in")
            AppState.shared.flagPost = true
        }
       
        //getCurrent User info
//        let group1 = DispatchGroup()
//        group1.enter()
//
//        DispatchQueue.main.async {
            AWSCognitoIdentityUserPool.default().currentUser()?.getDetails().continueWith { (task: AWSTask!) -> AnyObject? in
                if (task.error != nil) {
                    print("Error: " + (task.error?.localizedDescription)!)

                } else {
                    //let cognitoId = task.result!
                    let response: AWSCognitoIdentityUserGetDetailsResponse? = task.result
                    //let userAttributes = response?.userAttributes
                    self.responseUsername = (response?.username)!
                    //print("\n\n\nPRINTING USERNAME FROM GETDETAILS(): \(response?.username)")
                    AppState.shared.username = (response?.username)!
//                    group1.leave()
                }
                return nil
            }
//        }
//
//         group1.notify(queue: .main) {
//            print("USER NAME ISSSSSSS: \(self.responseUsername)")
//            self.getFollowers()
//        }
//
        print("i think getFollowers code running")

        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        //Set ups location request
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            AppState.shared.latitude = locationManager.location?.coordinate.latitude
            AppState.shared.longitude = locationManager.location?.coordinate.longitude

        }
        locationManager.requestLocation()
        
        

    }

    
    func getFollowers() {
        print("begin getFollowers")
//        let group = DispatchGroup()
//        group.enter()
//
//        // avoid deadlocks by not using .main queue here
//        DispatchQueue.global(qos: .background).async {
            self.client.followersGet(username: self.responseUsername).continueWith {(task:AWSTask) -> [String]? in
                //                    print("printing task in getFriends")
                //                    print(task.result as Any)
                //                    print("finished printing the task in the api call return")
                self.savedTask = task
                AppState.shared.myFollowers = []
                let followers = self.savedTask.result as! NSDictionary
                let keys = followers.allKeys as! [String]
                
                for key in keys {
                    let arr = followers[key] as? NSArray
                    // print(arr![1] as Any)"
                    for friend in arr! {
                        let innerArr=friend as? NSArray
                        //print("result from api?: \(innerArr![1])")
                        
                        AppState.shared.myFollowers.append(innerArr![1] as! String)
                        self.myFollowersLocal.append(innerArr![1] as! String)
                    }
                }
//                group.leave()

                //
                return nil
            }
//        }
        //            concurrentQueue.async {
        //                self.client.followersGet(username: self.responseUsername).continueWith {(task:AWSTask) -> [String]? in
        ////                    print("printing task in getFriends")
        ////                    print(task.result as Any)
        ////                    print("finished printing the task in the api call return")
        //                    self.savedTask = task
        //                    group.leave()
        //                    //
        //                    return nil
        //                }
        //            }
        // wait ...
//        group.wait()
       
        
        print("I want to print followers!!!!!!! trying appstate")
        for people in AppState.shared.myFollowers {
            print("AppState shared follower: \(people)")
        }
        
        print("I want to print followers!!!!!!! trying local array")
        for people in self.myFollowersLocal {
            print("Local followers: \(people)")
        }
        
        print("leaving getFollowers")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
       
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        
    }
    
    // MARK: - ARSKViewDelegate
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        getFollowers()
    }
    
    /* User Interface Control
     * This functions will control the user interface in the Main View.
     *
     */
    
    func presentAuthUIViewController() {
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.22, alpha:1.0)
        config.font = UIFont (name: "Helvetica Neue", size: 12)
        config.logoImage = #imageLiteral(resourceName: "MarkerLogo")
        
        // config.canCancel = false
//        let group = DispatchGroup();
//        group.enter()
//        group.leave()
//        DispatchQueue.main.async {}
//        group.notify(queue: .main) {
//            AppState.shared.flagPost = true
//            let configuration = ARWorldTrackingConfiguration()
//            self.sceneView.session.run(configuration)
//        }
        AWSAuthUIViewController.presentViewController(
            with: self.navigationController!,
            configuration: config, completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                if error == nil {
                    // SignIn succeeded.
                    //check if user is logged in
                    AppState.shared.flagPost = true
                } else {
                    // end user faced error while loggin in, take any required action here.
                }
        })
      
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"
        {
           AppState.shared.message = markerTextField.text
            performUIChange(didChange: false)
            createMarker()
            
            return false
        }
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 112
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(markerTextField.text == "Leave your Mark...")
        {
            markerTextField.text =  ""
        }
        markerTextField.becomeFirstResponder()
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if(markerTextField.text == "")
        {
            markerTextField.text =  "Leave your Mark..."
        }
        markerTextField.resignFirstResponder()
    }
    
    func performUIChange(didChange:Bool) {
        
        if didChange
        {
            markerImg.isHidden = false
            markerTextField.isHidden = false
            buttonMaker.isHidden = true
            submitButton.isHidden = false
            cancelButton.isHidden =  false
        }else
        {
            markerImg.isHidden = true
            cancelButton.isHidden =  true
            markerTextField.isHidden = true
            buttonMaker.isHidden = false
            submitButton.isHidden = true
            markerTextField.resignFirstResponder()
            markerTextField.text =  "Leave your Mark..."
        }
    }
    
    /* Location Functions
     * This functions will control location functionally.
     *
     */
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            AppState.shared.latitude = (locations.first?.coordinate.latitude)!
            AppState.shared.longitude = (locations.first?.coordinate.longitude)!
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
    
    
    /* AR Functions
     * This functions will control the AR
     *
     */
    
    func createMarker(){
        
        if let longitude = AppState.shared.longitude {
            
            if let latitude = AppState.shared.latitude {
                if let username =  AppState.shared.username{
                    client.postsUsernamePost(username: username   , message: AppState.shared.message, lat: "\(latitude)", lon: "\(longitude)").continueWith {(task:AWSTask) -> AnyObject? in
                        // creates another thread
                        print(task.result as Any)
                        return nil
                    }
                    
                }
                
            }
            
        }

     
    }
 
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let Image =  #imageLiteral(resourceName: "MarkerView") //do your setup here to make a UIImage
        let Texture = SKTexture(image: Image)
        let Sprite = SKSpriteNode(texture:Texture)
        
        let myLabel = SKLabelNode(fontNamed:"Avenir Book")
        myLabel.text =  AppState.shared.message
        myLabel.fontSize = 8
        myLabel.fontColor = UIColor.black
        myLabel.horizontalAlignmentMode = .center
        myLabel.verticalAlignmentMode = .bottom
        myLabel.zPosition = 2.0
        myLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        myLabel.numberOfLines = 4
        myLabel.preferredMaxLayoutWidth = 110
        Sprite.addChild(myLabel)
        return Sprite;
        
    }
    
    func getFriends(){
        print("\n\nLmao Hi! getFriends() was called!\n\n")
        
        if let username = AppState.shared.username{
            client.followersGet(username: username).continueWith {(task:AWSTask) -> [String]? in
                print("printing task in getFriends")
                print(task.result as Any)
                let followers = task.result as! NSDictionary
                let keys = followers.allKeys as! [String]
                
                for key in keys {
                    let arr = followers[key] as? NSArray
                    // print(arr![1] as Any)
                    for friend in arr! {
                        let innerArr=friend as? NSArray
                        print(innerArr![1])
                        AppState.shared.myFollowers.append(innerArr![1] as! String)
                    }
                    
                    //print (self.myFollowers[0])
                    //let types = type(of:friend)
                    //print("\(types)")
                }
                //
                return nil
            }
            
        }
        
    }
    
    
}
