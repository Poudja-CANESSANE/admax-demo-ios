//
//  LBCAdmaxPrebidMobileService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 28/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCAdmaxPrebidMobileServiceProtocol: AnyObject {
    var admaxConfig: Data? { get }

    func start()
    func getKeyvaluePrefix(admaxConfig: Data?) -> String
    func findPrebidCreativeSize(_ adView: UIView,
                                success: @escaping (CGSize) -> Void,
                                failure: @escaping (Error) -> Void)
}

final class LBCAdmaxPrebidMobileService: LBCAdmaxPrebidMobileServiceProtocol {
    var admaxConfig: Data? {
        return Prebid.shared.admaxConfig
    }

    func start() {
        Prebid.shared.loggingEnabled = true
        Prebid.shared.admaxExceptionLogger = DemoAdmaxExceptionLogger()
        Prebid.shared.prebidServerAccountId = "4803423e-c677-4993-807f-6a1554477ced"
        Prebid.shared.shareGeoLocation = true
        Prebid.shared.initAdmaxConfig()
    }

    func getKeyvaluePrefix(admaxConfig: Data?) -> String {
        AdmaxConfigUtil.getKeyvaluePrefix(admaxConfig: admaxConfig)
    }

    func findPrebidCreativeSize(_ adView: UIView,
                                success: @escaping (CGSize) -> Void,
                                failure: @escaping (Error) -> Void) {
        Utils.shared.findPrebidCreativeSize(adView, success: success, failure: failure)
    }
}
