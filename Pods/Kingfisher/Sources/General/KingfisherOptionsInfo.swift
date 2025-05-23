//
//  KingfisherOptionsInfo.swift
//  Kingfisher
//
//  Created by Wei Wang on 15/4/23.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
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

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// KingfisherOptionsInfo is a typealias for [KingfisherOptionsInfoItem].
/// You can use the enum of option item with value to control some behaviors of Kingfisher.
public typealias KingfisherOptionsInfo = [KingfisherOptionsInfoItem]

extension Array where Element == KingfisherOptionsInfoItem {
    static let empty: KingfisherOptionsInfo = []
}

/// Represents the available option items could be used in `KingfisherOptionsInfo`.
public enum KingfisherOptionsInfoItem {
    /// Kingfisher will use the associated `ImageCache` object when handling related operations,
    /// including trying to retrieve the cached images and store the downloaded image to it.
    case targetCache(ImageCache)

    /// The `ImageCache` for storing and retrieving original images. If `originalCache` is
    /// contained in the options, it will be preferred for storing and retrieving original images.
    /// If there is no `.originalCache` in the options, `.targetCache` will be used to store original images.
    ///
    /// When using KingfisherManager to download and store an image, if `cacheOriginalImage` is
    /// applied in the option, the original image will be stored to this `originalCache`. At the
    /// same time, if a requested final image (with processor applied) cannot be found in `targetCache`,
    /// Kingfisher will try to search the original image to check whether it is already there. If found,
    /// it will be used and applied with the given processor. It is an optimization for not downloading
    /// the same image for multiple times.
    case originalCache(ImageCache)

    /// Kingfisher will use the associated `ImageDownloader` object to download the requested images.
    case downloader(ImageDownloader)

    /// Member for animation transition when using `UIImageView`. Kingfisher will use the `ImageTransition` of
    /// this enum to animate the image in if it is downloaded from web. The transition will not happen when the
    /// image is retrieved from either memory or disk cache by default. If you need to do the transition even when
    /// the image being retrieved from cache, set `.forceRefresh` as well.
    case transition(ImageTransition)

    /// Associated `Float` value will be set as the priority of image download task. The value for it should be
    /// between 0.0~1.0. If this option not set, the default value (`URLSessionTask.defaultPriority`) will be used.
    case downloadPriority(Float)

    /// If set, Kingfisher will ignore the cache and try to start a download task for the image source.
    case forceRefresh

    /// If set, Kingfisher will try to retrieve the image from memory cache first. If the image is not in memory
    /// cache, then it will ignore the disk cache but download the image again from network. This is useful when
    /// you want to display a changeable image behind the same url at the same app session, while avoiding download
    /// it for multiple times.
    case fromMemoryCacheOrRefresh

    /// If set, setting the image to an image view will happen with transition even when retrieved from cache.
    /// See `.transition` option for more.
    case forceTransition

    /// If set, Kingfisher will only cache the value in memory but not in disk.
    case cacheMemoryOnly

    /// If set, Kingfisher will wait for caching operation to be completed before calling the completion block.
    case waitForCache

    /// If set, Kingfisher will only try to retrieve the image from cache, but not from network. If the image is not in
    /// cache, the image retrieving will fail with the `KingfisherError.cacheError` with `.imageNotExisting` as its
    /// reason.
    case onlyFromCache

    /// Decode the image in background thread before using. It will decode the downloaded image data and do a off-screen
    /// rendering to extract pixel information in background. This can speed up display, but will cost more time to
    /// prepare the image for using.
    case backgroundDecode

    /// The associated value will be used as the target queue of dispatch callbacks when retrieving images from
    /// cache. If not set, Kingfisher will use `.mainCurrentOrAsync` for callbacks.
    ///
    /// - Note:
    /// This option does not affect the callbacks for UI related extension methods. You will always get the
    /// callbacks called from main queue.
    case callbackQueue(CallbackQueue)

    /// The associated value will be used as the scale factor when converting retrieved data to an image.
    /// Specify the image scale, instead of your screen scale. You may need to set the correct scale when you dealing
    /// with 2x or 3x retina images. Otherwise, Kingfisher will convert the data to image object at `scale` 1.0.
    case scaleFactor(CGFloat)

    /// Whether all the animated image data should be preloaded. Default is `false`, which means only following frames
    /// will be loaded on need. If `true`, all the animated image data will be loaded and decoded into memory.
    ///
    /// This option is mainly used for back compatibility internally. You should not set it directly. Instead,
    /// you should choose the image view class to control the GIF data loading. There are two classes in Kingfisher
    /// support to display a GIF image. `AnimatedImageView` does not preload all data, it takes much less memory, but
    /// uses more CPU when display. While a normal image view (`UIImageView` or `NSImageView`) loads all data at once,
    /// which uses more memory but only decode image frames once.
    case preloadAllAnimationData

