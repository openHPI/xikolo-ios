//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//
//  Based on the work of https://github.com/Cocoanetics/Swift-Examples/tree/master/Attachments
//

import MobileCoreServices
import UIKit

/// An image text attachment that gets loaded from a remote URL
public class AsyncImageTextAttachment: NSTextAttachment {

    public var imageLoader: ImageLoader.Type
    public var imageURL: URL
    public var layoutChangeHandler: (() -> Void)?
    public var placeHolderImage: UIImage?

    private var downloadTask: URLSessionTask?
    private var imageSize: CGSize?

    public init(imageLoader: ImageLoader.Type, imageURL: URL, layoutChangeHandler: (() -> Void)? = nil, placeHolderImage: UIImage? = nil) {
        self.imageLoader = imageLoader
        self.imageURL = imageURL
        self.layoutChangeHandler = layoutChangeHandler
        self.placeHolderImage = placeHolderImage
        self.imageSize = self.placeHolderImage?.size

        super.init(data: nil, ofType: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func startAsyncImageDownload(in textContainer: NSTextContainer?) {
        guard self.contents == nil, self.downloadTask == nil else { return }

        self.downloadTask = self.imageLoader.dataTask(for: self.imageURL) { (data, response, error) in
            defer {
                self.downloadTask = nil // done with the task
            }

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

    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        guard let contents = self.contents, let image = UIImage(data: contents) else {
            self.startAsyncImageDownload(in: textContainer)
            return self.placeHolderImage
        }

        return image
    }

    public override func attachmentBounds(for textContainer: NSTextContainer?,
                                          proposedLineFragment lineFrag: CGRect,
                                          glyphPosition position: CGPoint,
                                          characterIndex charIndex: Int) -> CGRect {

        guard let imageSize = self.imageSize, imageSize.width > 0 else { return .zero }

        let factor = lineFrag.size.width / imageSize.width
        let size = CGSize(width: imageSize.width * factor, height: imageSize.height * factor)
        return CGRect(origin: .zero, size: size)
    }

}
