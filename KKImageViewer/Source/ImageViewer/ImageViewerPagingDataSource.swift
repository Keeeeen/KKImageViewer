//
//  ImageViewerPagingDataSource.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/23.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation
import UIKit

final class ImageViewerPagingDataSource: NSObject, UIPageViewControllerDataSource {
    
    weak var itemControllerDelegate: ItemControllerDelegate?
    private weak var imageViewerDataSource: ImageViewerDataSource?
    private weak var displacedViewsDataSource: DisplacedViewsDataSource?
    
    private let option: ImageViewerOption
    private var numberOfItems: Int {
        return imageViewerDataSource?.numberOfItems() ?? 0
    }
    
    init(imageViewerDataSource: ImageViewerDataSource, displacedViewsDataSource: DisplacedViewsDataSource?, option: ImageViewerOption) {
        
        self.imageViewerDataSource = imageViewerDataSource
        self.displacedViewsDataSource = displacedViewsDataSource
        self.option = option
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = viewController as? ItemController else {
            return nil
        }
        
        let previousIndex: Int
        
        if currentViewController.index == 0 {
            previousIndex = numberOfItems - 1
        } else {
            previousIndex = currentViewController.index - 1
        }
        
        if currentViewController.index > 0 {
            return createItemController(at: previousIndex)
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = viewController as? ItemController else {
            return nil
        }
        
        let nextIndex: Int
        
        if currentViewController.index == numberOfItems - 1 {
            nextIndex = 0
        } else {
            nextIndex = currentViewController.index + 1
        }
        
        if currentViewController.index < numberOfItems - 1 {
            return createItemController(at: nextIndex)
        } else {
            return nil
        }
    }
    
    func createItemController(at index: Int, isInitial: Bool = false) -> UIViewController {
        
        guard let item = imageViewerDataSource?.providedImageViewerItem(at: index) else {
            return UIViewController()
        }
        
        switch item {
        case .image(let fetchImageBlock):
            let imageViewController = ImageViewController(numberOfItems: numberOfItems,
                                                          startIndex: index,
                                                          fetchImageBlock: fetchImageBlock,
                                                          option: option,
                                                          isInitialController: isInitial)
            imageViewController.delegate = itemControllerDelegate
            imageViewController.displacedViewsDataSource = displacedViewsDataSource
            imageViewController.progressView = imageViewerDataSource?.progressView()
            return imageViewController
        }
    }
}
