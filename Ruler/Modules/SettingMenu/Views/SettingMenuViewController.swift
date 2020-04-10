//
//  SettingViewController.swift
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//

import UIKit
//MARK： - 设置菜单
class SettingMenuViewController: UIViewController {
    
    
    @IBOutlet weak var unitSegment: UISegmentedControl!
    @IBOutlet weak var displaySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unitSegment.selectedSegmentIndex = MeasurementUnit.Unit.all.index(of: ApplicationSetting.Status.CurrentUnit)!
        displaySwitch.isOn = ApplicationSetting.Status.displayFocus
        displaySwitch.onTintColor = UIColor(red:0.996, green:0.835, blue:0.380, alpha:1.000)
    }
    
    
    @IBAction func lengthUnitDidChange(_ sender: UISegmentedControl) {
        ApplicationSetting.Status.CurrentUnit = MeasurementUnit.Unit.all[sender.selectedSegmentIndex]
    }
    
    @IBAction func closeButtonDidClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func planeFocusDidChange(_ sender: UISwitch) {
        ApplicationSetting.Status.displayFocus = sender.isOn
    }
    
}
