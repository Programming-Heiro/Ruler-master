//
//  CylinderLine.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import SceneKit
// 用圆柱体构建线
class CylinderLine: SCNNode {
    init( parent: SCNNode, v1: SCNVector3, v2: SCNVector3, radius: CGFloat, radSegmentCount: Int, color: UIColor)
    {
        super.init()
        //高度为两点之间的距离
        let  height = v1.distance(receiver: v2)
        //自身的根节点当做第一个节点
        self.position = v1
        
        
        let nodeV2 = SCNNode()
        nodeV2.position = v2
        // 创建第二个节点，接入到parent父母节点中，父母节点是整个LineNode类（包含了点和线），而不是接入本身的CylinderLine类的节点
        // parent代表上一个节点
        parent.addChildNode(nodeV2)
        
        // 该节点用于结合设置好的圆柱结点
        let zAlign = SCNNode()
        // 欧拉角 eulerAngle  pi/2 = 90°  目的是为了让圆柱体的相对于两个点正好水平连接两个点
        zAlign.eulerAngles.x = Float(CGFloat.pi / 2)
        // 代表圆柱线的节点
        
        //先设置圆柱属性
        // radius 半径  height 高度
        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        // 圆柱的圆形分隔数，默认48 最小3
        cyl.radialSegmentCount = radSegmentCount
        cyl.firstMaterial?.diffuse.contents = color
        
        // 设置圆柱结点绑定形状及其设定其中间位置（）
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        zAlign.addChildNode(nodeCyl)
        
        self.addChildNode(zAlign)
        
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
// MARK: - 求距离,结果作为圆柱体的长度
private extension SCNVector3{
    func distance(receiver:SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}
