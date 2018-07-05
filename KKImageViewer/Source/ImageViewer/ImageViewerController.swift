//
//  ImageViewerController.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/23.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import UIKit

open class ImageViewerController: UIPageViewController, ItemControllerDelegate {
    
    private let option: ImageViewerOption
    private let pagingDataSource: ImageViewerPagingDataSource
    private let itemDataSource: ImageViewerDataSource?
    private let displacedViewsDataSource: DisplacedViewsDataSource?
    
    private weak var initialItemController: ItemController?
    
    private lazy var overlayView = BlurView(option: option)
    
    private var headerViewHidden = false
    private var footerViewHidden = false
    private var isAnimating = false
    private var initialPresentationDone = false
    
    open var headerView: UIView?
    open var footerView: UIView?
    open var headerViewHeight: CGFloat = 0
    open var footerViewHeight: CGFloat = 0
    
    public var currentIndex: Int
    
    public weak var imageViewerControllerDelegate: ImageViewerControllerDelegate?
    
    // MAKR: - Initialize
    
    public init(
        startIndex: Int,
        itemDataSource: ImageViewerDataSource,
        displacedViewsDataSource: DisplacedViewsDataSource? = nil,
        option: ImageViewerOption
        )
    {
        self.currentIndex = startIndex
        self.itemDataSource = itemDataSource
        self.displacedViewsDataSource = displacedViewsDataSource
        self.option = option
        
        pagingDataSource = ImageViewerPagingDataSource(
            imageViewerDataSource: itemDataSource,
            displacedViewsDataSource: displacedViewsDataSource,
            option: option
        )
        
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [
                UIPageViewControllerOptionInterPageSpacingKey:
                    NSNumber(value: Float(option.imageDividerWidth))
            ]
        )
        
        pagingDataSource.itemControllerDelegate = self
        
        let inittialController = pagingDataSource
            .createItemController(at: startIndex, isInitial: true)
        
        setViewControllers([inittialController],
                           direction: .forward,
                           animated: false,
                           completion: nil)
        
        if let controller = inittialController as? ItemController {
            initialItemController = controller
        }
        
        modalPresentationStyle = .overFullScreen
        dataSource = pagingDataSource
        