    /// The `ImageDownloadRequestModifier` contained will be used to change the request before it being sent.
    /// This is the last chance you can modify the image download request. You can modify the request for some
    /// customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url mapping.
    /// The original request will be sent without any modification by default.
    case requestModifier(AsyncImageDownloadRequestModifier)

    /// The `ImageDownloadRedirectHandler` contained will be used to change the request before redirection.
    /// This is the possibility you can modify the image download request during redirect. You can modify the request for
    /// some customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url
    /// mapping.
    /// The original redirection request will be sent without any modification by default.
    case redirectHandler(ImageDownloadRedirectHandler)

    /// Processor for processing when the downloading finishes, a processor will convert the downloaded data to an image
    /// and/or apply some filter on it. If a cache is connected to the downloader (it happens when you are using
    /// KingfisherManager or any of the view extension methods), the converted image will also be sent to cache as well.
    /// If not set, the `DefaultImageProcessor.default` will be used.
    case processor(ImageProcessor)

    /// Provides a `CacheSerializer` to convert some data to an image object for
    /// retrieving from disk cache or vice versa for storing to disk cache.
    /// If not set, the `DefaultCacheSerializer.default` will be used.
    case cacheSerializer(CacheSerializer)

    /// An `ImageModifier` is for modifying an image as needed right before it is used. If the image was fetched
    /// directly from the downloader, the modifier will run directly after the `ImageProcessor`. If the image is being
    /// fetched from a cache, the modifier will run after the `CacheSerializer`.
    ///
    /// Use `ImageModifier` when you need to set properties that do not persist when caching the image on a concrete
    /// type of `Image`, such as the `renderingMode` or the `alignmentInsets` of `UIImage`.
    case imageModifier(ImageModifier)

    /// Keep the existing image of image view while setting another image to it.
    /// By setting this option, the placeholder image parameter of image view extension method
    /// will be ignored and the current image will be kept while loading or downloading the new image.
    case keepCurrentImageWhileLoading

    /// If set, Kingfisher will only load the first frame from an animated image file as a single image.
    /// Loading an animated images may take too much memory. It will be useful when you want to display a
    /// static preview of the first frame from an animated image.
    ///
    /// This option will be ignored if the target image is not animated image data.
    case onlyLoadFirstFrame

    /// If set and an `ImageProcessor` is used, Kingfisher will try to cache both the final result and original
    /// image. Kingfisher will have a chance to use the original image when another processor is applied to the same
    /// resource, instead of downloading it again. You can use `.originalCache` to specify a cache or the original
    /// images if necessary.
    ///
    /// The original image will be only cached to disk storage.
    case cacheOriginalImage

    /// If set and an image retrieving error occurred Kingfisher will set provided image (or empty)
    /// in place of requested one. It's useful when you don't want to show placeholder
    /// during loading time but wants to use some default image when requests will be failed.
    case onFailureImage(KFCrossPlatformImage?)

    /// If set and used in `ImagePrefetcher`, the prefetching operation will load the images into memory storage
    /// aggressively. By default this is not contained in the options, that means if the requested image is already
    /// in disk cache, Kingfisher will not try to load it to memory.
    case alsoPrefetchToMemory

    /// If set, the disk storage loading will happen in the same calling queue. By default, disk storage file loading
    /// happens in its own queue with an asynchronous dispatch behavior. Although it provides better non-blocking disk
    /// loading performance, it also causes a flickering when you reload an image from disk, if the image view already
    /// has an image set.
    ///
    /// Set this options will stop that flickering by keeping all loading in the same queue (typically the UI queue
    /// if you are using Kingfisher's extension methods to set an image), with a tradeoff of loading performance.
    case loadDiskFileSynchronously

    /// Options to control the writing of data to disk storage
    /// If set, options will be passed the store operation for a new files.
    case diskStoreWriteOptions(Data.WritingOptions)

    /// The expiration setting for memory cache. By default, the underlying `MemoryStorage.Backend` uses the
    /// expiration in its config for all items. If set, the `MemoryStorage.Backend` will use this associated
    /// value to overwrite the config setting for this caching item.
    case memoryCacheExpiration(StorageExpiration)

    /// The expiration extending setting for memory cache. The item expiration time will be incremented by this
    /// value after access.
    /// By default, the underlying `MemoryStorage.Backend` uses the initial cache expiration as extending
    /// value: .cacheTime.
    ///
    /// To disable extending option at all add memoryCacheAccessExtendingExpiration(.none) to options.
    case memoryCacheAccessExtendingExpiration(ExpirationExtending)

