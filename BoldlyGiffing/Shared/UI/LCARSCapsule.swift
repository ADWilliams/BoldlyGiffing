//
//  LCARSCapsule.swift
//  BoldyGiffing
//
//  Created by Aaron Williams on 2022-04-12.
//  Copyright © 2022 SweetieApps. All rights reserved.
//

import SwiftUI

struct LCARSCapsule: Shape {
    enum CapsuleType {
        case leftEndCap
        case rightEndCap
        case full
        case none
    }
    
    let type: CapsuleType
    
    init(_ type: CapsuleType = .full) {
        self.type = type
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        var tr: CGFloat = 0
        var tl: CGFloat = 0
        var bl: CGFloat = 0
        var br: CGFloat = 0
        
        switch type {
        case .leftEndCap:
            tl = h / 2
            bl = h / 2
        case .rightEndCap:
            tr = h / 2
            br = h / 2
        case .full:
            tl = h / 2
            bl = h / 2
            tr = h / 2
            br = h / 2
        case .none:
            break
        }
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct LCARSCapsule_Previews: PreviewProvider {
    static var previews: some View {
        LCARSCapsule()
            .fill(.blue)
            .frame(width: 200, height: 300)
            .padding()
    }
}
