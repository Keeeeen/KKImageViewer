//
//  ImageViewerOption.swift
//  KKImageViewer
//
//  Created by K.Kawakami on 2018/01/21.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import Foundation
import UIKit

public struct ImageViewerOption {
    
    public init() { }
    
    /// Distance (width of the area) between images when paged.
    public var imageDividerWidth: CGFloat = 19.0
    
    /// UIActivityIndicator is shown when we page to an image page, but the image itself is still loading.
    public var activityIndicatorStyle: UIActivityIndicatorViewStyle = .white
    
    /// Tint color for the UIActivityIndicator.
    public var activityIndecatorColor: UIColor?
    
    /// Sets the status bar visible/invisible while gallery is presented.
    public var statusBarHidden = true
    
    /// Sets the header view visible/invisible on launch.
    public var hideHeaderViewOnLaunch = false
    
    /// Sets the footer view visible/invisible on launch.
    public var hideFooterViewOnLaunch = false
    
    /// Allows to turn on/off header view hiding via single tap.
    public var toggleHeaderViewBySingleTap = true
    
    /// Allows to turn on/off footer view hiding via single tap.
    public var toggleFooterViewBySingleTap = true
    
    /// Allows to UIActivityViewController with ItemView via long press.
    public var activityViewByLongPress = true
    
    /// Allows to set maximum magnification factor for the image
    public var maximumZoomScale: CGFloat = 8
    
    /// Allows to set maximum magnification factor when double tap
    public var doubleTapZoomScale: CGFloat = 7
    
    /// Sets the duration of the animation when item is double tapped and transitions between ScaleToAspectFit & ScaleToAspectFill sizes.
    public var doubleTapToZoomDuration: TimeInterval = 0.15
    
    /// Transition duration for the blur layer component of the overlay when Gallery is being presented.
    public var blurPresentDuration: TimeInterval = 0.5
    
    /// Delayed start for the transition of the blur layer component of the overlay when Gallery is being presented.
    public var blurPresentDelay: TimeInterval = 0
    
    /// Transition duration for the color layer component of the overlay when Gallery is being presented.
    public var colorPresentDuration: TimeInterval = 0.25
    
    /// Delayed start for the transition of color layer component of the overlay when Gallery is being presented.
    public var colorPresentDelay: TimeInterval = 0
    
    /// Delayed start for header view transition (fade-in) when Gallery is being presented.
//    public var headerViewPresentDelay: TimeInterval = 0.2
    
    /// Delayed start for footer view transition (fade-in) when Gallery is being presented.
//    public var footerViewPresentDelay: TimeInterval = 0.2
    
    /// Transition duration for the blur layer component of the overlay when Gallery is being dismissed.
    public var blurDismissDuration: TimeInterval = 0.1
    
    /// Transition delay for the blur layer component of the overlay when Gallery is being dismissed.
    public var blurDismissDelay: TimeInterval = 0.4
    
    /// Transition duration for the color layer component of the overlay when Gallery is being dismissed.
    public var colorDismissDuration: TimeInterval = 0.45
    
    /// Transition delay for the color layer component of the overlay when Gallery is being dismissed.
    public var colorDismissDelay: TimeInterval = 0
    
    /// Transition duration for the item when the fade-in/fade-out effect is used globally for items while Gallery is being presented/dismissed.
    public var itemFadeDuration: TimeInterval = 0.3
    
    public var decorationViewsCloseDuration: TimeInterval = 0.15
    
    /// Transition duration for header view when they fade-in/fade-out after single tap.
    public var headerviewFadeDuration: TimeInterval = 0.15
    
    /// Transition duration for header view when they fade-in/fade-out after single tap.
    public var footerviewFadeDuration: TimeInterval = 0.15
    
    ///Duration of animated re-layout after device rotation.
    public var rotationDuration: TimeInterval = 0.15
    
    /// Duration of the displacement effect when gallery is being presented.
    public var displacementDuration: TimeInterval = 0.15
    
    /// Duration of the displacement effect when gallery is being dismissed.
    public var reverseDisplacementDuration: TimeInterval = 0.25
    
    /// Setting this to true is useful when your overlay layer is not fully opaque and you have multiple images on screen at once. The problem is image 1 is going to be displaced (gallery is being presented) and you can see that it is missing in the parent canvas because it "left the canvas" and the canvas bleeds its content through the overlay layer. However when you page to a different image and you decide to dismiss the gallery, that different image is going to be returned (using reverse displacement). That looks a bit strange because it is reverse displacing but it actually is already present in the parent canvas whereas the original image 1 is still missing there. There is no meaningful way to manage these displaced views. This setting helps to avoid it his problem by keeping the originals in place while still using the displacement effect.
    public var displacementKeepOriginalInPlace = false
    
    /// Provides the most typical timing curves for the displacement transition.
    public var displacementTimingCurve: UIViewAnimationCurve = .linear
    
    /// Allows to optionally set a spring bounce when the displacement transition finishes.
    public var displacementTransitionStyle: ImageViewerDisplacementStyle = .normal
    
    /// For the image to be reverse displaced, it must be visible in the parent view frame on screen, otherwise it's pointless to do the reverse displacement animation as we would be animating to out of bounds of the screen. However, there might be edge cases where only a tiny percentage of image is visible on screen, so reverse-displacing to that might not be desirable / visually pleasing. To address this problem, we can define a valid area that will be smaller by a given margin and sit centered inside the parent frame. For example, setting a value of 20 means the reverse displaced image must be in a rect that is inside the parent frame and the margin on all sides is to the parent frame is 20 points.
    public var displacementInsetMargin: CGFloat = 50
    
    /// Base color of the overlay layer that is mostly visible when images are displaced (gallery is being presented), rotated and interactively dismissed.
    public var overlayColor: UIColor = .black
    
    /// Allows to select the overall tone on the B&W scale of the blur layer in the overlay.
    public var overlayBlurStyle: UIBlurEffectStyle?
    
    /// The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
    public var overlayBlurOpacity: CGFloat = 1
    
    /// The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
    public var overlayColorOpacity: CGFloat = 1
    
    /// The minimum velocity needed for the image to continue on its swipe-to-dismiss path instead of returning to its original position. The velocity is in scalar units per second, which in our case represents points on screen per second. When the thumb moves on screen and eventually is lifted, it traveled along a path and the speed represents the number of points it traveled in the last 1000 msec before it was lifted.
    public var swipeToDismissThresholdVelocity: CGFloat = 500
    
    /// Allows to decide direction of swipe to dismiss, or disable it altogether
    public var swipeToDismissMode: SwipeToDismissMode = .vertical
    
    /// Allows to set rotation support support with relation to rotation support in the hosting app.
    public var rotationMode: RotationMode = .always
    
    /// Allows the video player to automatically continue playing the next video
    public var continuePlayVideoOnEnd = false
    
    /// Allows auto play video after gallery presented
    public var videoAutoPlay = false
    
    /// Tint color of video controls
    public var videoControlsColor: UIColor = .white
}

public enum ImageViewerDisplacementStyle {
    case normal
    case springBounce(CGFloat)
}

public enum SwipeToDismissMode: Int {
    case never
    case horizontal
    case vertical
    case always
}

public enum RotationMode {
    ///Gallery will rotate to orientations supported in the application.
    case applicationBased
    
    ///Gallery will rotate regardless of the rotation setting in the application.
    case always
}