    /// The expiration setting for disk cache. By default, the underlying `DiskStorage.Backend` uses the
    /// expiration in its config for all items. If set, the `DiskStorage.Backend` will use this associated
    /// value to overwrite the config setting for this caching item.
    case diskCacheExpiration(StorageExpiration)

    /// The expiration extending setting for disk cache. The item expiration time will be incremented by this value after access.
    /// By default, the underlying `DiskStorage.Backend` uses the initial cache expiration as extending value: .cacheTime.
    /// To disable extending option at all add diskCacheAccessExtendingExpiration(.none) to options.
    case diskCacheAccessExtendingExpiration(ExpirationExtending)

    /// Decides on which queue the image processing should happen. By default, Kingfisher uses a pre-defined serial
    /// queue to process images. Use this option to change this behavior. For example, specify a `.mainCurrentOrAsync`
    /// to let the image be processed in main queue to prevent a possible flickering (but with a possibility of
    /// blocking the UI, especially if the processor needs a lot of time to run).
    case processingQueue(CallbackQueue)

    /// Enable progressive image loading, Kingfisher will use the associated `ImageProgressive` value to process the
    /// progressive JPEG data and display it in a progressive way.
    case progressiveJPEG(ImageProgressive)

    /// The alternative sources will be used when the original input `Source` fails. The `Source`s in the associated
    /// array will be used to start a new image loading task if the previous task fails due to an error. The image
    /// source loading process will stop as soon as a source is loaded successfully. If all `[Source]`s are used but
    /// the loading is still failing, an `imageSettingError` with `alternativeSourcesExhausted` as its reason will be
    /// thrown out.
    ///
    /// This option is useful if you want to implement a fallback solution for setting image.
    ///
    /// User cancellation will not trigger the alternative source loading.
    case alternativeSources([Source])

    /// Provide a retry strategy which will be used when something gets wrong during the image retrieving process from
    /// `KingfisherManager`. You can define a strategy by create a type conforming to the `RetryStrategy` protocol.
    ///
    /// - Note:
    ///
    /// All extension methods of Kingfisher (`kf` extensions on `UIImageView` or `UIButton`) retrieve images through
    /// `KingfisherManager`, so the retry strategy also applies when using them. However, this option does not apply
    /// when pass to an `ImageDownloader` or `ImageCache`.
    ///
    case retryStrategy(RetryStrategy)

    /// The `Source` should be loaded when user enables Low Data Mode and the original source fails with an
    /// `NSURLErrorNetworkUnavailableReason.constrained` error. When this option is set, the
    /// `allowsConstrainedNetworkAccess` property of the request for the original source will be set to `false` and the
    /// `Source` in associated value will be used to retrieve the image for low data mode. Usually, you can provide a
    /// low-resolution version of your image or a local image provider to display a placeholder.
    ///
    /// If not set or the `source` is `nil`, the device Low Data Mode will be ignored and the original source will
    /// be loaded following the system default behavior, in a normal way.
    case lowDataMode(Source?)
}

// Improve performance by parsing the input `KingfisherOptionsInfo` (self) first.
// So we can prevent the iterating over the options array again and again.
/// The parsed options info used across Kingfisher methods. Each property in this type corresponds a case member
/// in `KingfisherOptionsInfoItem`. When a `KingfisherOptionsInfo` sent to Kingfisher related methods, it will be
/// parsed and converted to a `KingfisherParsedOptionsInfo` first, and pass through the internal methods.
public struct KingfisherParsedOptionsInfo {
    public var targetCache: ImageCache?
    public var originalCache: ImageCache?
    public var downloader: ImageDownloader?
    public var transition: ImageTransition = .none
    public var downloadPriority: Float = URLSessionTask.defaultPriority
    public var forceRefresh = false
    public var fromMemoryCacheOrRefresh = false
    public var forceTransition = false
    public var cacheMemoryOnly = false
    public var waitForCache = false
    public var onlyFromCache = false
    public var backgroundDecode = false
    public var preloadAllAnimationData = false
    public var callbackQueue: CallbackQueue = .mainCurrentOrAsync
    public var scaleFactor: CGFloat = 1.0
    public var requestModifier: AsyncImageDownloadRequestModifier?
    public var redirectHandler: ImageDownloadRedirectHandler?
    public var processor: ImageProcessor = DefaultImageProcessor.default
    public var imageModifier: ImageModifier?
    public var cacheSerializer: CacheSerializer = DefaultCacheSerializer.default
    public var keepCurrentImageWhileLoading = false
    public var onlyLoadFirstFrame = false
    public var cacheOriginalImage = false
    public var onFailureImage: Optional<KFCrossPlatformImage?> = .none
    public var alsoPrefetchToMemory = false
    public var loadDiskFileSynchronously = false
    public var diskStoreWriteOptions: Data.WritingOptions = []
    public var memoryCacheExpiration: StorageExpiration?
    public var memoryCacheAccessExtendingExpiration: ExpirationExtending = .cacheTime
    public var diskCacheExpiration: StorageExpiration?
    public var diskCacheAccessExtendingExpiration: ExpirationExtending = .cacheTime
    public var processingQueue: CallbackQueue?
    public var progressiveJPEG: ImageProgressive?
    public var alternativeSources: [Source]?
    public var retryStrategy: RetryStrategy?
    public var lowDataModeSource: Source?

