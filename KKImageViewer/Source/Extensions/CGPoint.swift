//
//  CGPoint.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

enum Direction {
    
    case left, right, up, down, none
}

enum Orientation {
    
    case vertical, horizontal, none
}

extension CGPoint {
    
    func inverted() -> CGPoint {
        
        return CGPoint(x: y, y: x)
    }
    
    var direction: Direction {
        
        if x == 0 && y == 0 { return .none }
        
        if (abs(self.x) > abs(self.y) && self.x > 0) {
            return .right
        } else if (abs(self.x) > abs(self.y) && self.x <= 0) {
            return .left
        } else if (abs(self.x) <= abs(self.y) && self.y > 0) {
            return .up
        } else if (abs(self.x) <= abs(self.y) && self.y <= 0) {
            return .down
        } else {
            return .none
        }
    }
    
    var orientation: Orientation {
        
        if direction == .none {
            return .none
        } else if direction == .left || direction == .right {
            return .horizontal
        } else {
            return .vertical
        }
    }
}
