//
//  RulerARProViewController.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Photos
import AudioToolbox
import VideoToolbox


typealias Localization = R.string.rulerString

class ARMeasureRulerViewController: UIViewController {
    
    enum MeasurementMode {
        case length
        case area
        case volume
        func toAttrStr() -> NSAttributedString {
            let str = self == .area ? R.string.rulerString.startArea() : R.string.rulerString.startLength()
            // 在测量结果显示之前resultLabel的字体大小和字体颜色
            return NSAttributedString(string: str, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20), NSAttributedStringKey.foregroundColor: UIColor.gray])
            //return NSAttributedString(string: str)
        }
    }
    struct Image {
        struct Menu {
            static let volume = #imageLiteral(resourceName: "menu_area")
            static let area = #imageLiteral(resourceName: "menu_area")
            static let length = #imageLiteral(resourceName: "menu_length")
            static let reset = #imageLiteral(resourceName: "menu_reset")
            static let setting = #imageLiteral(resourceName: "menu_setting")
            static let save = #imageLiteral(resourceName: "menu_save")
        }
        struct More {
            static let close = #imageLiteral(resourceName: "more_off")
            static let open = #imageLiteral(resourceName: "more_on")
        }
        struct Place {
            static let area = #imageLiteral(resourceName: "place_area")
            static let length = #imageLiteral(resourceName: "place_length")
            static let done = #imageLiteral(resourceName: "place_done")
        }
        struct Close {
            static let delete = #imageLiteral(resourceName: "cancle_delete")
            static let cancle = #imageLiteral(resourceName: "cancle_back")
        }
        struct Indicator {
            static let enable = #imageLiteral(resourceName: "img_indicator_enable")
            static let disable = #imageLiteral(resourceName: "img_indicator_disable")
        }
        struct Result {
            static let copy = #imageLiteral(resourceName: "result_copy")
        }
    }
    
    // MARK: - SoundEffect
    struct SoundEffect {
        static var soundID: SystemSoundID = 0
        static func install() {
            guard let path = Bundle.main.path(forResource: "SetPoint", ofType: "wav") else { return }
            let url = URL(fileURLWithPath: path)
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        }
        static func play() {
            guard soundID != 0 else { return }
            AudioServicesPlaySystemSound(soundID)
        }
        static func dispose() {
            guard soundID != 0 else { return }
            AudioServicesDisposeSystemSoundID(soundID)
        }

    }
    
    //private let sceneView: ARSCNView =  ARSCNView(frame: UIScreen.main.bounds)
    let sceneView: ARSCNView =  ARSCNView(frame: UIScreen.main.bounds)
    //private let indicator = UIImageView()
    let indicator = UIImageView()
    //private let resultLabel = UILabel().then({
    
    //显示标签字体初始化,修改动态结果属性在toAttrStr()方法
    let resultLabel = UILabel().then({
        $0.textAlignment = .center
        $0.textColor = UIColor.gray
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
        //$0.lineBreakMode = .byWordWrapping
        // 自动换行
        $0.adjustsFontSizeToFitWidth = true

    })
    

    let sessionInfoLabel: UILabel = {
        let sessionInfoLabel = UILabel()
        sessionInfoLabel.textAlignment = .left
        sessionInfoLabel.textColor = UIColor.red
        sessionInfoLabel.numberOfLines = 0
        sessionInfoLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
        sessionInfoLabel.adjustsFontSizeToFitWidth = true
        //sessionInfoLabel.text = "hello"
        sessionInfoLabel.backgroundColor = UIColor.gray
        sessionInfoLabel.frame = CGRect(x: 15, y: 15, width: 60, height: 60)
        return sessionInfoLabel
    }()

    
