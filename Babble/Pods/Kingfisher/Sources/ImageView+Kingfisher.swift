//
//  ImageView+Kingfisher.swift
//  Kingfisher
//
//  Created by Wei Wang on 15/4/6.
//
//  Copyright (c) 2016 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#if os(OSX)
import AppKit
typealias ImageView = NSImageView
#else
import UIKit
typealias ImageView = UIImageView
#endif

// MARK: - Set Images
/**
*	Set image to use from web.
*/
extension ImageView {

    /**
     Set an image with a URL, a placeholder image, options, progress handler and completion handler.
     
     - parameter URL:               The URL of image.
     - parameter placeholderImage:  A placeholder image when retrieving the image at URL.
     - parameter optionsInfo:       A dictionary could control some behaviors. See `KingfisherOptionsInfo` for more.
     - parameter progressBlock:     Called when the image downloading progress gets updated.
     - parameter completionHandler: Called when the image retrieved and set.
     
     - returns: A task represents the retrieving process.
     
     - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread.
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
     */
    
    public func kf_setImageWithURL(_ URL: Foundation.URL?,
                                   placeholderImage: Image? = nil,
                                   optionsInfo: KingfisherOptionsInfo? = nil,
                                   progressBlock: DownloadProgressBlock? = nil,
                                   completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        let resource = URL.map { Resource(downloadURL: $0) }
        return kf_setImageWithResource(resource,
                                       placeholderImage: placeholderImage,
                                       optionsInfo: optionsInfo,
                                       progressBlock: progressBlock,
                                       completionHandler: completionHandler)
    }
    
    
    /**
    Set an image with a URL, a placeholder image, options, progress handler and completion handler.
    
    - parameter resource:          Resource object contains information such as `cacheKey` and `downloadURL`.
    - parameter placeholderImage:  A placeholder image when retrieving the image at URL.
    - parameter optionsInfo:       A dictionary could control some behaviors. See `KingfisherOptionsInfo` for more.
    - parameter progressBlock:     Called when the image downloading progress gets updated.
    - parameter completionHandler: Called when the image retrieved and set.
    
    - returns: A task represents the retrieving process.
     
    - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread. 
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
    */
    public func kf_setImageWithResource(_ resource: Resource?,
                                placeholderImage: Image? = nil,
                                     optionsInfo: KingfisherOptionsInfo? = nil,
                                   progressBlock: DownloadProgressBlock? = nil,
                               completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        image = placeholderImage
        
        guard let resource = resource else {
            completionHandler?(nil, nil, .none, nil)
            return RetrieveImageTask.emptyTask
        }
        
        let maybeIndicator = kf_indicator
        maybeIndicator?.startAnimatingView()
        
        kf_setWebURL(resource.downloadURL as URL)
        
        var options = optionsInfo ?? []
        if shouldPreloadAllGIF() {
            options.append(.preloadAllGIFData)
        }

        let task = KingfisherManager.sharedManager.retrieveImageWithResource(resource, optionsInfo: options,
            progressBlock: { receivedSize, totalSize in
                if let progressBlock = progressBlock {
                    progressBlock(receivedSize: receivedSize, totalSize: totalSize)
                }
            },
            completionHandler: {[weak self] image, error, cacheType, imageURL in
                
                dispatch_async_safely_to_main_queue {
                    guard let sSelf = self, imageURL == sSelf.kf_webURL else {
                        return
                    }
                    
                    sSelf.kf_setImageTask(nil)
                    
                    guard let image = image else {
                        maybeIndicator?.stopAnimatingView()
                        completionHandler?(image: nil, error: error, cacheType: cacheType, imageURL: imageURL)
                        return
                    }
                    
                    if let transitionItem = options.kf_firstMatchIgnoringAssociatedValue(.transition(.none)),
                        case .transition(let transition) = transitionItem, ( options.forceTransition || cacheType == .none) {
                            #if !os(OSX)
                                UIView.transition(with: sSelf, duration: 0.0, options: [],
                                    animations: {
                                        maybeIndicator?.stopAnimatingView()
                                    },
                                    completion: { finished in
                                        UIView.transition(with: sSelf, duration: transition.duration,
                                            options: [transition.animationOptions, .allowUserInteraction],
                                            animations: {
                                                // Set image property in the animation.
                                                transition.animations?(sSelf, image)
                                            },
                                            completion: { finished in
                                                transition.completion?(finished)
                                                completionHandler?(image: image, error: error, cacheType: cacheType, imageURL: imageURL)
                                        })
                                })
                            #endif
                    } else {
                        maybeIndicator?.stopAnimatingView()
                        sSelf.image = image
                        completionHandler?(image: image, error: error, cacheType: cacheType, imageURL: imageURL)
                    }
                }
            })
        
        kf_setImageTask(task)
        
        return task
    }
}

