//
//  ImageViewerDataSource.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/23.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

public protocol ImageViewerDataSource: class {
    func numberOfItems() -> Int
    func providedImageViewerItem(at index: Int) -> ImageViewerItem
    func progressView() -> ItemProgressView?
    func providedImageViewerThumbnail(at index: Int) -> UIImage?
}

public extension ImageViewerDataSource {
    func progressView() -> ItemProgressView? {
        return nil
    }
    
    func providedImageViewerThumbnail(at index: Int) -> UIImage? {
        return nil
    }
}
