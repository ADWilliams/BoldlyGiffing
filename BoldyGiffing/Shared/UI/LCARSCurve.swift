//
//  LCARSCurve.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-04-19.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI
import ShapeUp

struct LCARSCurve: CornerShape {
    var closed = true
    var insetAmount: CGFloat = .zero
    
    var columnWidth: CGFloat

    func corners(in rect: CGRect) -> [Corner] {
        let curveX = min( columnWidth, 200)
        let curveY = min( rect.midY / 2, 100)
        return [
            Corner(.rounded(radius: .relative(0.5)),x: rect.minX, y: rect.minY),
            Corner(x: rect.maxX, y: rect.minY),
            Corner(x: rect.maxX, y: curveY),
            Corner(.rounded(radius: .relative(0.4)),x: curveX, y: curveY ),
            Corner(x: curveX, y: rect.maxY),
            Corner(x: rect.minX, y: rect.maxY)
        ]
    }
}

struct LCARSCurve_Previews: PreviewProvider {
    static var previews: some View {
        LCARSCurve(columnWidth: 40)
            .padding()
            .frame(height: 80)
    }
}