//    private var line: LineNode?
//    private var lineSet: LineSetNode?
//
//
//    private var lines: [LineNode] = []
//    private var lineSets: [LineSetNode] = []
//    private var planes = [ARPlaneAnchor: Plane]()
    var line: LineNode?
    var lineSet: LineSetNode?
    
    
    var lines: [LineNode] = []
    var lineSets: [LineSetNode] = []
    var planes = [ARPlaneAnchor: Plane]()
    
    //private var focusSquare: FocusSquare?
    var focusSquare: FocusSquare?
    
    var visiblePlanes = [OverlayPlane]()
    
    //private var mode = MeasurementMode.length
    var mode = MeasurementMode.length
    //private var finishButtonState = false
    var finishButtonState = false
    //private var lastState: ARCamera.TrackingState = .notAvailable {
//    var lastState: ARCamera.TrackingState = .notAvailable {
//        didSet {
//            switch lastState {
//            case .notAvailable:
//                guard HUG.isVisible else { return }
//                HUG.show(title: Localization.arNotAvailable())
//            case .limited(let reason):
//                switch reason {
//                case .initializing:
//                    HUG.show(title: Localization.arInitializing(), message: Localization.arInitializingMessage(), inSource: self, autoDismissDuration: nil)
//                case .insufficientFeatures:
//                    HUG.show(title: Localization.arExcessiveMotion(), message: Localization.arInitializingMessage(), inSource: self, autoDismissDuration: 5)
//                case .excessiveMotion:
//                    HUG.show(title: Localization.arExcessiveMotion(), message: Localization.arExcessiveMotionMessage(), inSource: self, autoDismissDuration: 5)
//                case .relocalizing:
//                    print("camera did change tracking state: limited, relocalizing")
//                }
//            case .normal:
//                HUG.dismiss()
//            }
//        }
//    }
    //private var measureUnit = ApplicationSetting.Status.CurrentUnit {
    var measureUnit = ApplicationSetting.Status.CurrentUnit {
        didSet {
            let v = measureValue
            measureValue = v
        }
    }
    //private var measureValue: MeasurementUnit? {
    var measureValue: MeasurementUnit? {
        didSet {
            if let m = measureValue {
                resultLabel.text = nil
                resultLabel.attributedText = m.attributeString(type: measureUnit)
            } else {
                resultLabel.attributedText = mode.toAttrStr()
            }
        }
    }
    
    // false = close true = open
    var Open: Bool = true
    
    // MARK: - 菜单按钮
//    private lazy var menuButtonSet: PopButton = PopButton(buttons: menuButton.measurement,
//                                                          //menuButton.measurement,
//                                                          menuButton.save,
//                                                          menuButton.reset,
//                                                          menuButton.setting,
//                                                          menuButton.more)
    
