//
//  AnimatedImageView.swift
//  Kingfisher
//
//  Created by bl4ckra1sond3tre on 4/22/16.
//
//  The AnimatedImageView, AnimatedFrame and Animator is a modified version of
//  some classes from kaishin's Gifu project (https://github.com/kaishin/Gifu)
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Reda Lemeden.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  The name and characters used in the demo of this software are property of their
//  respective owners.

#if !os(watchOS)
    #if canImport(UIKit)
        import ImageIO
        import UIKit

        typealias KFCrossPlatformContentMode = UIView.ContentMode
    #elseif canImport(AppKit)
        import AppKit

        typealias KFCrossPlatformContentMode = NSImageScaling
    #endif

    /// Protocol of `AnimatedImageView`.
    public protocol AnimatedImageViewDelegate: AnyObject {
        /// Called after the animatedImageView has finished each animation loop.
        ///
        /// - Parameters:
        ///   - imageView: The `AnimatedImageView` that is being animated.
        ///   - count: The looped count.
        func animatedImageView(_ imageView: AnimatedImageView, didPlayAnimationLoops count: UInt)

        /// Called after the `AnimatedImageView` has reached the max repeat count.
        ///
        /// - Parameter imageView: The `AnimatedImageView` that is being animated.
        func animatedImageViewDidFinishAnimating(_ imageView: AnimatedImageView)
    }

    public extension AnimatedImageViewDelegate {
        func animatedImageView(_: AnimatedImageView, didPlayAnimationLoops _: UInt) {}
        func animatedImageViewDidFinishAnimating(_: AnimatedImageView) {}
    }

    let KFRunLoopModeCommon = RunLoop.Mode.common

    /// Represents a subclass of `UIImageView` for displaying animated image.
    /// Different from showing animated image in a normal `UIImageView` (which load all frames at one time),
    /// `AnimatedImageView` only tries to load several frames (defined by `framePreloadCount`) to reduce memory usage.
    /// It provides a tradeoff between memory usage and CPU time. If you have a memory issue when using a normal image
    /// view to load GIF data, you could give this class a try.
    ///
    /// Kingfisher supports setting GIF animated data to either `UIImageView` and `AnimatedImageView` out of box. So
    /// it would be fairly easy to switch between them.
    open class AnimatedImageView: KFCrossPlatformImageView {
        /// Proxy object for preventing a reference cycle between the `CADDisplayLink` and `AnimatedImageView`.
        class TargetProxy {
            private weak var target: AnimatedImageView?

            init(target: AnimatedImageView) {
                self.target = target
            }

            @objc func onScreenUpdate() {
                target?.updateFrameIfNeeded()
            }
        }

        /// Enumeration that specifies repeat count of GIF
        public enum RepeatCount: Equatable {
            case once
            case finite(count: UInt)
            case infinite

            public static func == (lhs: RepeatCount, rhs: RepeatCount) -> Bool {
                switch (lhs, rhs) {
                case let (.finite(l), .finite(r)):
                    return l == r
                case (.once, .once),
                     (.infinite, .infinite):
                    return true
                case let (.once, .finite(count)),
                     let (.finite(count), .once):
                    return count == 1
                case (.once, _),
                     (.infinite, _),
                     (.finite, _):
                    return false
                }
            }
        }

        // MARK: - Public property

        /// Whether automatically play the animation when the view become visible. Default is `true`.
        public var autoPlayAnimatedImage = true

        /// The count of the frames should be preloaded before shown.
        public var framePreloadCount = 10

        /// Specifies whether the GIF frames should be pre-scaled to the image view's size or not.
        /// If the downloaded image is larger than the image view's size, it will help to reduce some memory use.
        /// Default is `true`.
        public var needsPrescaling = true

        /// Decode the GIF frames in background thread before using. It will decode frames data and do a off-screen
        /// rendering to extract pixel information in background. This can reduce the main thread CPU usage.
        ///
        @available(*, deprecated, message: """
            This property does not perform as declared and may lead to performance degradation.
            It is currently obsolete and scheduled for removal in a future version.
        """)
        public var backgroundDecode = true

        /// The animation timer's run loop mode. Default is `RunLoop.Mode.common`.
        /// Set this property to `RunLoop.Mode.default` will make the animation pause during UIScrollView scrolling.
        public var runLoopMode = KFRunLoopModeCommon {
            willSet {
                guard runLoopMode != newValue else { return }
                stopAnimating()
                displayLink.remove(from: .main, forMode: runLoopMode)
                displayLink.add(to: .main, forMode: newValue)
                startAnimating()
            }
        }

        /// The repeat count. The animated image will keep animate until it the loop count reaches this value.
        /// Setting this value to another one will reset current animation.
        ///
        /// Default is `.infinite`, which means the animation will last forever.
        public var repeatCount = RepeatCount.infinite {
            didSet {
                if oldValue != repeatCount {
                    reset()
                    #if os(macOS)
                        needsDisplay = true
                        layer?.setNeedsDisplay()
                    #else
                        setNeedsDisplay()
                        layer.setNeedsDisplay()
                    #endif
                }
            }
        }

        /// Delegate of this `AnimatedImageView` object. See `AnimatedImageViewDelegate` protocol for more.
        public weak var delegate: AnimatedImageViewDelegate?

        /// The `Animator` instance that holds the frames of a specific image in memory.
        public private(set) var animator: Animator?

        // MARK: - Private property

        // Dispatch queue used for preloading images.
        private lazy var preloadQueue: DispatchQueue = .init(label: "com.onevcat.Kingfisher.Animator.preloadQueue")

        // A flag to avoid invalidating the displayLink on deinit if it was never created, because displayLink is so lazy.
        private var isDisplayLinkInitialized: Bool = false

        // A display link that keeps calling the `updateFrame` method on every screen refresh.
        private lazy var displayLink: DisplayLinkCompatible = {
            isDisplayLinkInitialized = true
            let displayLink = self.compatibleDisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
            displayLink.add(to: .main, forMode: runLoopMode)
            displayLink.isPaused = true
            return displayLink
        }()

        // MARK: - Override

        override open var image: KFCrossPlatformImage? {
            didSet {
                if image != oldValue {
                    reset()
                }
                #if os(macOS)
                    needsDisplay = true
                    layer?.setNeedsDisplay()
                #else
                    setNeedsDisplay()
                    layer.setNeedsDisplay()
                #endif
            }
        }

        override open var isHighlighted: Bool {
            get {
                super.isHighlighted
            }
            set {
                // Highlighted image is unsupported for animated images.
                // See https://github.com/onevcat/Kingfisher/issues/1679
                if displayLink.isPaused {
                    super.isHighlighted = newValue
                }
            }
        }

        // Workaround for Apple xcframework creating issue on Apple TV in Swift 5.8.
        // https://github.com/apple/swift/issues/66015
        #if os(tvOS)
            override public init(image: UIImage?, highlightedImage: UIImage?) {
                super.init(image: image, highlightedImage: highlightedImage)
            }

            public required init?(coder: NSCoder) {
                super.init(coder: coder)
            }

            init() {
                super.init(frame: .zero)
            }
        #endif

        deinit {
            if isDisplayLinkInitialized {
                displayLink.invalidate()
            }
        }

        #if os(macOS)
            override public init(frame frameRect: NSRect) {
                super.init(frame: frameRect)
                commonInit()
            }

            public required init?(coder: NSCoder) {
                super.init(coder: coder)
                commonInit()
            }

            private func commonInit() {
                super.animates = false
                wantsLayer = true
            }

            override open var animates: Bool {
                get {
                    if isDisplayLinkInitialized {
                        return !displayLink.isPaused
                    } else {
                        return super.animates
                    }
                }
                set {
                    if newValue {
                        startAnimating()
                    } else {
                        stopAnimating()
                    }
                }
            }

            open func startAnimating() {
                guard let animator = animator else { return }
                guard !animator.isReachMaxRepeatCount else { return }

                displayLink.isPaused = false
            }

            open func stopAnimating() {
                if isDisplayLinkInitialized {
                    displayLink.isPaused = true
                }
            }

            override open var wantsUpdateLayer: Bool {
                return true
            }

            override open func updateLayer() {
                if let frame = animator?.currentFrameImage ?? currentFrame, let layer = layer {
                    layer.contents = frame.kf.cgImage
                    layer.contentsScale = frame.kf.scale
                    layer.contentsGravity = determineContentsGravity(for: frame)
                    currentFrame = frame
                }
            }

            private func determineContentsGravity(for image: NSImage) -> CALayerContentsGravity {
                switch imageScaling {
                case .scaleProportionallyDown:
                    if image.size.width > bounds.width || image.size.height > bounds.height {
                        return .resizeAspect
                    } else {
                        return .center
                    }
                case .scaleProportionallyUpOrDown:
                    return .resizeAspect
                case .scaleAxesIndependently:
                    return .resize
                case .scaleNone:
                    return .center
                default:
                    return .resizeAspect
                }
            }

            override open func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()
                didMove()
            }

            override open func viewDidMoveToSuperview() {
                super.viewDidMoveToSuperview()
                didMove()
            }
        #else
            override open var isAnimating: Bool {
                if isDisplayLinkInitialized {
                    return !displayLink.isPaused
                } else {
                    return super.isAnimating
                }
            }

            /// Starts the animation.
            override open func startAnimating() {
                guard !isAnimating else { return }
                guard let animator = animator else { return }
                guard !animator.isReachMaxRepeatCount else { return }

                displayLink.isPaused = false
            }

            /// Stops the animation.
            override open func stopAnimating() {
                super.stopAnimating()
                if isDisplayLinkInitialized {
                    displayLink.isPaused = true
                }
            }

            override open func display(_ layer: CALayer) {
                layer.contents = animator?.currentFrameImage?.cgImage ?? image?.cgImage
            }

            override open func didMoveToWindow() {
                super.didMoveToWindow()
                didMove()
            }

            override open func didMoveToSuperview() {
                super.didMoveToSuperview()
                didMove()
            }
        #endif

        // This is for back compatibility that using regular `UIImageView` to show animated image.
        override func shouldPreloadAllAnimation() -> Bool {
            return false
        }

        // Reset the animator.
        private func reset() {
            animator = nil
            currentFrame = nil
            if let image = image, let frameSource = image.kf.frameSource {
                #if os(visionOS)
                    let scale = UITraitCollection.current.displayScale
                #elseif os(macOS)
                    let scale = image.recommendedLayerContentsScale(window?.backingScaleFactor ?? 0.0)
                    let contentMode = imageScaling
                #else
                    var scale: CGFloat = 0
                    if #available(iOS 13.0, tvOS 13.0, *) {
                        scale = UITraitCollection.current.displayScale
                    } else {
                        scale = UIScreen.main.scale
                    }
                #endif
                currentFrame = image
                let targetSize = bounds.scaled(scale).size
                let animator = Animator(
                    frameSource: frameSource,
                    contentMode: contentMode,
                    size: targetSize,
                    imageSize: image.kf.size,
                    imageScale: image.kf.scale,
                    framePreloadCount: framePreloadCount,
                    repeatCount: repeatCount,
                    preloadQueue: preloadQueue
                )
                animator.delegate = self
                animator.needsPrescaling = needsPrescaling
                animator.prepareFramesAsynchronously()
                self.animator = animator
            }
            didMove()
        }

        private func didMove() {
            if autoPlayAnimatedImage && animator != nil {
                if let _ = superview, let _ = window {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }

        /// If the Animator cannot prepare the next frame in time, `animator.currentFrameImage` will return nil.
        /// To prevent unexpected blinking in the ImageView, we maintain a cache of the currently displayed frame
        /// to use as a fallback in such scenarios.
        private var currentFrame: KFCrossPlatformImage?

        /// Update the current frame with the displayLink duration.
        private func updateFrameIfNeeded() {
            guard let animator = animator else {
                return
            }

            guard !animator.isFinished else {
                stopAnimating()
                delegate?.animatedImageViewDidFinishAnimating(self)
                return
            }

            let duration: CFTimeInterval

            // CA based display link is opt-out from ProMotion by default.
            // So the duration and its FPS might not match.
            // See [#718](https://github.com/onevcat/Kingfisher/issues/718)
            // By setting CADisableMinimumFrameDuration to YES in Info.plist may
            // cause the preferredFramesPerSecond being 0
            let preferredFramesPerSecond = displayLink.preferredFramesPerSecond
            if preferredFramesPerSecond == 0 {
                duration = displayLink.duration
            } else {
                // Some devices (like iPad Pro 10.5) will have a different FPS.
                duration = 1.0 / TimeInterval(preferredFramesPerSecond)
            }

            animator.shouldChangeFrame(with: duration) { [weak self] hasNewFrame in
                if hasNewFrame {
                    #if os(macOS)
                        self?.layer?.setNeedsDisplay()
                    #else
                        self?.layer.setNeedsDisplay()
                    #endif
                }
            }
        }
    }

    protocol AnimatorDelegate: AnyObject {
        func animator(_ animator: AnimatedImageView.Animator, didPlayAnimationLoops count: UInt)
    }

    extension AnimatedImageView: AnimatorDelegate {
        func animator(_: Animator, didPlayAnimationLoops count: UInt) {
            delegate?.animatedImageView(self, didPlayAnimationLoops: count)
        }
    }

    extension AnimatedImageView {
        // Represents a single frame in a GIF.
        struct AnimatedFrame {
            // The image to display for this frame. Its value is nil when the frame is removed from the buffer.
            let image: KFCrossPlatformImage?

            // The duration that this frame should remain active.
            let duration: TimeInterval

            // A placeholder frame with no image assigned.
            // Used to replace frames that are no longer needed in the animation.
            var placeholderFrame: AnimatedFrame {
                return AnimatedFrame(image: nil, duration: duration)
            }

            // Whether this frame instance contains an image or not.
            var isPlaceholder: Bool {
                return image == nil
            }

            // Returns a new instance from an optional image.
            //
            // - parameter image: An optional `UIImage` instance to be assigned to the new frame.
            // - returns: An `AnimatedFrame` instance.
            func makeAnimatedFrame(image: KFCrossPlatformImage?) -> AnimatedFrame {
                return AnimatedFrame(image: image, duration: duration)
            }
        }
    }

    public extension AnimatedImageView {
        // MARK: - Animator

        /// An animator which used to drive the data behind `AnimatedImageView`.
        class Animator {
            private let size: CGSize

            private let imageSize: CGSize
            private let imageScale: CGFloat

            /// The maximum count of image frames that needs preload.
            public let maxFrameCount: Int

            private let frameSource: ImageFrameSource
            private let maxRepeatCount: RepeatCount

            private let maxTimeStep: TimeInterval = 1.0
            private let animatedFrames = SafeArray<AnimatedFrame>()
            private var frameCount = 0
            private var timeSinceLastFrameChange: TimeInterval = 0.0
            private var currentRepeatCount: UInt = 0

            var isFinished: Bool = false

            var needsPrescaling = true

            weak var delegate: AnimatorDelegate?

            // Total duration of one animation loop
            var loopDuration: TimeInterval = 0

            /// The image of the current frame.
            public var currentFrameImage: KFCrossPlatformImage? {
                return frame(at: currentFrameIndex)
            }

            /// The duration of the current active frame duration.
            public var currentFrameDuration: TimeInterval {
                return duration(at: currentFrameIndex)
            }

            /// The index of the current animation frame.
            public internal(set) var currentFrameIndex = 0 {
                didSet {
                    previousFrameIndex = oldValue
                }
            }

            var previousFrameIndex = 0 {
                didSet {
                    preloadQueue.async {
                        self.updatePreloadedFrames()
                    }
                }
            }

            var isReachMaxRepeatCount: Bool {
                switch maxRepeatCount {
                case .once:
                    return currentRepeatCount >= 1
                case let .finite(maxCount):
                    return currentRepeatCount >= maxCount
                case .infinite:
                    return false
                }
            }

            /// Whether the current frame is the last frame or not in the animation sequence.
            public var isLastFrame: Bool {
                return currentFrameIndex == frameCount - 1
            }

            var preloadingIsNeeded: Bool {
                return maxFrameCount < frameCount - 1
            }

            #if os(macOS)
                var contentMode = NSImageScaling.scaleAxesIndependently
            #else
                var contentMode = UIView.ContentMode.scaleToFill
            #endif

            private lazy var preloadQueue: DispatchQueue = .init(label: "com.onevcat.Kingfisher.Animator.preloadQueue")

            /// Creates an animator with image source reference.
            ///
            /// - Parameters:
            ///   - source: The reference of animated image.
            ///   - mode: Content mode of the `AnimatedImageView`.
            ///   - size: Size of the `AnimatedImageView`.
            ///   - imageSize: Size of the `KingfisherWrapper`.
            ///   - imageScale: Scale of the `KingfisherWrapper`.
            ///   - count: Count of frames needed to be preloaded.
            ///   - repeatCount: The repeat count should this animator uses.
            ///   - preloadQueue: Dispatch queue used for preloading images.
            convenience init(imageSource source: CGImageSource,
                             contentMode mode: KFCrossPlatformContentMode,
                             size: CGSize,
                             imageSize: CGSize,
                             imageScale: CGFloat,
                             framePreloadCount count: Int,
                             repeatCount: RepeatCount,
                             preloadQueue: DispatchQueue)
            {
                let frameSource = CGImageFrameSource(data: nil, imageSource: source, options: nil)
                self.init(frameSource: frameSource,
                          contentMode: mode,
                          size: size,
                          imageSize: imageSize,
                          imageScale: imageScale,
                          framePreloadCount: count,
                          repeatCount: repeatCount,
                          preloadQueue: preloadQueue)
            }

            /// Creates an animator with a custom image frame source.
            ///
            /// - Parameters:
            ///   - frameSource: The reference of animated image.
            ///   - mode: Content mode of the `AnimatedImageView`.
            ///   - size: Size of the `AnimatedImageView`.
            ///   - imageSize: Size of the `KingfisherWrapper`.
            ///   - imageScale: Scale of the `KingfisherWrapper`.
            ///   - count: Count of frames needed to be preloaded.
            ///   - repeatCount: The repeat count should this animator uses.
            ///   - preloadQueue: Dispatch queue used for preloading images.
            init(frameSource source: ImageFrameSource,
                 contentMode mode: KFCrossPlatformContentMode,
                 size: CGSize,
                 imageSize: CGSize,
                 imageScale: CGFloat,
                 framePreloadCount count: Int,
                 repeatCount: RepeatCount,
                 preloadQueue: DispatchQueue)
            {
                frameSource = source
                contentMode = mode
                self.size = size
                self.imageSize = imageSize
                self.imageScale = imageScale
                maxFrameCount = count
                maxRepeatCount = repeatCount
                self.preloadQueue = preloadQueue
            }

            deinit {
                resetAnimatedFrames()
            }

            /// Gets the image frame of a given index.
            /// - Parameter index: The index of desired image.
            /// - Returns: The decoded image at the frame. `nil` if the index is out of bound or the image is not yet loaded.
            public func frame(at index: Int) -> KFCrossPlatformImage? {
                return animatedFrames[index]?.image
            }

            public func duration(at index: Int) -> TimeInterval {
                return animatedFrames[index]?.duration ?? .infinity
            }

            func prepareFramesAsynchronously() {
                frameCount = frameSource.frameCount
                animatedFrames.reserveCapacity(frameCount)
                preloadQueue.async { [weak self] in
                    self?.setupAnimatedFrames()
                }
            }

            func shouldChangeFrame(with duration: CFTimeInterval, handler: (Bool) -> Void) {
                incrementTimeSinceLastFrameChange(with: duration)

                if currentFrameDuration > timeSinceLastFrameChange {
                    handler(false)
                } else {
                    resetTimeSinceLastFrameChange()
                    incrementCurrentFrameIndex()
                    handler(true)
                }
            }

            private func setupAnimatedFrames() {
                resetAnimatedFrames()

                var duration: TimeInterval = 0

                for index in 0 ..< frameCount {
                    let frameDuration = frameSource.duration(at: index)
                    duration += min(frameDuration, maxTimeStep)
                    animatedFrames.append(AnimatedFrame(image: nil, duration: frameDuration))

                    if index > maxFrameCount { continue }
                    animatedFrames[index] = animatedFrames[index]?.makeAnimatedFrame(image: loadFrame(at: index))
                }

                loopDuration = duration
            }

            private func resetAnimatedFrames() {
                animatedFrames.removeAll()
            }

            private func loadFrame(at index: Int) -> KFCrossPlatformImage? {
                let resize = needsPrescaling && size != .zero
                let maxSize = resize ? size : nil
                guard let cgImage = frameSource.frame(at: index, maxSize: maxSize) else {
                    return nil
                }

                #if os(macOS)
                    return KFCrossPlatformImage(cgImage: cgImage, size: .zero)
                #else
                    if #available(iOS 15, tvOS 15, *) {
                        // From iOS 15, a plain image loading causes iOS calling `-[_UIImageCGImageContent initWithCGImage:scale:]`
                        // in ImageIO, which holds the image ref on the creating thread.
                        // To get a workaround, create another image ref and use that to create the final image. This leads to
                        // some performance loss, but there is little we can do.
                        // https://github.com/onevcat/Kingfisher/issues/1844
                        // https://github.com/onevcat/Kingfisher/pulls/2194
                        guard let unretainedImage = CGImage.create(ref: cgImage) else {
                            return KFCrossPlatformImage(cgImage: cgImage)
                        }

                        return KFCrossPlatformImage(cgImage: unretainedImage)
                    } else {
                        return KFCrossPlatformImage(cgImage: cgImage)
                    }
                #endif
            }

            private func updatePreloadedFrames() {
                guard preloadingIsNeeded else {
                    return
                }

                let previousFrame = animatedFrames[previousFrameIndex]
                animatedFrames[previousFrameIndex] = previousFrame?.placeholderFrame
                // ensure the image dealloc in main thread
                defer {
                    if let image = previousFrame?.image {
                        DispatchQueue.main.async {
                            _ = image
                        }
                    }
                }

                for index in preloadIndexes(start: currentFrameIndex) {
                    guard let currentAnimatedFrame = animatedFrames[index] else { continue }
                    if !currentAnimatedFrame.isPlaceholder { continue }
                    animatedFrames[index] = currentAnimatedFrame.makeAnimatedFrame(image: loadFrame(at: index))
                }
            }

            private func incrementCurrentFrameIndex() {
                let wasLastFrame = isLastFrame
                currentFrameIndex = increment(frameIndex: currentFrameIndex)
                if isLastFrame {
                    currentRepeatCount += 1
                    if isReachMaxRepeatCount {
                        isFinished = true

                        // Notify the delegate here because the animation is stopping.
                        delegate?.animator(self, didPlayAnimationLoops: currentRepeatCount)
                    }
                } else if wasLastFrame {
                    // Notify the delegate that the loop completed
                    delegate?.animator(self, didPlayAnimationLoops: currentRepeatCount)
                }
            }

            private func incrementTimeSinceLastFrameChange(with duration: TimeInterval) {
                timeSinceLastFrameChange += min(maxTimeStep, duration)
            }

            private func resetTimeSinceLastFrameChange() {
                timeSinceLastFrameChange -= currentFrameDuration
            }

            private func increment(frameIndex: Int, by value: Int = 1) -> Int {
                return (frameIndex + value) % frameCount
            }

            private func preloadIndexes(start index: Int) -> [Int] {
                let nextIndex = increment(frameIndex: index)
                let lastIndex = increment(frameIndex: index, by: maxFrameCount)

                if lastIndex >= nextIndex {
                    return [Int](nextIndex ... lastIndex)
                } else {
                    return [Int](nextIndex ..< frameCount) + [Int](0 ... lastIndex)
                }
            }
        }
    }

    class SafeArray<Element> {
        private var array: [Element] = []
        private let lock = NSLock()

        subscript(index: Int) -> Element? {
            get {
                lock.lock()
                defer { lock.unlock() }
                return array.indices ~= index ? array[index] : nil
            }

            set {
                lock.lock()
                defer { lock.unlock() }
                if let newValue = newValue, array.indices ~= index {
                    array[index] = newValue
                }
            }
        }

        var count: Int {
            lock.lock()
            defer { lock.unlock() }
            return array.count
        }

        func reserveCapacity(_ count: Int) {
            lock.lock()
            defer { lock.unlock() }
            array.reserveCapacity(count)
        }

        func append(_ element: Element) {
            lock.lock()
            defer { lock.unlock() }
            array += [element]
        }

        func removeAll() {
            lock.lock()
            defer { lock.unlock() }
            array = []
        }
    }
#endif
