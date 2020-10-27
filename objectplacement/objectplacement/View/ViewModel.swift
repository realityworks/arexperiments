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
    func select(object: PlacedObject) {
        let curSelectedObject = selectedObject
        deselect()
        
        // Don't select the same object twice
        guard object.node != curSelectedObject?.node else { return }
        
        selectedObject = object
        selectedObject?.node.opacity = 0.7
    }
    
    func deselect() {
        guard let selectedObject = selectedObject else { return }
        selectedObject.node.opacity = 1
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
