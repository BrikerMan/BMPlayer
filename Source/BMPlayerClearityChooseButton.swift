//
//  File.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import UIKit

class BMPlayerClearityChooseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    func initUI() {
        self.titleLabel?.font   = UIFont.systemFont(ofSize: 12)
        self.layer.cornerRadius = 2
        self.layer.borderWidth  = 1
        self.layer.borderColor  = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8 ).cgColor
        self.setTitleColor(UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9 ), for: .normal)
    }
}
