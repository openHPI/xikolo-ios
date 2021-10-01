//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import MobileCoreServices
import UIKit

class AsyncImageTextAttachment: NSTextAttachment {

    typealias LayoutChangeHandler = () -> Void
    typealias ImageLoader = (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask

    public var imageLoader: ImageLoader
    public var imageURL: URL
    public var layoutChangeHandler: LayoutChangeHandler?
    public var placeHolderImage: UIImage?

    private var downloadTask: URLSessionTask?
    private var imageSize: CGSize?

    public init(imageLoader: @escaping ImageLoader, imageURL: URL, layoutChangeHandler: LayoutChangeHandler? = nil, placeHolderImage: UIImage? = nil) {
        self.imageLoader = imageLoader
        self.imageURL = imageURL
        self.layoutChangeHandler = layoutChangeHandler
        self.placeHolderImage = placeHolderImage
        self.imageSize = self.placeHolderImage?.size

        super.init(data: nil, ofType: nil)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func startAsyncImageDownload(in textContainer: NSTextContainer?) {
        guard self.contents == nil, self.downloadTask == nil else { return }

        self.downloadTask = self.imageLoader(self.imageURL) { data, _, error in
            defer {
                self.downloadTask = nil
            } // done with the task

            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }

            var displaySizeChanged = false

            self.contents = data

            let ext = self.imageURL.pathExtension as CFString
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, nil) {
                self.fileType = uti.takeRetainedValue() as String
            }

            if let image = UIImage(data: data) {
                let newImageSize = image.size
                displaySizeChanged = newImageSize != self.imageSize
                self.imageSize = newImageSize
            } else {
                displaySizeChanged = self.imageSize != .zero
                self.imageSize = .zero
            }

            DispatchQueue.main.async {
                // tell layout manager so that it should refresh
                if displaySizeChanged {
                    textContainer?.layoutManager?.setNeedsLayout(forAttachment: self)
                    self.layoutChangeHandler?()
                } else {
                    textContainer?.layoutManager?.setNeedsDisplay(forAttachment: self)
                }
            }
        }

        self.downloadTask?.resume()
    }

    override public func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        guard let contents = self.contents, let image = UIImage(data: contents) else {
            self.startAsyncImageDownload(in: textContainer)
            return self.placeHolderImage
        }

        return image
    }

    override public func attachmentBounds(for textContainer: NSTextContainer?,
                                          proposedLineFragment lineFrag: CGRect,
                                          glyphPosition position: CGPoint,
                                          characterIndex charIndex: Int) -> CGRect {

        guard let imageSize = self.imageSize, imageSize.width > 0 else { return .zero }

        let factor = lineFrag.size.width / imageSize.width
        let size = CGSize(width: imageSize.width * factor, height: imageSize.height * factor)
        return CGRect(origin: .zero, size: size)
    }

}
