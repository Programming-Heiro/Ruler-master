//
//  ARMeasureRulerViewController+FocusSquare.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//
import Foundation
import ARKit

// MARK: - FocusSquare
//fileprivate extension ARMeasureRulerViewController {
extension ARMeasureRulerViewController {
    
    //    // MARK: - Focus Square
    //
    //    func setupFocusSquare() {
    //        focusSquare.unhide()
    //        focusSquare.removeFromParentNode()
    //        sceneView.scene.rootNode.addChildNode(focusSquare)
    //    }
    //
    //    func updateFocusSquare() {
    //        let (worldPosition, planeAnchor, _) = worldPositionFromScreenPosition(view.center, objectPos: focusSquare.position)
    //        if let worldPosition = worldPosition {
    //            focusSquare.update(for: worldPosition, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
    //        }
    //    }
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
    }
    
    func updateFocusSquare() {
        if ApplicationSetting.Status.displayFocus {
            focusSquare?.unhide()
        } else {
            focusSquare?.hide()
        }
        let (worldPos, planeAnchor, _) = sceneView.worldPositionFromScreenPosition(sceneView.bounds.mid, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
            //self.focusSquare?.state = .initializing
            //self.focusSquare？.state = .detecting(hitTestResult: result, camera: camera)
        }
    }
}
