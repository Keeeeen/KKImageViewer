//
//  ItemBaseViewController.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import UIKit

open class ItemBaseViewController<T: UIView>: UIViewController, ItemController, UIScrollViewDelegate, UIGestureRecognizerDelegate where T: ItemView {
    
    // MARK: ItemController Properties
    public let index: Int
    public let isInitialController: Bool
    
    public let numberOfItems: Int
    private let fetchImageBlock: FetchImageBlock
    private let option: ImageViewerOption
    private let displacementSpringBounce: CGFloat
    private let minimumZoomScale: CGFloat = 1
    
    let itemView = T()
    private var isAnimating = false
    private var swipeDirection: SwipeDirection?
    private var swipeToDismissTransition: SwipeToDismissTransition?
    
    private lazy var scrollView: UIScrollView = self.createScrollView()
    private lazy var doubleTapRecognizer: UITapGestureRecognizer = self.createDoubleTapRecognizer()
    private lazy var singleTapRecognizer: UITapGestureRecognizer = self.createSingleTapRecognizer()
    private lazy var longPressRecognizer: UILongPressGestureRecognizer? = self.createLongPressRecognizer()
    private lazy var swipeToDismissRecognizer: UIPanGestureRecognizer? = self.createSwipeToDismissRecognizer()
    private lazy var activityIndicatorView: UIActivityIndicatorView = self.createActivityIndicatorView()
    
    public weak var delegate: ItemControllerDelegate?
    public weak var displacedViewsDataSource: DisplacedViewsDataSource?
    public var progressView: ItemProgressView?
    
    // MARK: Initialize
    
    init(
        numberOfItems: Int,
        startIndex: Int,
        fetchImageBlock: @escaping FetchImageBlock,
        option: ImageViewerOption,
        isInitialController: Bool = false
        )
    {
        self.index = startIndex
        self.numberOfItems = numberOfItems
        self.isInitialController = isInitialController
        self.fetchImageBlock = fetchImageBlock
        self.option = option
        
        switch option.displacementTransitionStyle {
        case .normal:
            self.displacementSpringBounce = 1
        case .springBounce(let bounce):
            self.displacementSpringBounce = bounce
        }
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        
        itemView.isHidden = isInitialController
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    public func setProgress(value: Float) {
        progressView?.setProgress(value: value)
    }
    
    // MARK: LifeCycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        view.addSubview(activityIndicatorView)
        if let p = progressView {
            view.addSubview(p)
        }
        
        if let swipeToDismissRecognizer = swipeToDismissRecognizer {
            view.addGestureRecognizer(swipeToDismissRecognizer)
        }
        
        fetchImage()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.itemControllerWillAppear(self)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        activityIndicatorView.center = view.boundsCenter
        
        if let size = itemView.image?.size , size != .zero {
            
            let aspectFitItemSize = aspectFitSize(forContentOfSize: size,
                                                  inBounds: scrollView.bounds.size)
            
            itemView.bounds.size = aspectFitItemSize
            scrollView.contentSize = itemView.bounds.size
            
            itemView.center = scrollView.boundsCenter
        }
        
        progressView?.center = view.boundsCenter
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delegate?.itemControllerDidAppear(self)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.itemControllerWillDisappear(self)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Create Local Properties
    
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.contentInset = .zero
        scrollView.contentOffset = .zero
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = max(option.maximumZoomScale,
                                          aspectFillZoomScale(forBoundingSize: view.bounds.size,
                                                              contentSize: itemView.bounds.size))
        scrollView.delegate = self
        scrollView.addSubview(itemView)
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        scrollView.addGestureRecognizer(singleTapRecognizer)
        if let longPressRecognizer = longPressRecognizer {
            scrollView.addGestureRecognizer(longPressRecognizer)
        }
        return scrollView
    }
    
