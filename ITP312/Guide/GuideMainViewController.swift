//
//  GuideMainViewController.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GuideMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellID = "GuideCell"
    
    @IBOutlet weak var guideTableView: UITableView!
    @IBOutlet weak var viewButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    var guides:[Guide] = []
    var guideRole = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guideTableView.register(GuideCell.self, forCellReuseIdentifier: cellID)
        guideTableView.delegate = self
        guideTableView.rowHeight = 75
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        observeRefreshGuides()
    }
    
    func observeRefreshGuides () {
        Database.database().reference().child("guide").observe(.value) { (snapshot) in
            self.guides.removeAll()
            if let dictionary = snapshot.value as? [String:AnyObject] {
                for i in dictionary {
                    let guide = Guide(dictionary: i.value as! [String : AnyObject])
                    self.guides.append(guide)
                    if guide.guideID == Auth.auth().currentUser?.uid {
                        self.guideRole = true
                    }
                }
                
                if self.guideRole {
                    self.viewButton.isEnabled = true
                    self.createButton.isEnabled = false
                } else {
                    self.viewButton.isEnabled = false
                    self.createButton.isEnabled = true
                }
                
                self.guideTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! GuideCell
        let guide = guides[indexPath.row]
        cell.guide = guide
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let guide = guides[indexPath.row]
        let guideID = guide.guideID!
        let ref = Database.database().reference().child("/users/\(guideID)/")
        ref.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(
                id: guideID,
                name: dictionary["name"]! as! String,
                email: dictionary["email"]! as! String,
                profileURL: dictionary["profileURL"]! as! String
            )
            self.showGuideDetails(user: user, guide: guide)
        })
    }
    
    private func showGuideDetails(user: User, guide: Guide) {
        let GuideDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetail") as! GuideDetailViewController
        GuideDetailViewController.user = user
        GuideDetailViewController.guide = guide
        self.navigationController?.pushViewController(GuideDetailViewController, animated: true)
    }

}
