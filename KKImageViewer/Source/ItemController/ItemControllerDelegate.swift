//
//  ItemControllerDelegate.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

public protocol ItemControllerDelegate: class {
    
    ///Represents a generic transitioning progress from 0 to 1 (or reversed) where 0 is no progress and 1 is fully finished transitioning. It's up to the implementing controller to make decisions about how this value is being calculated, based on the nature of transition.
    func itemController(_ controller: ItemController, didSwipeToDismissWithRatio ratio: CGFloat)
    
    func itemControllerDidFinishSwipeToDismiss()
    
    func itemControllerDidSingleTap(_ controller: ItemController)
    func itemControllerDidLongPress(_ controller: ItemController, in item: ItemView)
    
    func itemControllerWillAppear(_ controller: ItemController)
    func itemControllerWillDisappear(_ controller: ItemController)
    func itemControllerDidAppear(_ controller: ItemController)
    
}
