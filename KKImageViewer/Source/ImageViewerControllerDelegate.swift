//
//  ImageViewerControllerDelegate.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/23.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

public protocol ImageViewerControllerDelegate: class {
    
    func imageViewerDidLaunch(_ imageViewerContrller: ImageViewerController)
    func imageViewerDidLandedPage(_ imageViewerContrller: ImageViewerController, at index: Int)
    func imageViewerDidClosed(_ imageViewerContrller: ImageViewerController)
    func imageViewerDidSwipedToDismiss(_ imageViewerContrller: ImageViewerController)
    
}
