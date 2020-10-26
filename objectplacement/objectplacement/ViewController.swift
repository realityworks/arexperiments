//
//  ViewController.swift
//  objectplacement
//
//  Created by Piotr Suwara on 26/10/20.
//

import UIKit
import SceneKit
import ARKit
import TinyConstraints

class ViewController: UIViewController {
    
    // MARK: UI Connections
    var sceneView: ARSCNView = ARSCNView(frame: .zero)
    
    // MARK: AR Properties
    let worldTrackingConfiguration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Just use tiny constraints here to add the subview instead of having to add IB contraints
        self.view.addSubview(sceneView)
        sceneView.edgesToSuperview()
    }
}