//    private let placeButton = UIButton(size: CGSize(width: 80, height: 80), image: Image.Place.length)
//    private let cancleButton = UIButton(size: CGSize(width: 60, height: 60), image: Image.Close.delete)
//    private let finishButton = UIButton(size: CGSize(width: 60, height: 60), image: Image.Place.done)
//    private let menuButton = (measurement: UIButton(size: CGSize(width: 50, height: 50), image: Image.Menu.area),
//                              //measurement: UIButton(size: CGSize(width: 50, height: 50), image: Image.Menu.area),
//                         save: UIButton(size: CGSize(width: 50, height: 50), image: Image.Menu.save),
//                        reset: UIButton(size: CGSize(width: 50, height: 50), image: Image.Menu.reset),
//                        setting: UIButton(size: CGSize(width: 50, height: 50), image: Image.Menu.setting),
//                        more: UIButton(size: CGSize(width: 60, height: 60), image: Image.More.close))
    lazy var menuButtonSet: PopButton = PopButton(buttons: menuButton.measurement,
                                                          //menuButton.measurement,
        menuButton.save,
        menuButton.reset,
        menuButton.setting,
        menuButton.more)
    // 主界面三个按钮
    let placeButton = UIButton(size: CGSize(width: 100, height: 100), image: Image.Place.length)
    let cancleButton = UIButton(size: CGSize(width: 60, height: 60), image: Image.Close.delete)
    let finishButton = UIButton(size: CGSize(width: 60, height: 60), image: Image.Place.done)
    // 菜单界面
    let menuButton = (measurement: UIButton(size: CGSize(width: 60, height: 60), image: Image.Menu.area),
                              //measurement: UIButton(size: CGSize(width: 50, height: 50), image: Image.Menu.area),
        save: UIButton(size: CGSize(width: 60, height: 60), image: Image.Menu.save),
        reset: UIButton(size: CGSize(width: 60, height: 60), image: Image.Menu.reset),
        setting: UIButton(size: CGSize(width: 60, height: 60), image: Image.Menu.setting),
        more: UIButton(size: CGSize(width: 60, height: 60), image: Image.More.close))
    
   
    var countDown = 0
    var myTimer: Timer? = nil
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        layoutViewController()
        setupFocusSquare()
        SoundEffect.install()
        self.sceneView.debugOptions = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartSceneView()
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    
//    // MARK: - 代码布局
//    private func layoutViewController() {
//        let width = view.bounds.width //屏幕宽度
//        let height = view.bounds.height //屏幕高度
//        view.backgroundColor = UIColor.black
//        
//        
//        //do {
//            view.addSubview(sceneView)
//            sceneView.frame = view.bounds
//            sceneView.delegate = self
//        //}
//        
//        //do {
//            let resultLabelBg = UIView()
//            resultLabelBg.backgroundColor = UIColor.white.withAlphaComponent(0.8)
//            //resultLabelBg.layer.cornerRadius = 45
//            resultLabelBg.layer.cornerRadius = 30
//            resultLabelBg.clipsToBounds = true
//            
//            //复制按钮
//            let copy = UIButton(size: CGSize(width: 30, height: 30), image: Image.Result.copy)
//            //复制到剪切板动作
//            copy.addTarget(self, action: #selector(ARMeasureRulerViewController.copyAction(_:)), for: .touchUpInside)
//            
//            //点击结果切换度量单位
//            let tap = UITapGestureRecognizer(target: self, action: #selector(ARMeasureRulerViewController.changeMeasureUnitAction(_:)))
//            resultLabel.addGestureRecognizer(tap)
//            resultLabel.isUserInteractionEnabled = true
//            
//            //resultLabelBg.frame = CGRect(x: 30, y: 30, width: width - 60, height: 90)
//            resultLabelBg.frame = CGRect(x: 150, y: 30, width: width - 180, height: 60)
//            //复制按钮的位置
//            copy.frame = CGRect(x: resultLabelBg.frame.maxX - 10 - 30, y: resultLabelBg.frame.minY + (resultLabelBg.frame.height - 30)/2, width: 30, height: 30)
//            
//            resultLabel.frame = resultLabelBg.frame.insetBy(dx: 10, dy: 0)
//            resultLabel.attributedText = mode.toAttrStr()
//            
//            view.addSubview(resultLabelBg)
//            view.addSubview(resultLabel)
//            view.addSubview(copy)
//
//        //}
//        
//        //do {
//            indicator.image = Image.Indicator.disable
//            view.addSubview(indicator)
//            indicator.frame = CGRect(x: (width - 60)/2, y: (height - 60)/2, width: 60, height: 60)
//        //}
//        //do {
//            view.addSubview(finishButton)
//            view.addSubview(placeButton)
//            finishButton.addTarget(self, action: #selector(ARMeasureRulerViewController.finishAreaAction(_:)), for: .touchUpInside)
//            placeButton.addTarget(self, action: #selector(ARMeasureRulerViewController.placeAction(_:)), for: .touchUpInside)
//            placeButton.frame = CGRect(x: (width - 80)/2, y: (height - 20 - 80), width: 80, height: 80)
//            finishButton.center = placeButton.center
//        //}
//        //do {
//            view.addSubview(cancleButton)
//            cancleButton.addTarget(self, action: #selector(ARMeasureRulerViewController.deleteAction(_:)), for: .touchUpInside)
//            cancleButton.frame = CGRect(x: 40, y: placeButton.frame.origin.y + 10, width: 60, height: 60)
//        //}
//        //do {
//            view.addSubview(menuButtonSet)
//            menuButton.more.addTarget(self, action: #selector(ARMeasureRulerViewController.showMenuAction(_:)), for: .touchUpInside)
//            menuButton.setting.addTarget(self, action: #selector(ARMeasureRulerViewController.moreAction(_:)), for: .touchUpInside)
//            menuButton.reset.addTarget(self, action: #selector(ARMeasureRulerViewController.restartAction(_:)), for: .touchUpInside)
//            menuButton.measurement.addTarget(self, action: #selector(ARMeasureRulerViewController.changeMeasureMode(_:)), for: .touchUpInside)
//            menuButton.save.addTarget(self, action: #selector(ARMeasureRulerViewController.saveImage(_:)), for: .touchUpInside)
//            menuButtonSet.frame = CGRect(x: (width - 40 - 60), y: placeButton.frame.origin.y + 10, width: 60, height: 60)
//            
//
//        //}
//        
//    }
    
    //这个函数貌似没用
