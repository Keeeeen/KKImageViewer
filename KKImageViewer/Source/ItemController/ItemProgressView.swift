//
//  ItemProgressView.swift
//  KKImageViewer
//
//  Created by Yuma Matsune on 2018/06/07.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

open class ItemProgressView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func setProgress(value: Float) {}
}
