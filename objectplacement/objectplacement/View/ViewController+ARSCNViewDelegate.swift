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
    /// Callback when a node has been added
    /// - Parameters:
    ///   - renderer: Renderer used by the scene
    ///   - node: Node that  has been added
    ///   - anchor: Attached anchor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // We want to know if we have a new plane anchor detected upon which we can start
        // Casting rays
        guard anchor is ARPlaneAnchor else { return }
        
        viewModel.canPlaceObject.send(true)
    }
}