    private func createDoubleTapRecognizer() -> UITapGestureRecognizer {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(scrollViewDidDoubleTap(_:)))
        return recognizer
    }
    
    private func createSingleTapRecognizer() -> UITapGestureRecognizer {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(scrollViewDidSingleTap))
        recognizer.require(toFail: doubleTapRecognizer)
        return recognizer
    }
    
    private func createLongPressRecognizer() -> UILongPressGestureRecognizer? {
        if !option.activityViewByLongPress { return nil }
        
        let recognizer = UILongPressGestureRecognizer()
        recognizer.addTarget(self, action: #selector(scrollViewDidLongPress))
        return recognizer
    }
    
    private func createSwipeToDismissRecognizer() -> UIPanGestureRecognizer? {
        if option.swipeToDismissMode == .never { return nil }
        
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(scrollViewDidSwipeToDismiss(_:)))
        recognizer.require(toFail: doubleTapRecognizer)
        recognizer.delegate = self
        return recognizer
    }
    
    private func createActivityIndicatorView() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.color = option.activityIndecatorColor
        indicator.activityIndicatorViewStyle = option.activityIndicatorStyle
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }
    
    // MARK: - Swipe To Dimiss Methods
    
    func handleSwipeToDismissInProgress(_ swipeDirection: SwipeDirection, for touchPoint: CGPoint) {
        
        switch (swipeDirection, index) {
        case (.horizontal, 0) where numberOfItems != 1:
            /// edge case horizontal first index - limits the swipe to dismiss to HORIZONTAL RIGHT direction.
            swipeToDismissTransition?
                .didChangeInteractiveTransition(horizontalOffset: min(0, -touchPoint.x))
            
        case (.horizontal, numberOfItems - 1) where numberOfItems != 1:
            
            /// edge case horizontal last index - limits the swipe to dismiss to HORIZONTAL LEFT direction.
            swipeToDismissTransition?
                .didChangeInteractiveTransition(horizontalOffset: max(0, -touchPoint.x))
            
        case (.horizontal, _):
            
            swipeToDismissTransition?
                .didChangeInteractiveTransition(horizontalOffset: -touchPoint.x)
            
        case (.vertical, _):
            
            swipeToDismissTransition?
                .didChangeInteractiveTransition(verticalOffset: -touchPoint.y)
        }
    }
    
    func handleSwipeToDimissEnded(_ swipeDirection: SwipeDirection, velocity: CGPoint, touchPoint: CGPoint) {
        
        let thresholdVelocity = option.swipeToDismissThresholdVelocity
        let swipeToDimissCompletionBlock = { [weak self] in
            
            UIApplication.window.windowLevel = UIWindowLevelNormal
            self?.swipeDirection = nil
            self?.delegate?.itemControllerDidFinishSwipeToDismiss()
        }
        
        switch (swipeDirection, index) {
        case (.vertical, _) where velocity.y < -thresholdVelocity:
            
            swipeToDismissTransition?
                .didFinishInteractiveTransition(
                    with: swipeDirection,
                    touchPoint: touchPoint.y,
                    targetOffset: view.bounds.height / 2 + itemView.bounds.height / 2,
                    escapeVelocity: velocity.y,
                    completion: swipeToDimissCompletionBlock
            )
            
        case (.vertical, _) where thresholdVelocity < velocity.y:
        
            swipeToDismissTransition?
                .didFinishInteractiveTransition(
                    with: swipeDirection,
                    touchPoint: touchPoint.y,
                    targetOffset: -(view.bounds.height / 2) - itemView.bounds.height / 2,
                    escapeVelocity: velocity.y,
                    completion: swipeToDimissCompletionBlock
            )
            
        case (.horizontal, 0) where thresholdVelocity < velocity.x:
            
            swipeToDismissTransition?
                .didFinishInteractiveTransition(
                    with: swipeDirection,
                    touchPoint: touchPoint.x,
                    targetOffset: -(view.bounds.width / 2) - itemView.bounds.width / 2,
                    escapeVelocity: velocity.x,
                    completion: swipeToDimissCompletionBlock
            )
            
        case (.horizontal, numberOfItems - 1) where velocity.x < -thresholdVelocity:
            
            swipeToDismissTransition?
                .didFinishInteractiveTransition(
                    with: swipeDirection,
                    touchPoint: touchPoint.x,
                    targetOffset: view.bounds.width / 2 + itemView.bounds.width / 2,
                    escapeVelocity: velocity.x,
                    completion: swipeToDimissCompletionBlock
            )
            
        default:
            
            swipeToDismissTransition?
                .cancelInteractiveTransition { [weak self] in
                    self?.swipeDirection = nil
            }
        }
    }
    
    // MARK: - Internal Methods
    
    func displacementTargetSize(for size: CGSize) -> CGSize {
        
        let boundingSize = rotationAdjustedBounds().size
        
        return aspectFitSize(forContentOfSize: size, inBounds: boundingSize)
    }
    
    func findVisibleDisplacedView() -> DisplaceableView? {
        
        guard let displacedView = displacedViewsDataSource?.provideDisplacementItem(at: index) else { return nil }
        
        let displacedViewFrame = displacedView.frameInCoordinatesOfScreen
        let validAreaFrame = self.view.frame.insetBy(dx: option.displacementInsetMargin,
                                                     dy: option.displacementInsetMargin)
        let isVisibleEnough = displacedViewFrame.intersects(validAreaFrame)
        
        return isVisibleEnough ? displacedView : nil
    }
    
    // MARK: - ItemController functions
    
    public func fetchImage() {
        fetchImageBlock { [weak self] image in
            guard let image = image else { return }
            
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                
                var itemView = self?.itemView
                itemView?.image = image
                itemView?.isAccessibilityElement = image.isAccessibilityElement
                itemView?.accessibilityLabel = image.accessibilityLabel
                itemView?.accessibilityTraits = image.accessibilityTraits
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    public func presentItem(animations: () -> Void, completion: @escaping () -> Void) {
        if isAnimating { return }
        isAnimating = true
        
        animations()
        
        if var displacedView = displacedViewsDataSource?.provideDisplacementItem(at: index),
            let image = displacedView.image {
            
            let animatedImageView = displacedView.imageView
            
            if UIApplication.isPortraitOnly {
                animatedImageView.transform = deviceRotationTransform()
            }
            
            animatedImageView.center = displacedView.convert(displacedView.boundsCenter, to: view)
            animatedImageView.clipsToBounds = true
            
            view.addSubview(animatedImageView)
            
            displacedView.isHidden = !option.displacementKeepOriginalInPlace
            
            UIView
                .animate(
                    withDuration: option.displacementDuration,
                    delay: 0,
                    usingSpringWithDamping: displacementSpringBounce,
                    initialSpringVelocity: 1,
                    options: .curveEaseIn,
                    animations: { [weak self] in
                        
                        if UIApplication.isPortraitOnly {
                            animatedImageView.transform = .identity
                        }
                        
                        animatedImageView.bounds.size = self?.displacementTargetSize(for: image.size) ?? image.size
                        animatedImageView.center = self?.view.boundsCenter ?? .zero
                
                    },
                    completion: { [weak self] _ in
                        var itemView = self?.itemView
                        itemView?.image = image
                        itemView?.isHidden = false
                        displacedView.isHidden = false
                        animatedImageView.removeFromSuperview()
                        
                        self?.isAnimating = false
                        completion()
                    }
            )
            
        } else {
            
            itemView.alpha = 0
            itemView.isHidden = false
            
            UIView
                .animate(
                    withDuration: option.itemFadeDuration,
                    animations: { [weak self] in
                        self?.itemView.alpha = 1.0
                    },
                    completion: { [weak self] _ in
                        completion()
                        self?.isAnimating = false
                }
            )
        }
        
    }
    
    public func dismissItem(animations: () -> Void, completion: @escaping () -> Void) {
        if isAnimating { return }
        isAnimating = true
        
        animations()
        
        if var displacedView = findVisibleDisplacedView() {
            displacedView.isHidden = !option.displacementKeepOriginalInPlace
            
            UIView
                .animate(
                    withDuration: option.reverseDisplacementDuration,
                    animations: { [weak self] in
                        guard let weakSelf = self else { return }
                        
                        weakSelf.scrollView.zoomScale = weakSelf.minimumZoomScale
                        
                        if UIApplication.isPortraitOnly {
                            displacedView.isHidden = true
                        }
                        
                        weakSelf.itemView.bounds = displacedView.bounds
                        weakSelf.itemView.center = displacedView.convert(displacedView.boundsCenter, to: weakSelf.view)
                        weakSelf.itemView.clipsToBounds = true
                        weakSelf.itemView.contentMode = displacedView.contentMode
                    },
                    completion:  { [weak self] _ in
                        self?.isAnimating = false
                        displacedView.isHidden = false
                        
                        completion()
                    }
            )
        } else {
            UIView
                .animate(
                    withDuration: option.itemFadeDuration,
                    animations: {  [weak self] in
                        self?.itemView.alpha = 0
                    },
                    completion: { [weak self] _ in
                    self?.isAnimating = false
                    completion()
                }
            )
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        itemView.center = contentCenter(forBoundingSize: scrollView.bounds.size,
                                        contentSize: scrollView.contentSize)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return itemView
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let swipeGestureRecognizer = swipeToDismissRecognizer else { return false }
        
        let velocity = swipeGestureRecognizer.velocity(in: swipeGestureRecognizer.view)
        
        if velocity.orientation == .none {
            return false
        } else if velocity.orientation != .horizontal {
            return option.swipeToDismissMode == .vertical
        } else if (index == 0 && velocity.direction == .right)
            || (index == numberOfItems - 1 && velocity.direction == .left) {
            return swipeDirection == .horizontal
        }
        
        return false
    }
    
    // MARK: - NSKeyValueObserving
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let swipeDirection = swipeDirection, keyPath == "contentOffset" else { return }
        
        let distance: CGFloat
        let ratio: CGFloat
        
        switch swipeDirection {
        case .horizontal:
            distance = scrollView.bounds.width / 2 + itemView.bounds.width / 2
            ratio = fabs(scrollView.contentOffset.x / distance)
        case .vertical:
            distance = scrollView.bounds.height / 2 + itemView.bounds.height / 2
            ratio = fabs(scrollView.contentOffset.y / distance)
        }
        
        delegate?.itemController(self, didSwipeToDismissWithRatio: ratio)
    }
    
    // MARK: - Selectors
    
    @objc
    func scrollViewDidDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(ofTouch: 0, in: itemView)
        
        if touchPoint.y < 0 || touchPoint.y > itemView.frame.height {
            // when tap on the outside of the itemView
            return
        }
        
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: scrollView.bounds.size, contentSize: itemView.bounds.size)
        
        if scrollView.zoomScale == 1.0 && scrollView.zoomScale < aspectFillScale {
            
            let zoomRectangle = zoomRect(ForScrollView: scrollView,
                                         scale: aspectFillScale,
                                         center: touchPoint)
            
            UIView
                .animate(
                    withDuration: option.doubleTapToZoomDuration,
                    animations: { [weak self] in
                        self?.scrollView.zoom(to: zoomRectangle, animated: false)
                    },
                    completion: nil
            )
        } else  {
            UIView
                .animate(
                    withDuration: option.doubleTapToZoomDuration,
                    animations: { [weak self] in
                        self?.scrollView.setZoomScale(1.0, animated: false)
                    },
                    completion: nil
            )
        }
    }
    
    @objc
    func scrollViewDidSingleTap() {
        delegate?.itemControllerDidSingleTap(self)
    }
    
    @objc
    func scrollViewDidLongPress() {
        delegate?.itemControllerDidLongPress(self, in: itemView)
    }
    
    @objc
    func scrollViewDidSwipeToDismiss(_ recognizer: UIPanGestureRecognizer) {
        if scrollView.zoomScale != scrollView.minimumZoomScale { return }
        
        let velocity = recognizer.velocity(in: view)
        let touchPoint = recognizer.translation(in: view)
        
        if swipeDirection == nil {
            swipeDirection = fabs(velocity.x) > fabs(velocity.y) ? .horizontal : .vertical
        }
        
        guard let swipingDirection = swipeDirection else { return }
        
        switch recognizer.state {
        case .began:
            
            swipeToDismissTransition = SwipeToDismissTransition(scrollView: scrollView)
        
        case .changed:
        
            handleSwipeToDismissInProgress(swipingDirection, for: touchPoint)
       
        case .ended:
        
            handleSwipeToDimissEnded(swipingDirection, velocity: velocity, touchPoint: touchPoint)
        
        case .cancelled, .failed, .possible:
            break
        }
    }
}
