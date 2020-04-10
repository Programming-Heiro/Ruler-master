//
//  ARMeasureRulerViewController+ARSCNViewDelegate.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import Foundation
import ARKit


// MARK: - ARSCNViewDelegate
extension ARMeasureRulerViewController: ARSCNViewDelegate {
    
    //    func session(_ session: ARSession, didFailWithError error: Error) {
    //        DispatchQueue.main.async {
    //            HUG.show(title: (error as NSError).localizedDescription)
    //        }
    //    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
            self.updateLine()
        }
    }
    
    // didAdd
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
        // 每当检测到新的锚点，将锚点加入到原有的平面中
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let visiblePlane = OverlayPlane(anchor: planeAnchor)
        self.visiblePlanes.append(visiblePlane)
        node.addChildNode(visiblePlane)
        
    }
    
    // didUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
        let planefilter = self.visiblePlanes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if planefilter == nil {
            return
        }
        // 每当检测到新的锚点，更新：删除旧的锚点，添加新的锚点，始终保持一个平面在场景中，不要有多个平面堆叠在一起，并且保持所得的平面为实时最新的一个。
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let plane = OverlayPlane(anchor: planeAnchor)
        self.visiblePlanes.append(plane)
        node.addChildNode(plane)
        // 更新平面
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    // didRemove
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.removePlane(anchor: planeAnchor)
            }
        }
        
    }
    
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    //    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    //        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    //    }
    
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        let state = camera.trackingState
        DispatchQueue.main.async {
            //self.lastState = state
        }
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        //        sessionInfoLabel.text = "Session was interrupted"
        resultLabel.text = "会话被中断"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        // sessionInfoLabel.text = "Session interruption ended"
        resultLabel.text = "会话中断停止"
        resetTracking()
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            HUG.show(title: (error as NSError).localizedDescription)
        }
        
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Set the sessinInfoLabel
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        
        //        var message: String {
        //            switch trackingState {
        //            case .normal where frame.anchors.isEmpty:
        //                return "请在水平表面移动设备"
        //            case .normal:
        //                return ""
        //            case .notAvailable:
        //                return "检测功能不可用"
        //            case .limited(.excessiveMotion):
        //                return "检测失败：请缓慢地移动您的设备"
        //            case .limited(.insufficientFeatures):
        //                return "检测失败：检测表面细节不清晰"
        //            case .limited(.initializing):
        //                return "正在检测平面"
        //            case .limited(.relocalizing):
        //                return "恢复中断"
        //            default:
        //                return ""
        //            }
        //        }
        
        
        
        
        // Update the UI to provide feedback on the state of the AR experience.
        var message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "请在水平表面移动设备"
            
            if ((self.focusSquare?.isOpenOrNot())!){
                
                
                myTimer = Timer(timeInterval: 3.0, target: self, selector: "countDownTick", userInfo: nil, repeats: false)
                
                message = "检测成功，请进行测量"
            }
            
        case .notAvailable:
            message = "检测功能不可用"
            
        case .limited(.excessiveMotion):
            message = "检测失败：请缓慢地移动您的设备"
            
        case .limited(.insufficientFeatures):
            message = "检测失败：检测表面细节不清晰"
            
        case .limited(.initializing):
            message = "正在检测平面"
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        
        //sessionInfoLabel.text = message
        resultLabel.text = message
        
        if (message.isEmpty) {
            //sessionInfoLabel.text = "检测成功，请选择模型"
            resultLabel.text = "平面检测成功，请进行测量操作"
        }
        //
        //        sessionInfoLabel.text = message
        //        sessionInfoView.isHidden = message.isEmpty
        
    }
    
    //    func countDownTick(_ countDown: Int, _ myTimer: Timer) {
    //
    //        countDown -= 1
    //
    //        if (countDown == 0) {
    //            myTimer!.invalidate()
    //            myTimer=nil
    //        }
    //
    //        //countdownLabel.text = "\(countdown)"
    //    }
    
    
    
}
