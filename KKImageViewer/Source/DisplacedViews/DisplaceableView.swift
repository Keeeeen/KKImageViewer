//
//  DisplaceableView.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation
import UIKit

public protocol DisplaceableView {
    
    var image: UIImage? { get }
    var bounds: CGRect { get }
    var center: CGPoint { get }
    var boundsCenter: CGPoint { get }
    var contentMode: UIViewContentMode { get }
    var isHidden: Bool { get set }
    
    func convert(_ point: CGPoint, to view: UIView?) -> CGPoint
}

extension DisplaceableView {
    
    var imageView: UIImageView {
        
        let imageView = UIImageView(image: image)
        imageView.bounds = bounds
        imageView.center = center
        imageView.contentMode = contentMode
        
        return imageView
    }
    
    var frameInCoordinatesOfScreen: CGRect {
        return UIView().convert(bounds, to: UIScreen.main.coordinateSpace)
    }
}
