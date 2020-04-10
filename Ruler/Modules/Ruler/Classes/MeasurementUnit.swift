//
//  Distance.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import UIKit

// 测量单位结构体
struct MeasurementUnit {
    enum Unit: String {
        static let all: [Unit] = [.inch, .foot, .centimeter, .meter]
        case inch = "inch"
        case foot = "foot"
        case centimeter = "centimeter"
        case meter = "meter"
        func next() -> Unit {
            switch self {
            case .inch:
                return .foot
            case .foot:
                return .centimeter
            case .centimeter:
                return .meter
            case .meter:
                return .inch
            }
        }
        
        func meterScale(isArea: Bool = false) -> Float {
            let scale: Float = isArea ? 2 : 1
            switch self {
            case .meter: return pow(1, scale)
            case .centimeter: return pow(100, scale)
            case .inch: return pow(39.370, scale)
            case .foot: return pow(3.2808399, scale)
            }
        }
        
        func unitStr(isArea: Bool = false) -> String {
            switch self {
            case .meter:
                return isArea ? "m^2" : "m"
            case .centimeter:
                return isArea ? "cm^2" : "cm"
            case .inch:
                return isArea ? "in^2" : "in"
            case .foot:
                return isArea ? "ft^2" : "ft"
            }
        }
    }
    // 初始化
    private let rawValue: Float//初始值
    private let isArea: Bool//是否为面积
    init(meterUnitValue value: Float, isArea: Bool = false) {
        self.rawValue = value
        self.isArea = isArea
    }
    
    // 对测量结果和单位进行组合
    // 3d文字结果标注的格式
    func string(type: Unit) -> String {
        let unit = type.unitStr(isArea: isArea)
        let scale = type.meterScale(isArea: isArea)
        let result = rawValue * scale
        // 单位格式处理
        if  result < 0.1 {
            return String(format: "%.3f", result) +  unit
        } else if result < 1 {
            return String(format: "%.2f", result) +  unit
        } else if  result < 10 {
            return String(format: "%.1f", result) +  unit
        } else {
            return String(format: "%.1f", result) +  unit
        }
    }
    //测量后出现结果结果的字体大小颜色等属性
    func attributeString(type: Unit,
                         valueFont: UIFont = UIFont.boldSystemFont(ofSize: 40),
                         unitFont: UIFont = UIFont.systemFont(ofSize: 20),
                         color: UIColor = UIColor.black) -> NSAttributedString {
        func buildAttributeString(value: String, unit: String) -> NSAttributedString {
            let main = NSMutableAttributedString()
            let v = NSMutableAttributedString(string: value,
                                              attributes: [NSAttributedStringKey.font: valueFont,
                                                           NSAttributedStringKey.foregroundColor: color])
            let u = NSMutableAttributedString(string: unit,
                                              attributes: [NSAttributedStringKey.font: unitFont,
                                                           NSAttributedStringKey.foregroundColor: color])
            main.append(v)
            main.append(u)
            return main
        }
        
        let unit = type.unitStr(isArea: isArea)
        let scale = type.meterScale(isArea: isArea)
        let result = rawValue * scale
        //文本框内的结果格式
        if  result < 0.1 {
            return buildAttributeString(value: String(format: "%.3f", result), unit: unit)
        } else if result < 1 {
            return buildAttributeString(value: String(format: "%.2f", result), unit: unit)
        } else if  result < 10 {
            return buildAttributeString(value: String(format: "%.1f", result), unit: unit)
        } else {
            return buildAttributeString(value: String(format: "%.1f", result), unit: unit)
        }
    }
}