//    private func configureObserver() {
//        func cleanLine() {
//            line?.removeFromParent()
//            line = nil
//            for node in lines {
//                node.removeFromParent()
//            }
//
//        }
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { _ in
//            cleanLine()
//        }
//    }
    
    deinit {
        SoundEffect.dispose()
        NotificationCenter.default.removeObserver(self)
    }
}


//// MARK: - Target Action
////@objc private extension ARMeasureRulerViewController {
//@objc extension ARMeasureRulerViewController {
//    // 截图保存测量结果图像
//    func saveImage(_ sender: UIButton) {
//        func saveImage(image: UIImage) {
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAsset(from: image)
//            }) { (isSuccess: Bool, error: Error?) in
//                if let e = error {
//                    HUG.show(title: Localization.saveFail(), message: e.localizedDescription)
//                } else{
//                    HUG.show(title: Localization.saveSuccess())
//                }
//            }
//        }
//        
//        let image = sceneView.snapshot()
//        switch PHPhotoLibrary.authorizationStatus() {
//        case .authorized:
//            saveImage(image: image)
//        default:
//            PHPhotoLibrary.requestAuthorization { (status) in
//                switch status {
//                case .authorized:
//                    saveImage(image: image)
//                default:
//                    HUG.show(title: Localization.saveFail(), message: Localization.saveNeedPermission())
//                }
//            }
//        }
//    }
//    
//    
//    // 放置测量点
//    func placeAction(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
//            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        }) { (value) in
//            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseIn], animations: {
//                sender.transform = CGAffineTransform.identity
//            }) { (value) in
//            }
//        }
//        SoundEffect.play()
//        switch mode {
//        case .length:
//            if let l = line {
//                lines.append(l)
//                line = nil
//            } else  {
//                let startPos = sceneView.worldPositionFromScreenPosition(indicator.center, objectPos: nil)
//                if let p = startPos.position {
//                    line = LineNode(startPos: p, sceneV: sceneView)
//                }
//            }
//        case .area:
//            if let l = lineSet {
//                l.addLine()
//            } else {
//                let startPos = sceneView.worldPositionFromScreenPosition(indicator.center, objectPos: nil)
//                if let p = startPos.position {
//                    lineSet = LineSetNode(startPos: p, sceneV: sceneView)
//                }
//            }
//        case .volume:
//            print("select volume")
//            return
//        }
//    }
//    
//    // 重置视图
//    func restartAction(_ sender: UIButton) {
//        showMenuAction(sender)
//        line?.removeFromParent()
//        line = nil
//        for node in lines {
//            node.removeFromParent()
//        }
//        
//        lineSet?.removeFromParent()
//        lineSet = nil
//        for node in lineSets {
//            node.removeFromParent()
//        }
//        restartSceneView()
//        measureValue = nil
//    }
//    
//    // 删除上一操作
//    func deleteAction(_ sender: UIButton) {
//        switch mode {
//        case .length:
//            if line != nil {
//                line?.removeFromParent()
//                line = nil
//            } else if let lineLast = lines.popLast() {
//                lineLast.removeFromParent()
//            } else {
//                lineSets.popLast()?.removeFromParent()
//            }
//        case .area:
//            if let ls = lineSet {
//                if !ls.removeLine() {
//                    lineSet = nil
//                }
//            } else if let lineSetLast = lineSets.popLast() {
//                lineSetLast.removeFromParent()
//            } else {
//                lines.popLast()?.removeFromParent()
//            }
//        case .volume:
//            print("select volume")
//            return
//        }
//        cancleButton.normalImage = Image.Close.delete
//        measureValue = nil
//    }
//    
//    
//    // 复制测量结果
//    func copyAction(_ sender: UIButton) {
//        UIPasteboard.general.string = resultLabel.text
//        HUG.show(title: "已复制到剪贴版")
//    }
//    
//    
//    // 跳转设置
//    func moreAction(_ sender: UIButton) {
//        guard let vc = UIStoryboard(name: "SettingViewController", bundle: nil).instantiateInitialViewController() else {
//            return
//        }
//        showMenuAction(sender)
//        present(vc, animated: true, completion: nil)
//    }
//    
//    
//    // 显示菜单
//    func showMenuAction(_ sender: UIButton) {
//        if menuButtonSet.isOn {
//            menuButtonSet.dismiss()
//            menuButton.more.normalImage = Image.More.close
//        } else {
//            menuButtonSet.show()
//            menuButton.more.normalImage = Image.More.open
//        }
//    }
//    
//    // 完成面积测量
//    func finishAreaAction(_ sender: UIButton) {
//        guard mode == .area,
//            let line = lineSet,
//            line.lines.count >= 2 else {
//                lineSet = nil
//                return
//        }
//        lineSets.append(line)
//        lineSet = nil
//        changeFinishState(state: false)
//    }
//    
//    
//    
//    // 变换面积测量完成按钮状态
//    func changeFinishState(state: Bool) {
//        guard finishButtonState != state else { return }
//        finishButtonState = state
//        var center = placeButton.center
//        if state {
//            center.y -= 100
//        }
//        UIView.animate(withDuration: 0.3) {
//            self.finishButton.center = center
//        }
//    }
//    
//    // 变换测量单位
//    func changeMeasureUnitAction(_ sender: UITapGestureRecognizer) {
//        measureUnit = measureUnit.next()
//    }
//    
//    
//    func changeMeasureMode(_ sender: UIButton) {
//        showMenuAction(sender)
//        lineSet = nil
//        line = nil
//        switch mode {
//        case .area:
//            changeFinishState(state: false)
//            menuButton.measurement.normalImage = Image.Menu.area
//            placeButton.normalImage  = Image.Place.length
//            placeButton.disabledImage = Image.Place.length
//
//            mode = .length
//        case .length:
//            menuButton.measurement.normalImage = Image.Menu.length
//            placeButton.normalImage  = Image.Place.area
//            placeButton.disabledImage = Image.Place.area
//            mode = .area
//        case .volume:
//            print("select volume")
//            //下面的代码是展示代替动作的
//            menuButton.measurement.normalImage = Image.Menu.length
//            placeButton.normalImage  = Image.Place.area
//            placeButton.disabledImage = Image.Place.area
//            mode = .area
//        }
//        resultLabel.attributedText = mode.toAttrStr()
//    }
//    
//    
//}


