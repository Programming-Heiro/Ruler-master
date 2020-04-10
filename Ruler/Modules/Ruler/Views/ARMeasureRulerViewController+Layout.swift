//
//  ARMeasureRulerViewController+Layout.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import Foundation
import ARKit


extension ARMeasureRulerViewController {
    // MARK: - 代码布局
    //private func layoutViewController() {
    func layoutViewController() {
        let width = view.bounds.width //屏幕宽度
        let height = view.bounds.height //屏幕高度
        view.backgroundColor = UIColor.black
        
        
        //do {
        view.addSubview(sceneView)
        sceneView.frame = view.bounds
        sceneView.delegate = self
        //}
        
        //do {
        let resultLabelView = UIView()
        //resultLabelView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        //resultLabelBg.layer.cornerRadius = 45
        resultLabelView.layer.cornerRadius = 15
        resultLabelView.clipsToBounds = true
        
        //resultLabelBg.frame = CGRect(x: 30, y: 30, width: width - 60, height: 90)
        //resultLabelView.frame = CGRect(x: 195, y: 15, width: width - 210, height: 60)
        resultLabelView.frame = CGRect(x: 15, y: 15, width: width - 30, height: 60)
        //毛玻璃特效
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = resultLabelView.bounds
        resultLabelView.addSubview(blurredEffectView)
        //生动特效
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = resultLabelView.bounds
        
        let sessionInfoView = UIView()
        sessionInfoView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        sessionInfoView.layer.cornerRadius = 15
        sessionInfoView.clipsToBounds = true
        
        //resultLabelBg.frame = CGRect(x: 30, y: 30, width: width - 60, height: 90)
        sessionInfoView.frame = CGRect(x: 15, y: 15, width: width - 210, height: 60)
        
        sessionInfoView.isHidden = true
        
        //复制按钮
        let copy = UIButton(size: CGSize(width: 30, height: 30), image: Image.Result.copy)
        //复制到剪切板动作
        copy.addTarget(self, action: #selector(ARMeasureRulerViewController.copyAction(_:)), for: .touchUpInside)
        
        //点击结果切换度量单位
        let tap = UITapGestureRecognizer(target: self, action: #selector(ARMeasureRulerViewController.changeMeasureUnitAction(_:)))
        resultLabel.addGestureRecognizer(tap)
        resultLabel.isUserInteractionEnabled = true
        
        
        //复制按钮的位置
        copy.frame = CGRect(x: resultLabelView.frame.maxX - 10 - 30, y: resultLabelView.frame.minY + (resultLabelView.frame.height - 30)/2, width: 30, height: 30)
        
        resultLabel.frame = resultLabelView.frame.insetBy(dx: 10, dy: 0)
        resultLabel.attributedText = mode.toAttrStr()
        
        sessionInfoLabel.frame = sessionInfoView.frame.insetBy(dx: 0, dy: -5)
        //sessionInfoLabel.text = "hello"
        //sessionInfoLabel.sizeToFit()//label外边框刚好紧贴字体
        //sessionInfoLabel.center = sessionInfoView.convert(sessionInfoView.center, from: sessionInfoView.subviews)
        sessionInfoView.addSubview(sessionInfoLabel)
        view.addSubview(sessionInfoView)
        
        view.addSubview(resultLabelView)
        view.addSubview(resultLabel)
        view.addSubview(copy)
        
        //}
        
        //do {
        indicator.image = Image.Indicator.disable
        view.addSubview(indicator)
        indicator.frame = CGRect(x: (width - 60)/2, y: (height - 60)/2, width: 60, height: 60)
        //}
        //do {
        view.addSubview(finishButton)
        view.addSubview(placeButton)
        finishButton.addTarget(self, action: #selector(ARMeasureRulerViewController.finishAreaAction(_:)), for: .touchUpInside)
        placeButton.addTarget(self, action: #selector(ARMeasureRulerViewController.placeAction(_:)), for: .touchUpInside)
        //placeButton.frame = CGRect(x: (width - 80)/2, y: (height - 20 - 80), width: 100, height: 100)
        placeButton.frame = CGRect(x: (width - 90)/2, y: (height - 20 - 100), width: 100, height: 100)
        //placeButton.frame = CGRect(x: self.view.center.x, y: (height - 20 - 80), width: 100, height: 100)
        //placeButton. = self.view.center
        finishButton.center = placeButton.center
        //}
        //do {
        view.addSubview(cancleButton)
        cancleButton.addTarget(self, action: #selector(ARMeasureRulerViewController.deleteAction(_:)), for: .touchUpInside)
        cancleButton.frame = CGRect(x: 40, y: placeButton.frame.origin.y + 30, width: 60, height: 60)
        //}
        //do {
        view.addSubview(menuButtonSet)
        menuButton.more.addTarget(self, action: #selector(ARMeasureRulerViewController.showMenuAction(_:)), for: .touchUpInside)
        menuButton.setting.addTarget(self, action: #selector(ARMeasureRulerViewController.moreAction(_:)), for: .touchUpInside)
        menuButton.reset.addTarget(self, action: #selector(ARMeasureRulerViewController.restartAction(_:)), for: .touchUpInside)
        menuButton.measurement.addTarget(self, action: #selector(ARMeasureRulerViewController.changeMeasureMode(_:)), for: .touchUpInside)
        menuButton.save.addTarget(self, action: #selector(ARMeasureRulerViewController.saveImage(_:)), for: .touchUpInside)
        menuButtonSet.frame = CGRect(x: (width - 40 - 60), y: placeButton.frame.origin.y + 30, width: 60, height: 60)
        
        
        //}
        
    }
}
