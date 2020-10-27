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
import Combine

class ViewController: UIViewController {
    
    // MARK: UI Connections
    var sceneView: ARSCNView = ARSCNView(frame: .zero)
    var canAddObjectLabel = UILabel(frame: .zero)
    
    // MARK: AR Properties
    let worldTrackingConfiguration = ARWorldTrackingConfiguration()
    
    // MARK: View Data
    let viewModel = ViewModel()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: View Lifecycle
    
    /// Custom view setup before appearing
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARScene()
        setupGestures()
        
        // Place canAddObjectLabel
        view.addSubview(canAddObjectLabel)
        canAddObjectLabel.topToSuperview(offset: 0, usingSafeArea: true)
        canAddObjectLabel.edgesToSuperview(excluding: [.top, .bottom])
        canAddObjectLabel.height(40)
        
        // Setup the view model binding
        viewModel.hasDetectedPlane
            .receive(on: DispatchQueue.main)
            .sink { [self] canPlace in
                if canPlace {
                    canAddObjectLabel.backgroundColor = .green
                    canAddObjectLabel.text = "PLANE DETECTED - PLACE OBJECT"
                } else {
                    // Add the plane detection label
                    canAddObjectLabel.textColor = .white
                    canAddObjectLabel.backgroundColor = .red
                    canAddObjectLabel.text = "NO PLANE DETECTED"
                }
            }
            .store(in: &cancellables)
    }
    
    /// View did appear override
    /// - Parameter animated: Animated appearance
    override func viewDidAppear(_ animated: Bool) {
        /// Run a session with reset tracking everytime the view appears
        sceneView.session.run(worldTrackingConfiguration, options: [.resetTracking])
        viewModel.hasDetectedPlane.send(false)
    }
    
    /// Configure the ARKit Scene used for detecting planes and objects
    private func setupARScene() {
        /// Just use tiny constraints here to add the subview instead of having to add IB contraints
        self.view.addSubview(sceneView)
        sceneView.edgesToSuperview()
        
        /// Setup the AR Scene delegate and plane detection
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        //sceneView.showsStatistics = true
        //sceneView.debugOptions = [.showBoundingBoxes, .showFeaturePoints]
        
        worldTrackingConfiguration.planeDetection = .horizontal
        worldTrackingConfiguration.environmentTexturing = .automatic
        
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
        let doubleTapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(doubleTapResponse))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)
        
        /// Single tap gesture to move or select object
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tapResponse))
        tapGesture.numberOfTapsRequired = 1
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
    
    /// Handle the response when the user double taps on the screen
    /// - Parameter sender: The TapGestureRecognizer
    @objc func doubleTapResponse(sender: UITapGestureRecognizer) {
        guard viewModel.hasDetectedPlane.value,
              let scene = sender.view as? ARSCNView else { return }
        
        /// Let's grab a ray cast result of the tap on to our ar scene
        let tapAtLocation = sender.location(in: scene)
        guard let rayCastQuery = scene.raycastQuery(from: tapAtLocation, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
        
        guard let rayCastResult = scene.session.raycast(rayCastQuery).first else { return }
        addObject(at: rayCastResult)
    }
    
    /// Handle the response when the user taps on the screen
    /// - Parameter sender: The TapGestureRecognizer
    @objc func tapResponse(sender: UITapGestureRecognizer) {
        guard let arScene = sender.view as? ARSCNView else { return }
        
        /// Let's grab a ray cast result of the tap on to our ar scene
        let tapAtLocation = sender.location(in: arScene)
        
        /// Check if we tapped on an existing object, if so select it, otherwise, cast a ray to the world
        if let placedObject = placedObject(at: tapAtLocation) {
            viewModel.selectObject(object: placedObject)
            return
        }
        
        guard let worldRayCastQuery = arScene.raycastQuery(from: tapAtLocation,
                                                      allowing: .existingPlaneInfinite,
                                                      alignment: .horizontal) else { return }
        guard let worldRayCastResult = arScene.session.raycast(worldRayCastQuery).first else { return }
        
        moveObject(to: worldRayCastResult)
    }
    
    /// Handle the response when the user pinches the screen
    /// - Parameter sender: The PinchGestureRecognizer used in the pinch
    @objc func pinchResponse(sender: UIPinchGestureRecognizer) {
        guard let _ = sender.view as? ARSCNView,
              let selectedObject = viewModel.selectedObject else { return }
        
        selectedObject.node.scale = SCNVector3(scalar: sender.scale * selectedObject.scalar)
        
        /// When we finish pinching, the scalar value should be transformed into the new starting scalar value
        if sender.state == .ended {
            selectedObject.scalar *= sender.scale
        }
    }
    
    /// Handle the pan swiping event for rotation
    /// - Parameter sender: The PanGestureRecognizer
    @objc func panResponse(sender: UIPanGestureRecognizer) {
        guard let _ = sender.view as? ARSCNView,
              let selectedObject = viewModel.selectedObject else { return }
        
        let point = sender.translation(in: sceneView)
        
        /// Do a basic rotation around the Y axis
        let rotationAmount = (point.x * 3.147/180) + selectedObject.rotation
        selectedObject.node.rotation = SCNVector4(0, 1, 0, rotationAmount)
        
        if sender.state == .ended {
            selectedObject.rotation = rotationAmount
        }
    }
}

