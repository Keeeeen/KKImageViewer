//
//  UIApplication.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

extension UIApplication {
    
    static var window: UIWindow {
        return (UIApplication.shared.delegate?.window?.flatMap { $0 })!
    }
    
    static var isPortraitOnly: Bool {
        
        let orientations = UIApplication.shared.supportedInterfaceOrientations(for: nil)
        
        return !(orientations.contains(.landscapeLeft)
            || orientations.contains(.landscapeRight)
            || orientations.contains(.landscape)
        )
    }
}
