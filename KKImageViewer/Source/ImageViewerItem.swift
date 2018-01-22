//
//  ImageViewerItem.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/23.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

public typealias ImageCompletion = (UIImage?) -> Void
public typealias FetchImageBlock = (@escaping ImageCompletion) -> Void

public enum ImageViewerItem {
    case image(fetchImageBlock: FetchImageBlock)
}
