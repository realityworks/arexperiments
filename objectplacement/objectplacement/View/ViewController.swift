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
    
    // MARK: View Data
    var placedObject: SCNNode? = nil
    var placedObjectScalar: CGFloat = 0.001
    var placedObjectRotate: CGFloat = 0.0
    
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
                                                action: #selector(tapResponse))
        tapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(tapGesture)
        
        /// Pinch gesture to scale
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(pinchResponse))
        sceneView.addGestureRecognizer(pinchGesture)
        
        /// Pan gesture to catch for rotation
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(panResponse))
        panGesture.minimumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
    }
    
    // MARK: Gesture Recognizers
    
    /// Handle the response when the user taps on the screen
    /// - Parameter sender: The TapGestureRecognizer
    @objc func tapResponse(sender: UITapGestureRecognizer) {
        guard let scene = sender.view as? ARSCNView else { return }
        
        /// Let's grab a ray cast result of the tap on to our ar scene
        let tapAtLocation = sender.location(in: scene)
        guard let rayCastQuery = scene.raycastQuery(from: tapAtLocation, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
        
        guard let rayCastResult = scene.session.raycast(rayCastQuery).first else { return }
        addObject(at: rayCastResult)
    }
    
    /// Handle the response when the user pinches the screen
    /// - Parameter sender: The PinchGestureRecognizer used in the pinch
    @objc func pinchResponse(sender: UIPinchGestureRecognizer) {
        guard let _ = sender.view as? ARSCNView,
              let placedObject = placedObject else { return }
        
        placedObject.scale = SCNVector3(scalar: sender.scale * placedObjectScalar)
        
        /// When we finish pinching, the scalar value should be transformed into the new starting scalar value
        if sender.state == .ended {
            placedObjectScalar = sender.scale * placedObjectScalar
        }
    }
    
    @objc func panResponse(sender: UIPanGestureRecognizer) {
        guard let _ = sender.view as? ARSCNView,
              let placedObject = placedObject else { return }
        
        let point = sender.translation(in: sceneView)
        
        /// Do a basic rotation around the Y axis
        let rotationAmount = (point.x * 3.147/180) + placedObjectRotate
        placedObject.rotation = SCNVector4(0, 1, 0, rotationAmount)
        
        if sender.state == .ended {
            placedObjectRotate = rotationAmount
        }
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
        
        // Setup the default scalar on placement
        referenceNode.scale = SCNVector3(scalar: placedObjectScalar)
        
        sceneView.scene.rootNode.addChildNode(referenceNode)
        
        placedObject = referenceNode
    }
}

