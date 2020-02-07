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
    @IBOutlet weak var createButton: UIButton!
    
    
    var guides:[Guide] = []
    var guideRole = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guideTableView.register(GuideCell.self, forCellReuseIdentifier: cellID)
        guideTableView.delegate = self
        guideTableView.rowHeight = 90
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
                    if guide.guideID == Auth.auth().currentUser?.uid {
                        self.guideRole = true
                    } else {
                        self.guides.append(guide)
                    }
                    self.toggleRole(isGuide: self.guideRole)
                }
                self.attemptReload()
            }
        }
    }
    
    func toggleRole (isGuide: Bool) {
        if isGuide {
            createButton.setTitle("My Guide Profile", for: .normal)
        } else {
            createButton.setTitle("Become New Guide!", for: .normal)
        }
    }
    
    var timer:Timer?
    private func attemptReload() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
            guide1.fromDate! > guide2.fromDate!
        })
        guideTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! GuideCell
        let guide = guides[indexPath.row]
        if guide.guideID != Auth.auth().currentUser?.uid{
            cell.guide = guide
        }
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
