//
//  WorldViewController.swift
//  mARked
//
//  Created by Katherine Cabrera on 4/25/18.
//  Copyright © 2018 AGlez. All rights reserved.
//

import UIKit
import AWSAPIGateway

class WorldViewController: UIViewController{
    
  
    
    let client = MARKED_APIMARkedAPIClient.default()
    var otherUsers: [String] = []
    var searchParam: String = ""
   // let query = searchQuery.text
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  username =  AppState.shared.username
        print("this is my usernamr \(username)")
        
        
    }
    
    
    @IBAction func goPressed(_ sender: Any) {
//        searchParam = searchField.text!
        print(searchParam)
        if let username = AppState.shared.username{
            client.followersQueryGet(query: searchParam, username: username).continueWith {(task:AWSTask) -> AnyObject? in
                //// print(task.result as Any)
                
                let allUsers = task.result as! NSDictionary
                let keys = allUsers.allKeys as! [String]
                
                for key in keys {
                    let arr = allUsers[key] as? NSArray
                    // print(arr![1] as Any)
                    for user in arr! {
                        let innerArr=user as? NSArray
                        print(innerArr![1])
                        self.otherUsers.append(innerArr![1] as! String)
                    }
                    
                }
                return nil
            }
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}
