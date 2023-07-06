//
//  LcarsButton.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-08-04.
//  Copyright © 2017 Sweet Software. All rights reserved.
//

import UIKit

final class LcarsButton: UIButton {
    
    private var corners: UIRectCorner = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let maskPath = UIBezierPath.init(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 10, height: 10)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func setRounded(corners: UIRectCorner) {
        self.corners = corners
    }
}
