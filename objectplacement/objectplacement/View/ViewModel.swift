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
}
