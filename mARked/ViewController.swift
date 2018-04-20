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

class ViewController: UIViewController, ARSKViewDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var markerTextField: UITextView!
    @IBOutlet weak var markerImg: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var buttonMaker: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sceneView: ARSKView!
    
    var myUserName = ""
    var message:String = ""
    var location:CLLocation!
    let locationManager = CLLocationManager()
    var myLat: Double = 0
    var myLon: Double = 0
    var altitude:Double = 0
    let client = MARKED_APIMARkedAPIClient.default()
    var postID = NSMutableSet ()
    
    
    
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
        message = markerTextField.text
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
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        //check if user is logged in
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            presentAuthUIViewController()
        } else {
            print("User is logged in")
        }
        
        //getCurrent User info
        AWSCognitoIdentityUserPool.default().currentUser()?.getDetails().continueWith { (task: AWSTask!) -> AnyObject? in
            if (task.error != nil) {
                print("Error: " + (task.error?.localizedDescription)!)
                
            } else {
                //let cognitoId = task.result!
                let response: AWSCognitoIdentityUserGetDetailsResponse? = task.result
                //let userAttributes = response?.userAttributes
                self.myUserName = (response?.username)!
            }
            return nil
        }
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        //Set ups location request
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        locationManager.requestLocation()
        
        
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"
        {
            message = markerTextField.text
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
            myLat = (locations.first?.coordinate.latitude)!
            myLon = (locations.first?.coordinate.longitude)!
            altitude = (locations.first?.altitude)!
            generateAutoMarker(message: "test")
            
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
    
    func createMarker() {
        
        client.postsUsernamePost(username: myUserName   , message: message, lat: "\(myLat)", lon: "\(myLon)").continueWith {(task:AWSTask) -> AnyObject? in
            // creates another thread
            print(task.result as Any)
            return nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
            if let currentFrame = self.sceneView.session.currentFrame {
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1
                let transform = simd_mul(currentFrame.camera.transform, translation)
                // Add a new anchor to the session
                let anchor = ARAnchor(transform: transform)
                self.sceneView.session.add(anchor: anchor)
            }
            
        }
    }
    
    func generateMarker(){
        
        client.postsGet(username: "*", radius: ".002", lat: "\(myLat)", lon: "\(myLon)").continueWith {(task:AWSTask) -> AnyObject? in // creates another thread
            let result = task.result as! NSDictionary
            let keys = result.allKeys as! [String]
            
            for key in keys{
                let arr = result[key] as? NSArray
                for post in arr! {
                    let dic = post as? NSDictionary
                    
                    for id in (dic?.allKeys)!{
                        
                        if self.postID.contains(id){
                            continue
                        }else{
                            //create post
                            self.postID.add(id)
                            print(dic![id] as! String)
                            
                            let group = DispatchGroup()
                            group.enter()
                            
                            
                            group.notify(queue: .main) {
                                print("printing allUserPosts in group code")
                                self.generateAutoMarker(message: dic![id] as! String)
                                
                            }
                        }
                        
                    }
                }
            }
             return nil
        }
    }
    
    
    func generateAutoMarker(message: String){
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
        if let currentFrame = self.sceneView.session.currentFrame {
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = self.randomPosition()
            translation.columns.3.y = self.randomPosition()
            translation.columns.3.w = 5
            let transform = simd_mul(currentFrame.camera.transform, translation)
            //print(transform)
            //print(currentFrame.camera.transform)
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            self.sceneView.session.add(anchor: anchor)
        }
    }
        
    }
    
    func randomPosition() -> Float{
        
        return  (Float(arc4random()) / 0xFFFFFFFF) * (2.0 - (-2.0) + (-2.0))
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let Image =  #imageLiteral(resourceName: "MarkerView") //do your setup here to make a UIImage
        let Texture = SKTexture(image: Image)
        let Sprite = SKSpriteNode(texture:Texture)
        
        let myLabel = SKLabelNode(fontNamed:"Avenir Book")
        myLabel.text =  message
        print(message)
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
                //                allUsersPosts = res.object(forKey: userName) as! [String] // array<String>
                //                print("in show results going to print posts \(allUsersPosts)")
                print("\n\nleaving showResult task")
            }
        } else {
            print("\n\n\nWOW WTF DID I GET BACK FROM AWS??\n\n\n")
        }
    }
    
    
}
