//
//  Simd+Extensions.swift
//  objectplacement
//
//  Created by Piotr Suwara on 26/10/20.
//

import SceneKit

extension simd_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}