//// MARK: - UI
////fileprivate extension ARMeasureRulerViewController {
//extension ARMeasureRulerViewController {
//    
//    func restartSceneView() {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//        measureUnit = ApplicationSetting.Status.CurrentUnit
//        resultLabel.attributedText = mode.toAttrStr()
//        updateFocusSquare()
//    }
//    
//    func updateLine() -> Void {
//        let startPos = sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
//        if let p = startPos.position {
//            let camera = self.sceneView.session.currentFrame?.camera
//            let cameraPos = SCNVector3.positionFromTransform(camera!.transform)
//            if cameraPos.distanceFromPos(pos: p) < 0.05 {
//                if line == nil {
//                    placeButton.isEnabled = false
//                    indicator.image = Image.Indicator.disable
//                }
//                return;
//            }
//            placeButton.isEnabled = true
//            indicator.image = Image.Indicator.enable
//            switch mode {
//            case .length:
//                guard let currentLine = line else {
//                    cancleButton.normalImage = Image.Close.delete
//                    return
//                }
//                let length = currentLine.updatePosition(pos: p, camera: self.sceneView.session.currentFrame?.camera, unit: measureUnit)
//                measureValue =  MeasurementUnit(meterUnitValue: length, isArea: false)
//                cancleButton.normalImage = Image.Close.cancle
//            case .area:
//                guard let set = lineSet else {
//                    changeFinishState(state: false)
//                    cancleButton.normalImage = Image.Close.delete
//                    return
//                }
//                let area = set.updatePosition(pos: p, camera: self.sceneView.session.currentFrame?.camera, unit: measureUnit)
//                measureValue =  MeasurementUnit(meterUnitValue: area, isArea: true)
//                changeFinishState(state: set.lines.count >= 2)
//                cancleButton.normalImage = Image.Close.cancle
//            case .volume:
//                print("select volume")
//                return
//            }
//        }
//    }
//}




