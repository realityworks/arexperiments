//
//  ViewController+ObjectInteraction.swift
//  objectplacement
//
//  Created by Piotr Suwara on 27/10/20.
//

import SceneKit
import ARKit

extension ViewController {
    
    /// Add the object at a ray intersection
    /// - Parameter result: ARRaycastResult that contains the transform of the intersection.
    func addObject(at result: ARRaycastResult) {
        let position = result.worldTransform.position()
        
        // Pull out the gramaphone usdz file
        guard let url = Bundle.main.url(forResource: "gramophone",
                                        withExtension: "usdz"),
              let referenceNode = SCNReferenceNode(url: url) else {
            return
        }
        
        referenceNode.load()
        referenceNode.position = position
        
        sceneView.scene.rootNode.addChildNode(referenceNode)
        
        // Setup the placed object from the node
        let placedObject = PlacedObject(node: referenceNode)
        referenceNode.scale = SCNVector3(scalar: placedObject.scalar)
        
        // Add our new object
        viewModel.addObject(object: placedObject)
    }
    
    /// Move the object to a location
    /// - Parameter result: A raycast result that contains the world transform of the raycast intersection with world position
    func moveObject(to result: ARRaycastResult) {
        guard let selectedObject = viewModel.selectedObject else { return }
        
        let position = result.worldTransform.position()
        selectedObject.node.position = position
    }
    
    func placedObject(at point: CGPoint) -> PlacedObject? {
        /// This is deprecated, but raycasts don't seem to return anchors for nodes? How should this work.
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = sceneView.hitTest(point, options: hitTestOptions)
        
        return hitTestResults
            .compactMap { self.viewModel.object(for: $0.node) }
            .first
    }
}
