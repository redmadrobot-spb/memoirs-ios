//
//  LogsTextView.swift
//  Example
//
//  Created by Roman Mazeev on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class LogsTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()

        isEditable = false
        contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
}
