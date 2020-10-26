//
//  SCNVector+Extensions.swift
//  objectplacement
//
//  Created by Piotr Suwara on 26/10/20.
//

import SceneKit

extension SCNVector3 {
    /// Utility initializer to setup a vector as scalar.
    /// - Parameter scalar: Single value to be used for x, y, z
    init(scalar: CGFloat) {
        self.init(scalar, scalar, scalar)
    }
}
