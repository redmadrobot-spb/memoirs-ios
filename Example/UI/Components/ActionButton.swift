//
//  ActionButton.swift
//  Example
//
//  Created by Roman Mazeev on 27.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 8
        self.backgroundColor = .systemBlue
        self.setTitleColor(.white, for: .normal)
    }
}
