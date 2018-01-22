//
//  SwipeToDismissTransition.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/22.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

enum SwipeDirection {
    case horizontal
    case vertical
}

final class SwipeToDismissTransition {
    
    private weak var scrollView: UIScrollView?
    
    init(scrollView: UIScrollView?) {
        self.scrollView = scrollView
    }
    
    func didChangeInteractiveTransition(horizontalOffset: CGFloat = 0, verticalOffset: CGFloat = 0) {
        let newPoint = CGPoint(x: horizontalOffset, y: verticalOffset)
        scrollView?.setContentOffset(newPoint, animated: false)
    }
    
    
    func didFinishInteractiveTransition(with swipeDirection: SwipeDirection,
                                        touchPoint: CGFloat,
                                        targetOffset: CGFloat,
                                        escapeVelocity: CGFloat,
                                        completion: (() -> Void)?) {
        
        let springVelocity = fabs(escapeVelocity / (targetOffset - touchPoint))
        let expectedDirection = TimeInterval(fabs(targetOffset - touchPoint) / fabs(escapeVelocity))
        
        UIView
            .animate(
                withDuration: expectedDirection * 0.65,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: springVelocity,
                options: .curveLinear,
                animations: { [weak self] in
                    
                    let newPoint: CGPoint
                    
                    switch swipeDirection {
                    case .horizontal:
                        newPoint = CGPoint(x: targetOffset, y: 0)
                    case .vertical:
                        newPoint = CGPoint(x: 0, y: targetOffset)
                    }
                    
                    self?.scrollView?.setContentOffset(newPoint, animated: false)
                },
                completion: { _ in
                    completion?()
            }
        )
    }
    
    func cancelInteractiveTransition(_ completion: (() -> Void)? = {}) {
        UIView
            .animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveLinear,
                animations: { [weak self] in
                    self?.scrollView?.setContentOffset(.zero, animated: false)
                },
                completion: { _ in
                    completion?()
            }
        )
    }
}
