//
//  ApplicationSetting.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import UIKit

class ApplicationSetting {
    // 初始化状态标志
    struct Config {
        static let initializeUnit = "com.ARRuler.initializeUnit"
        static let initializedisplayFocus = "com.ARRuler.initializedisplayFocus"
    }
    
    struct Status {
        
        static var CurrentUnit: MeasurementUnit.Unit = {
            guard let str = UserDefaults.standard.string(forKey: Config.initializeUnit)  else {
                //初始默认为cm单位, let 单位设置为常量
                return MeasurementUnit.Unit.centimeter
            }
            return MeasurementUnit.Unit(rawValue: str) ?? MeasurementUnit.Unit.centimeter
        }() {
            didSet {
                UserDefaults.standard.setValue(CurrentUnit.rawValue, forKey: Config.initializeUnit)
            }
        }
        
        static var displayFocus: Bool = {
            // 用bool类型判断是否打开FocusSquare
            guard UserDefaults.standard.object(forKey: Config.initializedisplayFocus) != nil else  {
                return true
            }
            return UserDefaults.standard.bool(forKey: Config.initializedisplayFocus)
        }() {
            didSet {
                UserDefaults.standard.set(displayFocus, forKey: Config.initializedisplayFocus)
            }
        }
    }

}
