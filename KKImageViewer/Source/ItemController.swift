//
//  ItemController.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

public protocol ItemController: class {
    
    var index: Int { get }
    
    var isInitialController: Bool { get }
    
    weak var delegate: ItemControllerDelegate? { get set }
    weak var displacedViewsDataSource: DisplacedViewsDataSource? { get set }

    func fetchImage()

    func presentItem(animations: () -> Void, completion: @escaping () -> Void)
    func dismissItem(animations: () -> Void, completion: @escaping () -> Void)
}
