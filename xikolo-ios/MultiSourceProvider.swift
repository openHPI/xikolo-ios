//
//  MultiSourceProvider.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 26.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

protocol MultiSourceProvider {
    
    typealias T
    
    static func getObservable() -> Observable<T>
    
    static func getLocalDataObservable() -> Observable<T>
    static func getNetworkDataObservable() -> Observable<T>

}
