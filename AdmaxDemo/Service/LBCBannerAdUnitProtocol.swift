//
//  LBCBannerAdUnitProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCBannerAdUnitProtocol: AnyObject {
    var isGoogleAdServerAd: Bool { get set }

    func isAdServerSdkRendering() -> Bool
    func loadAd()
}

extension BannerAdUnit: LBCBannerAdUnitProtocol {}
