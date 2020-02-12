//
//  GuideMainViewController.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import DropDown


class GuideMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellID = "GuideCell"
    
    @IBOutlet weak var guideTableView: UITableView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var myBookingButton: UIButton!
    @IBOutlet weak var sortBtn: UIBarButtonItem!
    
    var guides:[Guide] = []
    var users:[User] = []
    var guideRole = false
    let dropDown = DropDown()
    var ascending = false
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredGuides: [Guide] = []
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    var prevSort = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        guideTableView.register(GuideCell.self, forCellReuseIdentifier: cellID)
        guideTableView.delegate = self
        guideTableView.rowHeight = 90
        createButton.layer.cornerRadius = 18
        
        dropDown.anchorView = guideTableView
        // UIView or UIBarButtonItem
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            // Setup your custom UI components
            cell.optionLabel.textAlignment = .center
        }
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Popularity", "Country", "Start Date", "End Date"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if self.sortButton.titleLabel!.text == item {
                self.ascending.toggle()
                if self.ascending {
                    self.sortBtn.image = UIImage.init(systemName: "chevron.up")
                } else {
                    self.sortBtn.image = UIImage.init(systemName: "chevron.down")
                }
                self.attemptReload()
            }
            self.sortButton.setTitle(item, for: .normal)
            self.attemptReload()
            self.prevSort = item
        }
        
        // observeRefreshGuides()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Country"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func handleSortTable() {
        if sortButton.titleLabel!.text == "Start Date" && ascending {
            self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
                guide1.fromDate! < guide2.fromDate!
            })
        }
        else if sortButton.titleLabel!.text == "Start Date" && !ascending
        {
            self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
                guide1.fromDate! > guide2.fromDate!
            })
        }
        else if sortButton.titleLabel!.text == "End Date" && ascending
        {
           self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
               guide1.toDate! < guide2.toDate!
           })
        }
        else if sortButton.titleLabel!.text == "End Date" && !ascending
        {
          self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
              guide1.toDate! > guide2.toDate!
          })
        }
        else if sortButton.titleLabel!.text == "Country" && ascending
        {
          self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
              guide1.country! < guide2.country!
          })
        }
        else if sortButton.titleLabel!.text == "Country" && !ascending
        {
          self.guides.sort(by: {(guide1: Guide, guide2: Guide) -> Bool in
              guide1.country! > guide2.country!
          })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        observeRefreshGuides()
    }
    
    func observeRefreshGuides () {
        Database.database().reference().child("guides").observe(.childAdded) { (snapshot) in
            self.guideRole = false
            self.guides.removeAll()
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let guide = Guide(dictionary: dictionary)
                let guideID = guide.guideID!
                Database.database().reference().child("users").child(guideID)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String:AnyObject] {
                            guide.guideName = dictionary["name"]! as? String
                            if guide.guideID == Auth.auth().currentUser?.uid {
                                self.guideRole = true
                            } else {
                                self.guides.append(guide)
                            }
                            self.toggleRole(isGuide: self.guideRole)
                        }
                    }
                )
                self.attemptReload()
            }
        }
    }
    
    func toggleRole (isGuide: Bool) {
        if isGuide {
            createButton.setTitle("My Guide Profile", for: .normal)
            myBookingButton.setTitle("My Booking Offer", for: .normal)
        } else {
            createButton.setTitle("Join as Guide!", for: .normal)
            myBookingButton.setTitle("Booking Request", for: .normal)
        }
    }
    
    var timer:Timer?
    
    private func attemptReload() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        handleSortTable()
        guideTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredGuides.count
        } else {
            return guides.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! GuideCell
        var guide: Guide
        if isFiltering {
          guide = filteredGuides[indexPath.row]
        } else {
          guide = guides[indexPath.row]
        }
        if guide.guideID != Auth.auth().currentUser?.uid{
            cell.guide = guide
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let guide = guides[indexPath.row]
        self.showGuideDetails(guide: guide)
    }
    
    private func showGuideDetails(guide: Guide) {
        let GuideDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetail") as! GuideDetailViewController
        GuideDetailViewController.guide = guide
        self.navigationController?.pushViewController(GuideDetailViewController, animated: true)
    }
    
    @IBAction func handleSort(_ sender: Any) {
        dropDown.show()
    }
        
    @IBAction func handleOfferRequest(_ sender: Any) {
        print(guideRole)
        if guideRole {
            let guideBookOfferViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideOffer") as! GuideBookOfferViewController
            present(guideBookOfferViewController, animated: true, completion: nil)
        } else {
            let guideBookRequestViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideRequest") as! GuideBookRequestViewController
            present(guideBookRequestViewController, animated: true, completion: nil)
        }
    }

    func filterContentForSearchText(_ searchText: String) {
      filteredGuides = guides.filter { (guide: Guide) -> Bool in
        return guide.country!.lowercased().contains(searchText.lowercased())
      }
      guideTableView.reloadData()
    }
}

extension GuideMainViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}