    var onDataReceived: [DataReceivingSideEffect]?

    public init(_ info: KingfisherOptionsInfo?) {
        guard let info = info else { return }
        for option in info {
            switch option {
            case let .targetCache(value): targetCache = value
            case let .originalCache(value): originalCache = value
            case let .downloader(value): downloader = value
            case let .transition(value): transition = value
            case let .downloadPriority(value): downloadPriority = value
            case .forceRefresh: forceRefresh = true
            case .fromMemoryCacheOrRefresh: fromMemoryCacheOrRefresh = true
            case .forceTransition: forceTransition = true
            case .cacheMemoryOnly: cacheMemoryOnly = true
            case .waitForCache: waitForCache = true
            case .onlyFromCache: onlyFromCache = true
            case .backgroundDecode: backgroundDecode = true
            case .preloadAllAnimationData: preloadAllAnimationData = true
            case let .callbackQueue(value): callbackQueue = value
            case let .scaleFactor(value): scaleFactor = value
            case let .requestModifier(value): requestModifier = value
            case let .redirectHandler(value): redirectHandler = value
            case let .processor(value): processor = value
            case let .imageModifier(value): imageModifier = value
            case let .cacheSerializer(value): cacheSerializer = value
            case .keepCurrentImageWhileLoading: keepCurrentImageWhileLoading = true
            case .onlyLoadFirstFrame: onlyLoadFirstFrame = true
            case .cacheOriginalImage: cacheOriginalImage = true
            case let .onFailureImage(value): onFailureImage = .some(value)
            case .alsoPrefetchToMemory: alsoPrefetchToMemory = true
            case .loadDiskFileSynchronously: loadDiskFileSynchronously = true
            case let .diskStoreWriteOptions(options): diskStoreWriteOptions = options
            case let .memoryCacheExpiration(expiration): memoryCacheExpiration = expiration
            case let .memoryCacheAccessExtendingExpiration(expirationExtending): memoryCacheAccessExtendingExpiration = expirationExtending
            case let .diskCacheExpiration(expiration): diskCacheExpiration = expiration
            case let .diskCacheAccessExtendingExpiration(expirationExtending): diskCacheAccessExtendingExpiration = expirationExtending
            case let .processingQueue(queue): processingQueue = queue
            case let .progressiveJPEG(value): progressiveJPEG = value
            case let .alternativeSources(sources): alternativeSources = sources
            case let .retryStrategy(strategy): retryStrategy = strategy
            case let .lowDataMode(source): lowDataModeSource = source
            }
        }

        if originalCache == nil {
            originalCache = targetCache
        }
    }
}

extension KingfisherParsedOptionsInfo {
    var imageCreatingOptions: ImageCreatingOptions {
        return ImageCreatingOptions(
            scale: scaleFactor,
            duration: 0.0,
            preloadAll: preloadAllAnimationData,
            onlyFirstFrame: onlyLoadFirstFrame
        )
    }
}

protocol DataReceivingSideEffect: AnyObject {
    var onShouldApply: () -> Bool { get set }
    func onDataReceived(_ session: URLSession, task: SessionDataTask, data: Data)
}

class ImageLoadingProgressSideEffect: DataReceivingSideEffect {
    var onShouldApply: () -> Bool = { true }

    let block: DownloadProgressBlock

    init(_ block: @escaping DownloadProgressBlock) {
        self.block = block
    }

    func onDataReceived(_: URLSession, task: SessionDataTask, data _: Data) {
        guard onShouldApply() else { return }
        guard let expectedContentLength = task.task.response?.expectedContentLength,
              expectedContentLength != -1
        else {
            return
        }

        let dataLength = Int64(task.mutableData.count)
        DispatchQueue.main.async {
            self.block(dataLength, expectedContentLength)
        }
    }
}
