//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 15.0, *)
class QuizRecapViewController: UIViewController {

    let configuration: QuizRecapConfiguration
    private lazy var content = makeContentViewController()

    init(configuration: QuizRecapConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add our header view controller as a child:
        addChild(content)
        view.addSubview(content.view)
        content.didMove(toParent: self)

        // Apply a series of Auto Layout constraints to its view:
        NSLayoutConstraint.activate([
            content.view.topAnchor.constraint(equalTo: view.topAnchor),
            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func makeContentViewController() -> UIHostingController<QuizRecapView> {
        let contentView = QuizRecapView(configuration: configuration) {
            self.dismiss(animated: trueUnlessReduceMotionEnabled, completion: nil)
        }
        let contentViewController = UIHostingController(rootView: contentView)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        return contentViewController
    }

}


//@available(iOS 14.0, *)
//struct QuizRecapView: View {
//    let configuration: QuizRecapConfiguration
//    var dismissAction: (() -> Void)
//
//    var body: some View {
//        ZStack {
//            Color.blue
//                .ignoresSafeArea()
//            
//            VStack() {
//                HStack {
//                    Spacer()
//                    Button {
//                        dismissAction()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.secondary)
//                            .frame(width: 44)
//                    }
//                    .padding()
//                }
//
//                Spacer()
//                Image(systemName: "questionmark.app.fill")
//                Text("Quiz Recap")
//                    .font(.title)
//            }
//        }
//        .navigationBarHidden(true)
//
//    }
//}
//
//@available(iOS 14.0, *)
//struct QuizRecapView_Previews: PreviewProvider {
//    static var configuration = QuizRecapConfiguration(courseId: "", sectionIds: [], onlyVisitedItems: true, questionLimit: nil)
//    static var previews: some View {
//        Group {
//            QuizRecapView(configuration: configuration, dismissAction: {})
//        }
//    }
//}


