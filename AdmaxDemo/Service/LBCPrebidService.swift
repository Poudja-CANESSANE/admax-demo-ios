//
//  LBCPrebidService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCPrebidServiceProtocol: AnyObject {
    var admaxConfig: Data? { get }

    func start()
}

final class LBCPrebidService: LBCPrebidServiceProtocol {
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
}
