//
//  LBCAdUnitProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

typealias LBCAdUnitServiceHandler = (_ result: LBCResultCode) -> Void

protocol LBCAdUnitProtocol: AnyObject {
    var isGoogleAdServerAd: Bool { get set }
    var isSmartAdServerAd: Bool { get set }
    var adSizeDelegate: AdSizeDelegate? { get set }

    func isAdServerSdkRendering() -> Bool
    func isSmartAdServerSdkRendering() -> Bool
    func loadAd()
    func stopAutoRefresh()
    func fetchLBCDemand(adObject: AnyObject, completion: @escaping LBCAdUnitServiceHandler)
}

extension AdUnit: LBCAdUnitProtocol {
    func fetchLBCDemand(adObject: AnyObject, completion: @escaping LBCAdUnitServiceHandler) {
        self.fetchDemand(adObject: adObject) { result in
            completion(result.convertToLBCResultCode())
        }
    }
}

