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
        print("Did move is called!")
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (currentTime > creationTime) {
            print("current Time: \(currentTime)\nCreationTime: \(creationTime)")
        }
        // Called before each frame is rendered
        let longi = AppState.shared.longitude
        let lati = AppState.shared.latitude
        if longi != nil {
            if let longitude = longi {
                if let latitude = lati {
                    if (currentTime > creationTime) {
                        print("LMAO CALLING API")
                        creationTime = currentTime + TimeInterval(Float.random(min: 10.0, max: 16.0))
                        client.postsGet(username: "*", radius: "0.02", lat: "\(latitude)", lon: "\(longitude)").continueWith {(task:AWSTask) -> AnyObject? in // creates another thread
                            print("API Called times: \(self.count)")
                            self.count = self.count + 1
                            print("\n\n\n\n")
                            print(task.result)
                            print("\n\n\n\n")
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
                                                let str = dic![id] as! String
                                                print("about to create node with message: \(str)")
                                                sleep(1)
                                                print("i just woke up and the marker should have been created")
                                                self.postID.add(id)
                                                self.generateAutoMarker(message: dic![id] as! String)
                                               

                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            return nil
                        }
                    }
                    
                }
                
               
            }
           
            }

        
    }
    
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//
//        // Create anchor using the camera's current position
//        if let currentFrame = sceneView.session.currentFrame {
//
//            // Create a transform with a translation of 0.2 meters in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.2
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            sceneView.session.add(anchor: anchor)
//        }
//    }
    
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
        print("FROM GENERATEMARKERCLASS          \(AppState.shared.message)")
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
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




