//
//  ViewController.swift
//  librariestesting
//
//  Created by tyr on 6/2/20.
//  Copyright © 2020 tyr. All rights reserved.
//

import SpriteKit
import Magnetic

class ViewController: UIViewController, MagneticDelegate {
    
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
        
        for _ in 0..<12 {
            addNodes()
        }
    }
    
    
    func addNodes() {
        let name = UIImage.names.randomItem()
        let color = UIColor.colors.randomItem()
        let node = Node(text: name.capitalized, image: UIImage(named: name), color: color, radius: 40)
        magnetic.addChild(node)
    }
    
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
        addNodes()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        for i in nodeList {
            print(i)
        }
    }
    
}
