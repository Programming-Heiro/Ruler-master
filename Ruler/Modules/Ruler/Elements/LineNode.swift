//
//  LineNode.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//


import UIKit
import SceneKit
import ARKit

import SpriteKit

class LineNode: NSObject {
    
    let startNode: SCNNode
    let endNode: SCNNode
    var lineNode: SCNNode?
    let textNode: SCNNode
    //let textNode：Sprite
    
    
    let sceneView: ARSCNView?
    private var recentFocusSquarePositions = [SCNVector3]()

    init(startPos: SCNVector3,
         sceneV: ARSCNView,
         color: (start: UIColor, end: UIColor) = (UIColor.green, UIColor.red),
         //font: UIFont = UIFont.boldSystemFont(ofSize: 10) ) {
        font: UIFont = UIFont.init(name: "Menlo", size: 6)!) {
        
        sceneView = sceneV
        
        let scale = 1/500.0
        let scaleVector = SCNVector3(scale, scale, scale)
        
        
        // 设置每个标记圆球外观的属性
        func buildSCNSphere(color: UIColor) -> SCNSphere {
            let dot = SCNSphere(radius:1)
            dot.firstMaterial?.diffuse.contents = color
            dot.firstMaterial?.lightingModel = .constant
            dot.firstMaterial?.isDoubleSided = true
            return dot
        }
   
        // 设置每个圆球位置和大小属性
        startNode = SCNNode(geometry: buildSCNSphere(color: color.start))
        startNode.scale = scaleVector
        
        startNode.position = startPos
        sceneView?.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: buildSCNSphere(color: color.end))
        endNode.scale = scaleVector
        
        lineNode = nil
        
        // 初始化字体
        let text = SCNText (string: "--", extrusionDepth: 0.00)
        text.font = font
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.alignmentMode  = kCAAlignmentCenter//居中对齐
        text.truncationMode = kCATruncationMiddle//居中截取（对于过长的text的处理）
        text.firstMaterial?.isDoubleSided = true
        text.flatness = 0.1
        //text.
        textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        //textNode.eulerAngles.x = Float(CGFloat.pi / 2)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 析构方法
    deinit {
        removeFromParent()
    }
    //
    public func updatePosition(pos: SCNVector3, camera: ARCamera?, unit: MeasurementUnit.Unit = MeasurementUnit.Unit.centimeter) -> Float {
        
        let posEnd = updateTransform(for: pos, camera: camera)
        
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
        endNode.position = posEnd
        
        let posStart = startNode.position
        let middle = SCNVector3((posStart.x+posEnd.x)/2.0, (posStart.y+posEnd.y)/2.0+0.002, (posStart.z+posEnd.z)/2.0)
        
        let text = textNode.geometry as! SCNText
        let length = posEnd.distanceFromPos(pos: startNode.position)
        text.string = MeasurementUnit(meterUnitValue: length).string(type: unit)
        textNode.setPivot()
        textNode.position = middle
        
        //textNode.localRotate(by: SCNQuaternion(x: 0, y: 0, z: 0.7071, w: 0.7071))
        
        if textNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(textNode)
        }
        
        lineNode?.removeFromParentNode()
        lineNode = lineBetweenNodeA(nodeA: startNode, nodeB: endNode)
        sceneView?.scene.rootNode.addChildNode(lineNode!)
        
        return length
    }
    
    func removeFromParent() -> Void {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        textNode.removeFromParentNode()
    }
    
    // MARK: - Private
    // 连接每个start 和 end
    private func lineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> SCNNode {
        
        return CylinderLine(parent: sceneView!.scene.rootNode,
                            v1: nodeA.position,
                            v2: nodeB.position,
                            radius: 0.001,
                            radSegmentCount: 16,
                            color: UIColor.blue)
        
    }
    
    
    private func updateTransform(for position: SCNVector3, camera: ARCamera?) -> SCNVector3 {
        recentFocusSquarePositions.append(position)
        recentFocusSquarePositions.keepLast(8)
        if let camera = camera {
            let tilt = abs(camera.eulerAngles.x)
            let threshold1: Float = Float.pi / 2 * 0.65
            let threshold2: Float = Float.pi / 2 * 0.75
            let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
            var angle: Float = 0
            
            switch tilt {
            case 0..<threshold1:
                angle = camera.eulerAngles.y
            case threshold1..<threshold2:
                let relativeInRange = abs((tilt - threshold1) / (threshold2 - threshold1))
                let normalizedY = normalize(camera.eulerAngles.y, forMinimalRotationTo: yaw)
                angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange
            default:
                angle = yaw
            }
            //textNode.runAction(SCNAction.rotateTo(x: 0, y: CGFloat(angle), z: 0, duration: 0))
            //旋转
            textNode.runAction(SCNAction.rotateTo(x: CGFloat(M_PI*1.5), y: CGFloat(angle), z: 0, duration: 0))
            textNode.runAction(SCNAction.move(by:SCNVector3(x:0, y:0.001, z: 0), duration: 0))
            
        }
        
        if let average = recentFocusSquarePositions.average {
            return average
        }
        
        return SCNVector3Zero
    }
    
    // 旋转角度正常化
    private func normalize(_ angle: Float, forMinimalRotationTo ref: Float) -> Float {

        var normalized = angle
        while abs(normalized - ref) > Float.pi / 4 {
            if angle > ref {
                normalized -= Float.pi / 2
            } else {
                normalized += Float.pi / 2
            }
        }
        return normalized
    }
}