extension ImageView {
    func shouldPreloadAllGIF() -> Bool {
        return true
    }
}

extension ImageView {
    /**
     Cancel the image download task bounded to the image view if it is running.
     Nothing will happen if the downloading has already finished.
     */
    public func kf_cancelDownloadTask() {
        kf_imageTask?.downloadTask?.cancel()
    }
}

/**
 Enum for the types of indicators that the user can choose from.
 */
extension ImageView {
    public enum IndicatorType {
        /// No indicator.
        case none
        /// Use system activity indicator.
        case activity
        /// Use an image as indicator. GIF is supported.
        case image(imageData: Data)
        /// Use a custom indicator, which conforms to the `Indicator` protocol.
        case custom(indicator: Indicator)
    }
}

// MARK: - Associated Object
private var lastURLKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var imageTaskKey: Void?

extension ImageView {
    /// Get the image URL binded to this image view.
    public var kf_webURL: URL? {
        return objc_getAssociatedObject(self, &lastURLKey) as? URL
    }
    
    fileprivate func kf_setWebURL(_ URL: Foundation.URL) {
        objc_setAssociatedObject(self, &lastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    
    /// Whether show an animating activity indicator when the image view is loading an image or not.
    /// Default is false.
    public var kf_showIndicatorWhenLoading: Bool {
        get {
            switch kf_indicatorType {
            case .none:
                return false
            case .activity: fallthrough
            case .image(_): fallthrough
            case .custom(_): return true
            }
        }
        
        set {
            if kf_showIndicatorWhenLoading == newValue {
                return
            } else {
                kf_indicatorType = .activity
            }
        }
    }

    /// Holds which indicator type is going to be used.
    /// Default is .None
    public var kf_indicatorType: IndicatorType {
        get {
            let indicator = (objc_getAssociatedObject(self, &indicatorTypeKey) as? Box<IndicatorType?>)?.value
            return indicator ?? .none
        }
        
        set {
            switch newValue {
            case .none:
                kf_indicator = nil
            case .activity:
                kf_indicator = ActivityIndicator()
            case .image(let data):
                kf_indicator = ImageIndicator(imageData: data)
            case .custom(let indicator):
                kf_indicator = indicator
            }

            objc_setAssociatedObject(self, &indicatorTypeKey, Box(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// `kf_indicator` holds any type that conforms to the protocol `Indicator`.
    /// The protocol `Indicator` has a `view` property that will be shown when loading an image.
    /// Everything will be `nil` if `kf_indicatorType` is .None.
    public fileprivate(set) var kf_indicator: Indicator? {
        get {
            return (objc_getAssociatedObject(self, &indicatorKey) as? Box<Indicator?>)?.value
        }

        set {
            // Remove previous
            if let previousIndicator = kf_indicator {
                previousIndicator.view.removeFromSuperview()
            }

            // Add new
            if var newIndicator = newValue {
                newIndicator.view.frame = self.frame
                newIndicator.viewCenter = CGPoint(x: bounds.midX, y: bounds.midY)
                newIndicator.view.isHidden = true
                self.addSubview(newIndicator.view)
            }

            // Save in associated object
            objc_setAssociatedObject(self, &indicatorKey, Box(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate var kf_imageTask: RetrieveImageTask? {
        return objc_getAssociatedObject(self, &imageTaskKey) as? RetrieveImageTask
    }
    
    fileprivate func kf_setImageTask(_ task: RetrieveImageTask?) {
        objc_setAssociatedObject(self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
