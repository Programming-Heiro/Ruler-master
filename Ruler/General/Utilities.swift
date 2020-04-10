//
//  Utilities.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

/// 根据点云拟合平面
/// - Parameters:
///   - featureCloud： 点云
/// - Returns: 平面法向量及平面上一点
func planeDetectWithFeatureCloud(featureCloud: [SCNVector3]) -> (detectPlane: SCNVector3, planePoint: SCNVector3) {
    let warpFeatures = featureCloud.map({ (feature) -> NSValue in
        return NSValue(scnVector3: feature)
    })
    let result = PlaneDetector.detectPlane(withPoints: warpFeatures)
    var planePoint = SCNVector3Zero
    if result.x != 0 {
        planePoint = SCNVector3(result.w/result.x,0,0)
    }else if result.y != 0 {
        planePoint = SCNVector3(0,result.w/result.y,0)
    }else {
        planePoint = SCNVector3(0,0,result.w/result.z)
    }
    let detectPlane = SCNVector3(result.x, result.y, result.z)
    return (detectPlane, planePoint)
}

/// 根据直线上的点和向量及平面上的点和法向量计算交点
/// - Parameters:
///   - planeVector: 平面法向量
///   - planePoint: 平面上一点
///   - lineVector: 直线向量
///   - linePoint: 直线上一点
/// - Returns: 交点
func planeLineIntersectPoint(planeVector: SCNVector3 , planePoint: SCNVector3, lineVector: SCNVector3, linePoint: SCNVector3) -> SCNVector3? {
    let vpt = planeVector.x * lineVector.x + planeVector.y * lineVector.y + planeVector.z * lineVector.z
    if vpt != 0 {
        let t = ((planePoint.x-linePoint.x)*planeVector.x + (planePoint.y-linePoint.y)*planeVector.y + (planePoint.z-linePoint.z)*planeVector.z)/vpt
        let cross = SCNVector3Make(linePoint.x + lineVector.x*t, linePoint.y + lineVector.y*t, linePoint.z + lineVector.z*t)
        if (cross-linePoint).length() < 5 {
            return cross
        }
    }
    return nil
}


// 点云拟合多边形求面积
/// - Parameters:
///   - points: 顶点坐标
/// - Returns: 面积
func area3DPolygonFormPointCloud(points: [SCNVector3]) -> Float32 {
    let (detectPlane, planePoint) = planeDetectWithFeatureCloud(featureCloud: points)
    var newPoints = [SCNVector3]()
    for p in points {
        guard let ip = planeLineIntersectPoint(planeVector: detectPlane, planePoint: planePoint, lineVector: detectPlane, linePoint: p) else {
            return 0
        }
        newPoints.append(ip)
    }
    return area3DPolygon(points: newPoints, plane: detectPlane)
}

// 空间多边形面积
/// - Parameters:
///   - points: 顶点坐标
///   - plane: 多边形所在平面法向量
/// - Returns: 面积
func area3DPolygon(points: [SCNVector3], plane: SCNVector3 ) -> Float32 {
    let n = points.count
    guard n >= 3 else { return 0 }
    var V = points
    V.append(points[0])
    V.append(points[1])
    let N = plane
    var area = Float(0)
    var (an, ax, ay, az) = (Float(0), Float(0), Float(0), Float(0))
    var coord = 0   // 1=x, 2=y, 3=z
    var (i, j, k) = (0, 0, 0)
    
    ax = (N.x>0 ? N.x : -N.x)
    ay = (N.y>0 ? N.y : -N.y)
    az = (N.z>0 ? N.z : -N.z)
    
    coord = 3;
    if (ax > ay) {
        if (ax > az) {
            coord = 1
        }
    } else if (ay > az) {
        coord = 2
    }
    
    (i, j, k) = (1, 2, 0)
    while i<=n {
        switch (coord) {
        case 1:
            area += (V[i].y * (V[j].z - V[k].z))
        case 2:
            area += (V[i].x * (V[j].z - V[k].z))
        case 3:
            area += (V[i].x * (V[j].y - V[k].y))
        default:
            break
        }
        i += 1
        j += 1
        k += 1
    }

    an = sqrt( ax*ax + ay*ay + az*az)
    switch (coord) {
    case 1:
        area *= (an / (2*ax))
    case 2:
        area *= (an / (2*ay))
    case 3:
        area *= (an / (2*az))
    default:
        break
    }
    return area
}



// MARK: - float4x4 extensions

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

//extension CGPoint {
//    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
//    init(_ vector: SCNVector3) {
//        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
//    }
//    
//    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
//    var length: CGFloat {
//        return sqrt(x * x + y * y)
//    }
//}
