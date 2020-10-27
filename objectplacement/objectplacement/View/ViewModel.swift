//
//  ViewModel.swift
//  objectplacement
//
//  Created by Piotr Suwara on 26/10/20.
//

import SceneKit
import Combine

class ViewModel {
    var canPlaceObject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var placedObject: SCNNode? = nil
    var placedObjectScalar: CGFloat = 0.001
    var placedObjectRotate: CGFloat = 0.0
    
    // MARK: Properties
    
    /// Revised view model with multiple objects
    private (set) var selectedObject: PlacedObject? = nil
    private var placedObjects = [PlacedObject]()
    let hasDetectedPlane: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    // MARK: Utility Functions
    
    func addObject(object: PlacedObject) {
        placedObjects.append(object)
    }
    
    func selectObjectWith(node: SCNNode) {
        /// Sanity test to make sure object exists
        guard let newSelectedObject = placedObjectForNode(node: node) else { return }
        
        #warning("TODO : Add material when the object is selected")
        //let material = SCNMaterialProperty()
        //newSelectedObject.node.geometry?.firstMaterial?.diffuse =
    }
    
    func object(for node: SCNNode) -> PlacedObject? {
        return placedObjects.first { object -> Bool in
            object.node == node
        }
    }
}