// MARK： - AR


// MARK: - Plane
//fileprivate extension ARMeasureRulerViewController {
extension ARMeasureRulerViewController {
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        let plane = Plane(anchor, false)
        planes[anchor] = plane
        node.addChildNode(plane)
        indicator.image = Image.Indicator.enable
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
}



//// MARK: - FocusSquare
//fileprivate extension ARMeasureRulerViewController {
//
////    // MARK: - Focus Square
////
////    func setupFocusSquare() {
////        focusSquare.unhide()
////        focusSquare.removeFromParentNode()
////        sceneView.scene.rootNode.addChildNode(focusSquare)
////    }
////
////    func updateFocusSquare() {
////        let (worldPosition, planeAnchor, _) = worldPositionFromScreenPosition(view.center, objectPos: focusSquare.position)
////        if let worldPosition = worldPosition {
////            focusSquare.update(for: worldPosition, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
////        }
////    }
//
//    func setupFocusSquare() {
//        focusSquare?.isHidden = true
//        focusSquare?.removeFromParentNode()
//        focusSquare = FocusSquare()
//        sceneView.scene.rootNode.addChildNode(focusSquare!)
//    }
//
//    func updateFocusSquare() {
//        if ApplicationSetting.Status.displayFocus {
//            focusSquare?.unhide()
//        } else {
//            focusSquare?.hide()
//        }
//        let (worldPos, planeAnchor, _) = sceneView.worldPositionFromScreenPosition(sceneView.bounds.mid, objectPos: focusSquare?.position)
//        if let worldPos = worldPos {
//            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
//        }
//    }
//}





