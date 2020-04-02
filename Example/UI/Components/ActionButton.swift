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

        layer.cornerRadius = 8
        backgroundColor = .systemBlue
        setTitleColor(.white, for: .normal)
    }
}
