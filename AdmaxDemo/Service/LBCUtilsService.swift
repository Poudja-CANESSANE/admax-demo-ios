//
//  LBCUtilsService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCUtilsServiceProtocol: AnyObject {
    func findPrebidCreativeSize(_ adView: UIView,
                                success: @escaping (CGSize) -> Void,
                                failure: @escaping (Error) -> Void)
}

final class LBCUtilsService: LBCUtilsServiceProtocol {
    func findPrebidCreativeSize(_ adView: UIView,
                                success: @escaping (CGSize) -> Void,
                                failure: @escaping (Error) -> Void) {
        Utils.shared.findPrebidCreativeSize(adView, success: success, failure: failure)
    }
}