//// MARK: - ARSCNViewDelegate
//extension ARMeasureRulerViewController: ARSCNViewDelegate {
//    
////    func session(_ session: ARSession, didFailWithError error: Error) {
////        DispatchQueue.main.async {
////            HUG.show(title: (error as NSError).localizedDescription)
////        }
////    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        DispatchQueue.main.async {
//            self.updateFocusSquare()
//            self.updateLine()
//        }
//    }
//    
//    // didAdd
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        DispatchQueue.main.async {
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                self.addPlane(node: node, anchor: planeAnchor)
//            }
//        }
//        // 每当检测到新的锚点，将锚点加入到原有的平面中
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        let visiblePlane = OverlayPlane(anchor: planeAnchor)
//        self.visiblePlanes.append(visiblePlane)
//        node.addChildNode(visiblePlane)
//        
//    }
//    
//    // didUpdate
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        DispatchQueue.main.async {
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                self.updatePlane(anchor: planeAnchor)
//            }
//        }
//        let planefilter = self.visiblePlanes.filter { plane in
//            return plane.anchor.identifier == anchor.identifier
//            }.first
//        
//        if planefilter == nil {
//            return
//        }
//        // 每当检测到新的锚点，更新：删除旧的锚点，添加新的锚点，始终保持一个平面在场景中，不要有多个平面堆叠在一起，并且保持所得的平面为实时最新的一个。
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        node.enumerateChildNodes { (childNode, _) in
//            childNode.removeFromParentNode()
//        }
//        let plane = OverlayPlane(anchor: planeAnchor)
//        self.visiblePlanes.append(plane)
//        node.addChildNode(plane)
//        // 更新平面
//        plane.update(anchor: anchor as! ARPlaneAnchor)
//    }
//    
//    // didRemove
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        DispatchQueue.main.async {
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                self.removePlane(anchor: planeAnchor)
//            }
//        }
//        
//    }
//    
//    
//    // MARK: - ARSessionDelegate
//    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        guard let frame = session.currentFrame else { return }
//        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
//    }
//    
//    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
//        guard let frame = session.currentFrame else { return }
//        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
//    }
//    
////    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
////        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
////    }
//    
//    
//    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//        let state = camera.trackingState
//        DispatchQueue.main.async {
//            //self.lastState = state
//        }
//        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
//    }
//    
//    
//    
//    // MARK: - ARSessionObserver
//    
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
////        sessionInfoLabel.text = "Session was interrupted"
//        resultLabel.text = "会话被中断"
//    }
//    
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required.
//        // sessionInfoLabel.text = "Session interruption ended"
//        resultLabel.text = "会话中断停止"
//        resetTracking()
//    }
//    
//    
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        DispatchQueue.main.async {
//            HUG.show(title: (error as NSError).localizedDescription)
//        }
//        
//        // Present an error message to the user.
//        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
//        resetTracking()
//    }
//
//    
//    private func resetTracking() {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//    }
//    
//    // MARK: - Set the sessinInfoLabel
//    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
//        // Update the UI to provide feedback on the state of the AR experience.
//        
////        var message: String {
////            switch trackingState {
////            case .normal where frame.anchors.isEmpty:
////                return "请在水平表面移动设备"
////            case .normal:
////                return ""
////            case .notAvailable:
////                return "检测功能不可用"
////            case .limited(.excessiveMotion):
////                return "检测失败：请缓慢地移动您的设备"
////            case .limited(.insufficientFeatures):
////                return "检测失败：检测表面细节不清晰"
////            case .limited(.initializing):
////                return "正在检测平面"
////            case .limited(.relocalizing):
////                return "恢复中断"
////            default:
////                return ""
////            }
////        }
//        
//        
//        
//        
//        // Update the UI to provide feedback on the state of the AR experience.
//        var message: String
//        
//        switch trackingState {
//        case .normal where frame.anchors.isEmpty:
//            // No planes detected; provide instructions for this app's AR interactions.
//            message = "请在水平表面移动设备"
//            
//            if ((self.focusSquare?.isOpenOrNot())!){
//                
//                
//                myTimer = Timer(timeInterval: 3.0, target: self, selector: "countDownTick", userInfo: nil, repeats: false)
//                
//                message = "检测成功，请进行测量"
//            }
//            
//        case .notAvailable:
//            message = "检测功能不可用"
//            
//        case .limited(.excessiveMotion):
//            message = "检测失败：请缓慢地移动您的设备"
//            
//        case .limited(.insufficientFeatures):
//            message = "检测失败：检测表面细节不清晰"
//            
//        case .limited(.initializing):
//            message = "正在检测平面"
//            
//        default:
//            // No feedback needed when tracking is normal and planes are visible.
//            // (Nor when in unreachable limited-tracking states.)
//            message = ""
//            
//        }
//        
//        
//        //sessionInfoLabel.text = message
//        resultLabel.text = message
//        
//        if (message.isEmpty) {
//            //sessionInfoLabel.text = "检测成功，请选择模型"
//            resultLabel.text = "平面检测成功，请进行测量操作"
//        }
////
////        sessionInfoLabel.text = message
////        sessionInfoView.isHidden = message.isEmpty
//        
//    }
//    
////    func countDownTick(_ countDown: Int, _ myTimer: Timer) {
////
////        countDown -= 1
////
////        if (countDown == 0) {
////            myTimer!.invalidate()
////            myTimer=nil
////        }
////
////        //countdownLabel.text = "\(countdown)"
////    }
//    
//    
//    
//}
