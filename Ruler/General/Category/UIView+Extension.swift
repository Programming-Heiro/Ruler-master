//
//  UIView+Constraint.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import UIKit

enum InsideLayout {
    static let `default`: [InsideLayout] = [.top, .bottom, .left, .right]
    case top
    case bottom
    case left
    case right
}

public protocol Then {}
extension Then where Self: AnyObject {
    public func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}

//extension UIView {
//    func layoutInside(view: UIView, inset: UIEdgeInsets, options: [InsideLayout] = InsideLayout.default) {
//        if options.contains(.top) {
//            self.topAnchor.constraintEqualToSystemSpacingBelow(view.topAnchor, multiplier: inset.top)
//        }
//        if options.contains(.bottom) {
//            self.bottomAnchor.constraintEqualToSystemSpacingBelow(view.bottomAnchor, multiplier: inset.bottom)
//        }
//        if options.contains(.left) {
//            self.leftAnchor.constraintEqualToSystemSpacingAfter(view.leftAnchor, multiplier: inset.left)
//        }
//        if options.contains(.right) {
//            self.rightAnchor.constraintEqualToSystemSpacingAfter(view.rightAnchor, multiplier: inset.right)
//        }
//    }
//}
