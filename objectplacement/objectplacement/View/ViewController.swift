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
    
    // MARK: Model
    var placedObject: SCNNode? = nil
    
    /// Custom view setup before appearing
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARScene()
        setupGestures()
    }
    
    private func setupARScene() {
        /// Just use tiny constraints here to add the subview instead of having to add IB contraints
        self.view.addSubview(sceneView)
        sceneView.edgesToSuperview()
        
        /// Setup the AR Scene delegate and plane detection
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showBoundingBoxes, .showFeaturePoints]
        
        worldTrackingConfiguration.planeDetection = .horizontal
        
        sceneView.session.run(worldTrackingConfiguration)
        
        /// Add a simple global light node
        let globalLight: SCNNode = SCNNode()
        globalLight.light = SCNLight()
        globalLight.light?.color = UIColor(white: 0.8, alpha: 1.0)
        globalLight.light?.temperature = 3000.0 // 3000k is a nice warm mlight
        globalLight.light?.type = .omni
        globalLight.position = SCNVector3(0.0, 10.0, 0.0)
        sceneView.scene.rootNode.addChildNode(globalLight)
    }
    
    /// Initialize the gestures used within the application
    private func setupGestures() {
        /// Double tap gesture to place a new object
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(addObjectTapResponse))
        tapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(tapGesture)
        
        /// Pinch gesture to scale
    }
    
    /// Handle the response when the user taps on the screen
    /// - Parameter sender: The TapGestureRecognizer
    @objc func addObjectTapResponse(sender: UITapGestureRecognizer) {
        guard let scene = sender.view as? ARSCNView else { return }
        
        /// Let's grab a ray cast result of the tap on to our ar scene
        let tapAtLocation = sender.location(in: scene)
        guard let rayCastQuery = scene.raycastQuery(from: tapAtLocation, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
        
        guard let rayCastResult = scene.session.raycast(rayCastQuery).first else { return }
        addObject(at: rayCastResult)
    }
    
    // MARK: Private AR Utilities
    
    /// Add the object at a ray intersection
    /// - Parameter result: ARRaycastResult that contains the transform of the intersection.
    private func addObject(at result: ARRaycastResult) {
        let position = result.worldTransform.position()
        
        guard let url = Bundle.main.url(forResource: "gramophone",
                                        withExtension: "usdz"),
              let referenceNode = SCNReferenceNode(url: url) else {
            return
        }
        
        referenceNode.load()
        referenceNode.position = position
        sceneView.scene.rootNode.addChildNode(referenceNode)
        
        placedObject = referenceNode
    }
    
    private func scaleObject(_ scale: CGFloat) {
        guard let placedObject = placedObject else { return }
        placedObject.scale = SCNVector3(
    }
}

