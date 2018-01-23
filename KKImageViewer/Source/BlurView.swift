//
//  BlurView.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/23.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation

class BlurView: UIView {
    
    private let option: ImageViewerOption
    
    private let colorView = UIView()
    private let containerView = UIView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    init(option: ImageViewerOption) {
        self.option = option
        
        super.init(frame: .zero)
        
        colorView.alpha = 0
        colorView.backgroundColor = option.overlayColor
        addSubview(colorView)
        
        containerView.alpha = 0
        containerView.addSubview(blurView)
        addSubview(containerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = bounds
        blurView.frame = containerView.bounds
        colorView.frame = bounds
    }
    
    func present() {
        
        UIView
            .animate(
                withDuration: option.blurPresentDuration,
                delay: option.blurPresentDelay,
                options: .curveLinear,
                animations: { [weak self] in
                    
                    guard let weakSelf = self else { return }
                    
                    weakSelf.containerView.alpha = weakSelf.option.overlayBlurOpacity
                },
                completion: nil
        )
        
        UIView
            .animate(
                withDuration: option.colorDismissDuration,
                delay: option.colorDismissDelay,
                options: .curveLinear,
                animations: { [weak self] in
                    self?.colorView.alpha = 0
                },
                completion: nil
        )
    }
    
    func dismiss() {
        
        UIView
            .animate(
                withDuration: option.blurDismissDuration,
                delay: option.blurDismissDelay,
                options: .transitionCurlUp,
                animations: { [weak self] in
                    self?.containerView.alpha = 0
                }, completion: nil
        )
        
        UIView
            .animate(
                withDuration: option.colorDismissDuration,
                delay: option.colorDismissDelay,
                options: .curveLinear,
                animations: { [weak self] in
                    self?.colorView.alpha = 0
                },
                completion: nil
        )
    }
}
