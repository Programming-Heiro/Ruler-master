//
//  ARMeasureRulerViewController+Actions.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import Foundation
import ARKit
import Photos


// MARK: - Target Action
//@objc private extension ARMeasureRulerViewController {
@objc extension ARMeasureRulerViewController {
    // 截图保存测量结果图像
    func saveImage(_ sender: UIButton) {
        func saveImage(image: UIImage) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (isSuccess: Bool, error: Error?) in
                if let e = error {
                    HUG.show(title: Localization.saveFail(), message: e.localizedDescription)
                } else{
                    HUG.show(title: Localization.saveSuccess())
                }
            }
        }
        
        let image = sceneView.snapshot()
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            saveImage(image: image)
        default:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    saveImage(image: image)
                default:
                    HUG.show(title: Localization.saveFail(), message: Localization.saveNeedPermission())
                }
            }
        }
    }
    
    
    // 放置测量点
    func placeAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (value) in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseIn], animations: {
                sender.transform = CGAffineTransform.identity
            }) { (value) in
            }
        }
        SoundEffect.play()
        switch mode {
        case .length:
            if let l = line {
                lines.append(l)
                line = nil
            } else  {
                let startPos = sceneView.worldPositionFromScreenPosition(indicator.center, objectPos: nil)
                if let p = startPos.position {
                    line = LineNode(startPos: p, sceneV: sceneView)
                }
            }
        case .area:
            if let l = lineSet {
                l.addLine()
            } else {
                let startPos = sceneView.worldPositionFromScreenPosition(indicator.center, objectPos: nil)
                if let p = startPos.position {
                    lineSet = LineSetNode(startPos: p, sceneV: sceneView)
                }
            }
        case .volume:
            print("select volume")
            return
        }
    }
    
    // 重置视图
    func restartAction(_ sender: UIButton) {
        showMenuAction(sender)
        line?.removeFromParent()
        line = nil
        for node in lines {
            node.removeFromParent()
        }
        
        lineSet?.removeFromParent()
        lineSet = nil
        for node in lineSets {
            node.removeFromParent()
        }
        restartSceneView()
        measureValue = nil
    }
    
    // 删除上一操作
    func deleteAction(_ sender: UIButton) {
        switch mode {
        case .length:
            if line != nil {
                line?.removeFromParent()
                line = nil
            } else if let lineLast = lines.popLast() {
                lineLast.removeFromParent()
            } else {
                lineSets.popLast()?.removeFromParent()
            }
        case .area:
            if let ls = lineSet {
                if !ls.removeLine() {
                    lineSet = nil
                }
            } else if let lineSetLast = lineSets.popLast() {
                lineSetLast.removeFromParent()
            } else {
                lines.popLast()?.removeFromParent()
            }
        case .volume:
            print("select volume")
            return
        }
        cancleButton.normalImage = Image.Close.delete
        measureValue = nil
    }
    
    
    // 复制测量结果
    func copyAction(_ sender: UIButton) {
        UIPasteboard.general.string = resultLabel.text
        HUG.show(title: "已复制到剪贴版")
    }
    
    
    // 跳转设置
    func moreAction(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "SettingViewController", bundle: nil).instantiateInitialViewController() else {
            return
        }
        showMenuAction(sender)
        present(vc, animated: true, completion: nil)
    }
    
    
    // 显示菜单
    func showMenuAction(_ sender: UIButton) {
        if menuButtonSet.isOn {
            menuButtonSet.dismiss()
            menuButton.more.normalImage = Image.More.close
        } else {
            menuButtonSet.show()
            menuButton.more.normalImage = Image.More.open
        }
    }
    
    // 完成面积测量
    func finishAreaAction(_ sender: UIButton) {
        guard mode == .area,
            let line = lineSet,
            line.lines.count >= 2 else {
                lineSet = nil
                return
        }
        lineSets.append(line)
        lineSet = nil
        changeFinishState(state: false)
    }
    
    
    
    // 变换面积测量完成按钮状态
    func changeFinishState(state: Bool) {
        guard finishButtonState != state else { return }
        finishButtonState = state
        var center = placeButton.center
        if state {
            center.y -= 100
        }
        UIView.animate(withDuration: 0.3) {
            self.finishButton.center = center
        }
    }
    
    // 变换测量单位
    func changeMeasureUnitAction(_ sender: UITapGestureRecognizer) {
        measureUnit = measureUnit.next()
    }
    
    
    func changeMeasureMode(_ sender: UIButton) {
        showMenuAction(sender)
        lineSet = nil
        line = nil
        switch mode {
        case .area:
            changeFinishState(state: false)
            menuButton.measurement.normalImage = Image.Menu.area
            placeButton.normalImage  = Image.Place.length
            placeButton.disabledImage = Image.Place.length
            
            mode = .length
        case .length:
            menuButton.measurement.normalImage = Image.Menu.length
            placeButton.normalImage  = Image.Place.area
            placeButton.disabledImage = Image.Place.area
            mode = .area
        case .volume:
            print("select volume")
            //下面的代码是展示代替动作的
            menuButton.measurement.normalImage = Image.Menu.length
            placeButton.normalImage  = Image.Place.area
            placeButton.disabledImage = Image.Place.area
            mode = .area
        }
        resultLabel.attributedText = mode.toAttrStr()
    }
    
    
}

// MARK: - UI
//fileprivate extension ARMeasureRulerViewController {
extension ARMeasureRulerViewController {
    
    func restartSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        measureUnit = ApplicationSetting.Status.CurrentUnit
        resultLabel.attributedText = mode.toAttrStr()
        updateFocusSquare()
    }
    
    func updateLine() -> Void {
        let startPos = sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
        if let p = startPos.position {
            let camera = self.sceneView.session.currentFrame?.camera
            let cameraPos = SCNVector3.positionFromTransform(camera!.transform)
            if cameraPos.distanceFromPos(pos: p) < 0.05 {
                if line == nil {
                    placeButton.isEnabled = false
                    indicator.image = Image.Indicator.disable
                }
                return;
            }
            placeButton.isEnabled = true
            indicator.image = Image.Indicator.enable
            switch mode {
            case .length:
                guard let currentLine = line else {
                    cancleButton.normalImage = Image.Close.delete
                    return
                }
                let length = currentLine.updatePosition(pos: p, camera: self.sceneView.session.currentFrame?.camera, unit: measureUnit)
                measureValue =  MeasurementUnit(meterUnitValue: length, isArea: false)
                cancleButton.normalImage = Image.Close.cancle
            case .area:
                guard let set = lineSet else {
                    changeFinishState(state: false)
                    cancleButton.normalImage = Image.Close.delete
                    return
                }
                let area = set.updatePosition(pos: p, camera: self.sceneView.session.currentFrame?.camera, unit: measureUnit)
                measureValue =  MeasurementUnit(meterUnitValue: area, isArea: true)
                changeFinishState(state: set.lines.count >= 2)
                cancleButton.normalImage = Image.Close.cancle
            case .volume:
                print("select volume")
                return
            }
        }
    }
}
