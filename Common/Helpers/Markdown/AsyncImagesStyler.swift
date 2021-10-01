//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Down

class AsyncImagesStyler: DownStyler {

    typealias LayoutChangeHandler = () -> Void
    typealias ImageLoader = (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask

    let layoutChangeHandler: AsyncImageTextAttachment.LayoutChangeHandler?
    let imageLoader: AsyncImageTextAttachment.ImageLoader

    init(imageLoader: @escaping ImageLoader = URLSession.shared.dataTask(with:completionHandler:),
         layoutChangeHandler: LayoutChangeHandler? = nil,
         configuration: DownStylerConfiguration = DownStylerConfiguration()) {
        self.imageLoader = imageLoader
        self.layoutChangeHandler = layoutChangeHandler
        super.init(configuration: configuration)
    }

    override func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }

        let placeHolderColor: UIColor = {
            if #available(iOS 13, *) {
                return .tertiarySystemFill
            } else {
                return .lightGray
            }
        }()

        let placeHolderImage = UIImage.placeholder(withColor: placeHolderColor, size: CGSize(width: 2, height: 1))
        let attachment = AsyncImageTextAttachment(imageLoader: self.imageLoader,
                                                  imageURL: url,
                                                  layoutChangeHandler: self.layoutChangeHandler,
                                                  placeHolderImage: placeHolderImage)
        let attachmentString = NSAttributedString(attachment: attachment)

        let range = NSRange(location: 0, length: str.length)
        str.replaceCharacters(in: range, with: attachmentString)
    }

}
