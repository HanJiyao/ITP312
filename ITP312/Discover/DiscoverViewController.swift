//
//  ViewController.swift
//  librariestesting
//
//  Created by tyr on 6/2/20.
//  Copyright © 2020 tyr. All rights reserved.
//

import SpriteKit
import Magnetic
import Firebase

class DiscoverViewController: UIViewController, MagneticDelegate {
    
    @IBOutlet weak var discoverLabel: UILabel!
    
    var allNodes: [Node] = []
    
    var nodeList: Magnetic { return magneticView.magnetic }
        
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        setLabel(originalText: false)
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        nodeList.selectedChildren.count == 0 ? setLabel(originalText: true) : setLabel(originalText: false)
    }
    
    func setLabel(originalText: Bool) {
        discoverLabel.text = originalText ? "Discover new countries" : "Discover \(nodeList.selectedChildren.count) new countries"
    }
    
    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            nodeList.magneticDelegate = self
        }
    }
    
    /* second method to load magnetic programmatically instead of storyboard iboutlet delegate
    var magnetic: Magnetic?
    override func loadView() {
          super.loadView()
          let magneticView = MagneticView(frame: self.view.bounds)
          magnetic = magneticView.magnetic
          self.view.addSubview(magneticView)
      }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Discover"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setLabel(originalText: true)
        resetNodes()
    }
    
    func resetNodes() {
        allNodes.forEach{$0.removeFromParent()} //Node removeFromParent will remove it properly from screen, SKNode future node will not move to center after removing
        self.initialiseNodes()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {}
    }
    
    func initialiseNodes() {
        var resultSet = Set<String>() //prevent duplicate of name
        while resultSet.count < 13 {
            let name = UIImage.names.randomFromArray()
            resultSet.insert(name)
        }
        for name in Array(resultSet) {
            addNodesToListAndArray(nameParameter: name)
        }
    }
    
    func addNodesToListAndArray(nameParameter: String) {
        let name = nameParameter == "random" ? UIImage.names.randomFromArray() : nameParameter
        let color = UIColor.colors.randomFromArray()
        let imageName = UIImage.names.randomFromArray()
        let node = Node(text: name.capitalized, image: UIImage(named: imageName), color: color, radius: 40, marginScale: 1.05) //marginScale = spacing between bubbles default 1.01
        allNodes.append(node) //needed so that later can use removeFromParent instead of using nodeList.children which is [SKNode]
        nodeList.addChild(node)
    }
    
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
        let alert = UIAlertController(style: .alert, title: "Select method", message: "2 kinds of adding")
        alert.addAction(title: "Add random", style: .default) { _ in
            self.addNodesToListAndArray(nameParameter: "random")
        }
        alert.addAction(title: "Add country", style: .default) { _ in
            let alert = UIAlertController(style: .actionSheet, title: "Select Country")
            alert.addLocalePicker(type: .country) { info in
                self.addNodesToListAndArray(nameParameter: info!.country)
            }
            alert.addAction(title: "Cancel", style: .cancel)
            alert.show()
        }
        alert.show()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        var selectedNodes: [String] = []
        nodeList.selectedChildren.forEach { selectedNodes.append($0.text!) }
        let viewController = DataManager.viewControllerFromStoryboard(name: "DiscoverStoryboard", identifier: "SwipePhoto") as! SwipePhotoViewController
        viewController.countrySelectedList = selectedNodes
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}


extension Magnetic {
    func restartAnimation() {
        for (index, node) in children.enumerated() {
            let x = (index % 2 == 0) ? -node.frame.width : frame.width + node.frame.width
            let y = random(node.frame.height, (frame.height - node.frame.height))
            node.position = CGPoint(x: x, y: y)
//            node.position = CGPoint(x: node.frame.midX, y: node.frame.midY)
        }
    }
    
    func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}
