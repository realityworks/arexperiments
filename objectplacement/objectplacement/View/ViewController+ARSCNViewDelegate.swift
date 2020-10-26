//
//  ViewController+ARSCNViewDelegate.swift
//  objectplacement
//
//  Created by Piotr Suwara on 26/10/20.
//

import UIKit
import SceneKit
import ARKit

extension ViewController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        viewModel.canPlaceObject.send(true)
    }
}
