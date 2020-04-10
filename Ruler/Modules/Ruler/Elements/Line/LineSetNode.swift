//
//  LineSetNode.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class LineSetNode: NSObject {
    
    private(set) var lines = [LineNode]()
    var currentNode: LineNode
    var closeNode: LineNode?
    let sceneView: ARSCNView
    let textNode: SCNNode

    
    
    init(startPos: SCNVector3, sceneV: ARSCNView) {
        sceneView = sceneV
        let line = LineNode(startPos: startPos,
                            sceneV: sceneV,
                            color: (UIColor.blue, UIColor.blue),
                            font: UIFont.systemFont(ofSize: 6))
        currentNode = line
        lines.append(line)
        
        let text = SCNText (string: "--", extrusionDepth: 0.1)
        text.font = UIFont.boldSystemFont(ofSize: 6)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.alignmentMode  = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        text.firstMaterial?.isDoubleSided = true
        textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        textNode.isHidden = true
        //textNode.eulerAngles.x = Float(CGFloat.pi / 2)
        
        super.init()
    }
    
    
    func addLine() {
        currentNode = LineNode(startPos: currentNode.endNode.position,
                               sceneV: sceneView,
                               color: (UIColor.blue, UIColor.blue),
                               font: UIFont.systemFont(ofSize: 6))
        lines.append(currentNode)
        resetCloseLine()
    }
    
    // 用队列存储线
    func removeLine() -> Bool {
        guard let n = lines.popLast(), lines.count >= 1 else {
            resetCloseLine()
            return false
        }
        n.removeFromParent()
        currentNode = lines.last!
        resetCloseLine()
        return true
    }
    
    
    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    ///
    /// The two loops in the following example produce the same output:
    ///
    ///     let numberWords = ["one", "two", "three"]
    ///     for word in numberWords {
    ///         print(word)
    ///     }
    ///     // Prints "one"
    ///     // Prints "two"
    ///     // Prints "three"
    ///
    ///     numberWords.forEach { word in
    ///         print(word)
    ///     }
    ///     // Same as above
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a
    ///   parameter.
    // $0: 闭包中的第一个参数
    func removeFromParent() {
        lines.forEach({ $0.removeFromParent() })
        textNode.removeFromParentNode()
    }
    
    // 移除封闭直线，遍历删除
    private func resetCloseLine() {
        closeNode?.removeFromParent()
        closeNode = nil
        if lines.count > 1 {
            let closeNodeTemp = LineNode(startPos: lines[0].startNode.position,
                                         sceneV: sceneView,
                                         color: (UIColor.blue, UIColor.blue),
                                         font: UIFont.systemFont(ofSize: 6))
            closeNode = closeNodeTemp
        }
    }
    
    public func updatePosition(pos: SCNVector3, camera: ARCamera?, unit: MeasurementUnit.Unit = MeasurementUnit.Unit.centimeter) -> Float {
        _ = closeNode?.updatePosition(pos: pos, camera: camera, unit: unit)
        _ = currentNode.updatePosition(pos: pos, camera: camera, unit: unit)
        //大于两个点的情况才能有线进而才能有字
        guard lines.count >= 2 else {
            textNode.isHidden = true
            return 0
        }
        var points = lines.map({ $0.endNode.position })
        points.append(lines[0].startNode.position)
        
        var center = points.average ?? points[0]
        center.y += 0.002
        let text = textNode.geometry as! SCNText
        let area = computePolygonArea(points: points)
        text.string = MeasurementUnit(meterUnitValue: area, isArea: true).string(type: unit)
        textNode.setPivot()
        textNode.position = center
        //textNode.position = SCNVector3(x: center.x, y: center.y+1, z: center.z)
        textNode.runAction(SCNAction.rotateTo(x: CGFloat(M_PI*1.5), y: 0, z: 0, duration: 0))
        textNode.isHidden = false
        if textNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(textNode)
        }
        return area
    }
    // 计算多边形面积
    private func computePolygonArea(points: [SCNVector3]) -> Float {
        return abs(area3DPolygonFormPointCloud(points: points))
    }

    
}





