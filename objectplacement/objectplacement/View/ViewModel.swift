//
//  ViewModel.swift
//  objectplacement
//
//  Created by Piotr Suwara on 26/10/20.
//

import SceneKit
import Combine

class ViewModel {

    // MARK: Properties
    
    /// Revised view model with multiple objects
    private (set) var selectedObject: PlacedObject? = nil
    private var placedObjects = [PlacedObject]()
    let hasDetectedPlane: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    // MARK: Utility Functions
    
    func addObject(object: PlacedObject) {
        placedObjects.append(object)
    }
    
    /// Select the placed object specified and activate visual changes showing selection
    /// - Parameter object: The object to select
    func selectObject(object: PlacedObject) {
        guard let boundingSphere = object.node.geometry?.boundingSphere else { return }
        
        //object.node.geometry?.materials.forEach { $0.emission.contents = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1) }
        selectedObject = object
        
        let sphereNode = SCNNode(geometry: SCNSphere(radius: CGFloat(boundingSphere.radius)))
        let wireFrameMaterial = SCNMaterial()
        wireFrameMaterial.fillMode = .lines
        wireFrameMaterial.diffuse.contents = UIColor.white
        sphereNode.geometry?.firstMaterial = wireFrameMaterial
        sphereNode.position = boundingSphere.center
        
        selectedObject?.node.addChildNode(sphereNode)
    }
    
    /// Find the placedobject associated with the node. The node to search for can be in any part of the hierarchy where the PlacedObject is the parent
    /// - Parameter node: The node to look for, `nil` is acceptable.
    /// - Returns: A PlacedObject corresponding to the node
    func object(for node: SCNNode?) -> PlacedObject? {
        guard let node = node else { return nil }
        guard let foundObject: PlacedObject = placedObjects.first(where: { $0.node == node }) else {
            return object(for: node.parent)
        }
        
        return foundObject
    }
}
