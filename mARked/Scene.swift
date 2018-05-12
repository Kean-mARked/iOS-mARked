//
//  Scene.swift
//  mARked
//
//  Created by Arian Gonzalez on 3/26/18.
//  Copyright © 2018 AGlez. All rights reserved.
//

import SpriteKit
import ARKit
import CoreLocation

class Scene: SKScene{
    
    let client = MARKED_APIMARkedAPIClient.default()
    var postID = NSMutableSet ()
    var count = 0
    var creationTime = 0.0
   
    override func didMove(to view: SKView) {
        // Setup your scene here
       // print("Did move is called!")
        
    }
    
    override func update(_ currentTime: TimeInterval) {
       
        // Called before each frame is rendered
        let longi = AppState.shared.longitude
        let lati = AppState.shared.latitude
        if longi != nil {
            if let longitude = longi {
                if let latitude = lati {
                    if (currentTime > creationTime && AppState.shared.flagPost) {
                   
                       
                        creationTime = currentTime + TimeInterval(Float.random(min: 10.0, max: 16.0))
                        client.postsGet(username: "*", radius: "0.02", lat: "\(latitude)", lon: "\(longitude)").continueWith {(task:AWSTask) -> AnyObject? in // creates another thread
                            print("API IS CALLED \(self.count)")
                            self.count = self.count + 1
                            if task.result != nil {
                                let result = task.result as! NSDictionary
                                let keys = result.allKeys as! [String]
                                
                                for key in keys{
                                    
                                    let arr = result[key] as? NSArray
                                    for post in arr! {
                                        
                                        let dic = post as? NSDictionary
                                        for id in (dic?.allKeys)!{
                                            if self.postID.contains(id) {
                                                continue
                                            }else{
                                                //create post
                                                var str = dic![id] as! String
                                                str = "\(key):\n\(str)"
                                                sleep(1)

                                                self.postID.add(id)
                                                self.generateAutoMarker(message: str)
                                                
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            print("This is the set \(self.postID)")
                            return nil
                        }
                        
                        if let username = AppState.shared.username{
                            self.client.followersGet(username: username).continueWith {(task:AWSTask) -> [String]? in
                                //                    print("printing task in getFriends")
                                //                    print(task.result as Any)
                                //                    print("finished printing the task in the api call return")
                                //                                self.savedTask = task
                                AppState.shared.myFollowers = []
                                let followers = task.result as! NSDictionary
                                let keys = followers.allKeys as! [String]
                                for key in keys {
                                    let arr = followers[key] as? NSArray
                                    // print(arr![1] as Any)"
                                    for friend in arr! {
                                        let innerArr=friend as? NSArray
                                        //print("result from api?: \(innerArr![1])")

                                        AppState.shared.myFollowers.append(innerArr![1] as! String)
                                        //                                    self.myFollowersLocal.append(innerArr![1] as! String)
                                    }
                                }
                                //                group.leave()

                                //


                                return nil
                            }
                        }
                    }
                    
                }
                
               
            }
           
            }

        
    }
    

    
    public func createMarker() {
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
       
            if let currentFrame = sceneView.session.currentFrame {
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.8
                let transform = simd_mul(currentFrame.camera.transform, translation)
                // Add a new anchor to the session
                let anchor = ARAnchor(transform: transform)
                sceneView.session.add(anchor: anchor)
            
            }
        
    }



    func generateAutoMarker(message: String){
        
       AppState.shared.message = message
        print(" this is the message \(AppState.shared.message)")
       
        guard let sceneView = self.view as? ARSKView else {
            return
        }
       
        if let currentFrame = sceneView.session.currentFrame {
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = Float.random(min: -2, max: 2)
            translation.columns.3.y = Float.random(min: -2, max: 2)
            
            let transform = simd_mul(currentFrame.camera.transform, translation)
            //print(transform)
            //print(currentFrame.camera.transform)
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
public extension Float {
    
    // Returns a random floating point number between 0.0 and 1.0, inclusive.
    
    public static var random:Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    /*
     Create a random num Float
     
     - parameter min: Float
     - parameter max: Float
     
     - returns: Float
     */
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
    
    }




