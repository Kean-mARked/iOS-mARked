//
//  FViewController.swift
//  mARked
//
//  Created by Katherine Cabrera on 4/25/18.
//  Copyright © 2018 AGlez. All rights reserved.
//

import UIKit

class FViewController: UIViewController, UITableViewDataSource{

    let client = MARKED_APIMARkedAPIClient.default()
    var myFollowers: [String] = []
    let hardFollowers = [
    ("ariangonzalez"),
    ("ranaris")
    ]
    
  
    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\nCalled viewDidLoad()\n\n")
        print(AppState.shared.myFollowers)
//        let group = DispatchGroup()
//        group.enter()
//
//        DispatchQueue.main.async {
//            self.getFriends()
//            group.leave()
//        }
//
//        // does not wait. But the code in notify() gets run
//        // after enter() and leave() calls are balanced
//
//        group.notify(queue: .main) {
//            self.friendTableView.reloadData()
//        }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        print("\n\nCalled ViewWillAppear\n\n")
        friendTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.shared.myFollowers.count       //return myFollowers.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FriendCell
        let cell = friendTableView.dequeueReusableCell(withIdentifier: "cell") as! FriendCell
//        print("My followers are : \(myFollowers[indexPath.row])")
        
        cell.username = AppState.shared.myFollowers[indexPath.row]
//        let (follower) =
         //let(follower) = hardFollowers[indexPath.row]
//        cell.textLabel?.text = follower
        return cell
    }
//    func getFriends(){
//        print("\n\nLmao Hi! getFriends() was called!\n\n")
//        
//        if let username = AppState.shared.username{
//            client.followersGet(username: username).continueWith {(task:AWSTask) -> [String]? in
//                print("printing task in getFriends")
//                print(task.result as Any)
//                let followers = task.result as! NSDictionary
//                let keys = followers.allKeys as! [String]
//                
//                for key in keys {
//                    let arr = followers[key] as? NSArray
//                    // print(arr![1] as Any)
//                    for friend in arr! {
//                        let innerArr=friend as? NSArray
//                        print(innerArr![1])
//                        self.myFollowers.append(innerArr![1] as! String)
//                    }
//                    
//                    //print (self.myFollowers[0])
//                    //let types = type(of:friend)
//                    //print("\(types)")
//                }
//                //
//                return nil
//            }
//            
//        }
//        
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
