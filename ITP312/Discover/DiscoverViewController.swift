//
//  ViewController.swift
//  librariestesting
//
//  Created by tyr on 6/2/20.
//  Copyright © 2020 tyr. All rights reserved.
//

import SpriteKit
import Magnetic

class DiscoverViewController: UIViewController, MagneticDelegate {
    
    var nodeList: [String] = []
    
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        print("didSelect -> \(node)")
        print(node.text)
        nodeList.append(node.text!)

    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        print("didDeselect -> \(node)")
    }
    
    
//    var magneticDelegate: MagneticDelegate? // magnetic delegate

    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            magnetic.magneticDelegate = self
        }
    }
    
        var magnetic: Magnetic {
            return magneticView.magnetic
        }
    
//    var magnetic: Magnetic?
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Discover"
        for _ in 0..<12 {
            addNodes()
        }
    }
    
    
    func addNodes() {
        let name = UIImage.names.randomItemHey()
        let color = UIColor.colors.randomItemHey()
        let node = Node(text: name.capitalized, image: UIImage(named: name), color: color, radius: 40)
        magnetic.addChild(node)
    }
    
    func addNodesCountry(countryName: String) {
        let color = UIColor.colors.randomItemHey()
        let name = UIImage.names.randomItemHey()
        let node = Node(text: countryName, image: UIImage(named: name), color: color, radius: 40)
        magnetic.addChild(node)
    }
    
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
//        addNodes()
        let alert = UIAlertController(style: .alert, title: "Select method", message: "2 kinds of adding")
        alert.addAction(title: "Add random", style: .default) { _ in
            self.addNodes()
        }
        alert.addAction(title: "Add country", style: .default) { _ in
            print("addd country")
            let alert = UIAlertController(style: .actionSheet, title: "Select Country")
            alert.addLocalePicker(type: .country) { info in
                print("selected info", info)
                self.addNodesCountry(countryName: info!.country)
            }
            alert.addAction(title: "Cancel", style: .cancel)
            alert.show()
        }
        alert.show()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        for i in nodeList {
            print(i)
        }
    }
    
}