        UIApplication.window.windowLevel = option.statusBarHidden
            ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ImageViewerController.rotate),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        configureHeaderView()
        configureFooterView()
        view.setNeedsUpdateConstraints()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if option.rotationMode == .always && UIApplication.isPortraitOnly {
            view.transform = windowRotationTransform()
            view.bounds = rotationAdjustedBounds()
        }
        
        overlayView.frame = view.bounds.insetBy(dx: -UIScreen.main.bounds.width * 2,
                                                dy: -UIScreen.main.bounds.height * 2)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialPresentationDone { return }
        
        configureOverlayView()
        presentFirst()
        
        initialPresentationDone = true
    }
    
    override open func updateViewConstraints() {
        
        if #available(iOS 11.0, *) {
            
            if option.statusBarHidden, let superView = view.superview {
                headerView?.topAnchor
                    .constraint(equalTo: superView.topAnchor)
                    .isActive = true
            } else {
                headerView?.topAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
                    .isActive = true
            }
            
            headerView?.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
                .isActive = true
            
            headerView?.rightAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
                .isActive = true
            
        } else {
            
            if option.statusBarHidden, let superView = view.superview {
                headerView?.topAnchor
                    .constraint(equalTo: superView.topAnchor)
                    .isActive = true
            } else {
                headerView?.topAnchor
                    .constraint(equalTo: view.topAnchor)
                    .isActive = true
            }
            
            headerView?.leadingAnchor
                .constraint(equalTo: view.leadingAnchor)
                .isActive = true
            
            headerView?.rightAnchor
                .constraint(equalTo: view.rightAnchor)
                .isActive = true
        }
        
        headerView?.heightAnchor
            .constraint(equalToConstant: headerViewHeight)
            .isActive = true
        
        footerView?.heightAnchor
            .constraint(equalToConstant: footerViewHeight)
            .isActive = true
        
        footerView?.bottomAnchor
            .constraint(equalTo: view.bottomAnchor)
            .isActive = true
        
        footerView?.leadingAnchor
            .constraint(equalTo: view.leadingAnchor)
            .isActive = true
        
        footerView?.rightAnchor
            .constraint(equalTo: view.rightAnchor)
            .isActive = true
        
        super.updateViewConstraints()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Local Methods
    
    private func presentFirst() {
        
        isAnimating = true
        
        initialItemController?
            .presentItem(
                animations: { [weak self] in
                    self?.overlayView.present()
                },
                completion: { [weak self] in
                    guard let weakSelf = self else { return }
                    
                    if !weakSelf.headerViewHidden {
                        self?.animateHeaderView(visibale: true)
                    }
                    
                    if !weakSelf.footerViewHidden {
                        self?.animateFooterView(visibale: true)
                    }
                    
                    weakSelf.isAnimating = false
                    weakSelf.imageViewerControllerDelegate?.imageViewerDidLaunch(weakSelf)
            }
        )
    }
    
    private func animateHeaderView(visibale: Bool) {
        
        let targetAlpha: CGFloat = visibale ? 1 : 0
        
        UIView
            .animate(
                withDuration: option.headerviewFadeDuration,
                animations: { [weak self] in
                    self?.headerView?.alpha = targetAlpha
                    self?.headerView?.subviews.forEach { $0.alpha = targetAlpha }
                },
                completion: nil
        )
    }
    
    private func animateFooterView(visibale: Bool) {
        
        let targetAlpha: CGFloat = visibale ? 1 : 0
        
        UIView
            .animate(
                withDuration: option.footerviewFadeDuration,
                animations: { [weak self] in
                    self?.footerView?.alpha = targetAlpha
                    self?.footerView?.subviews.forEach { $0.alpha = targetAlpha }
                },
                completion: nil
        )
    }
    
    private func closeDecorationViews(_ completion: (() -> Void)?) {
        if isAnimating { return }
        isAnimating = true
        
        UIView
            .animate(
                withDuration: option.decorationViewsCloseDuration,
                animations: { [weak self] in
                    self?.headerView?.alpha = 0.0
                    self?.footerView?.alpha = 0.0
                },
                completion: { [weak self] _ in
                    guard let weakSelf = self else { return }
                    
                    let itemController = weakSelf.viewControllers?.first as? ItemController
                    
                    itemController?.dismissItem(
                        animations: {
                            weakSelf.overlayView.dismiss()
                        },
                        completion: {
                            weakSelf.isAnimating = true
                            
                            weakSelf.dissmissImageViewer(false) {
                                weakSelf.imageViewerControllerDelegate?.imageViewerDidClosed(weakSelf)
                            }
                    })
                }
        )
    }
    
    private func dissmissImageViewer(_ animated: Bool, completion: (() -> Void)?) {
        
        overlayView.removeFromSuperview()
        modalTransitionStyle = .crossDissolve
        
        dismiss(animated: animated) {
            UIApplication.window.windowLevel = UIWindowLevelNormal
            completion?()
        }
    }
    
    // MARK: Configuration
    
    private func configureOverlayView() {
        
        let halfWidth = UIScreen.main.bounds.width / 2
        let halfHeight = UIScreen.main.bounds.height / 2
        
        overlayView.bounds.size = UIScreen.main.bounds
            .insetBy(dx: -halfWidth,
                     dy: -halfHeight)
            .size

        overlayView.center = CGPoint(x: halfWidth, y: halfHeight)
        
        view.addSubview(overlayView)
        view.sendSubview(toBack: overlayView)
    }
    
    private func configureHeaderView() {
        guard let headerView = headerView else { return }
       
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.alpha = 0
        view.addSubview(headerView)
    }
    
    private func configureFooterView() {
        guard let footerView = footerView else { return }
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.alpha = 0
        view.addSubview(footerView)
    }
    
    // MARK: Open Methods
    
    open func close(completion: (() -> Void)?) {
        closeDecorationViews(completion)
    }
    
    // MARK: Selectors
    
    @objc
    func rotate() {
        if !UIApplication.isPortraitOnly { return }
        
        if UIDevice.current.orientation.isFlat && isAnimating {
            return
        }
        
        isAnimating = true
        
        UIView
            .animate(
                withDuration: option.rotationDuration,
                delay: 0,
                options: .curveLinear,
                animations: { [weak self] in
                    self?.view.transform = windowRotationTransform()
                    self?.view.bounds = rotationAdjustedBounds()
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                },
                completion: { [weak self] _ in
                    self?.isAnimating = false
                }
        )
    }
    
    // MARK: - ItemControllerDelegate
    
    open func itemController(_ controller: ItemController, didSwipeToDismissWithRatio ratio: CGFloat) {
        
        let alpha = 1 - ratio * 6
        
        if !headerViewHidden {
            headerView?.alpha = alpha
        }
        
        if !footerViewHidden {
            footerView?.alpha = alpha
        }
        
        overlayView.blurView.alpha = 1 - ratio
        overlayView.colorView.alpha = 1 - ratio
    }
    
    open func itemControllerDidFinishSwipeToDismiss() {
        imageViewerControllerDelegate?.imageViewerDidSwipedToDismiss(self)
        overlayView.removeFromSuperview()
        dismiss(animated: false, completion: nil)
    }
    
    open func itemControllerDidSingleTap(_ controller: ItemController) {
        headerViewHidden = !headerViewHidden
        footerViewHidden = !footerViewHidden
        
        animateHeaderView(visibale: !headerViewHidden)
        animateFooterView(visibale: !footerViewHidden)
    }
    
    open func itemControllerDidLongPress(_ controller: ItemController, in item: ItemView) {
        
        if controller is ImageViewController && item is UIImageView {
            guard let image = item.image else { return }
            
            let activityViewController = UIActivityViewController(activityItems: [image],
                                                                  applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    open func itemControllerWillAppear(_ controller: ItemController) {
        
    }
    
    open func itemControllerWillDisappear(_ controller: ItemController) {
        
    }
    
    open func itemControllerDidAppear(_ controller: ItemController) {
        currentIndex = controller.index
        headerView?.sizeToFit()
        footerView?.sizeToFit()
        imageViewerControllerDelegate?.imageViewerDidLandedPage(self, at: currentIndex)
    }
}
