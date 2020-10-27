//
//  PlacedObject.swift
//  objectplacement
//
//  Created by Piotr Suwara on 27/10/20.
//

import SceneKit

/// Class to contain an object in the world with a relative scalar and rotation value
class PlacedObject {
    let node: SCNNode
    var scalar: CGFloat = 0.001
    var rotation: CGFloat = 0.0
    
    /// Default initializer that accepts node in the scene
    /// - Parameter node: Scene node, expected to the a 3D object
    init(node: SCNNode) {
        self.node = node
    }
}
