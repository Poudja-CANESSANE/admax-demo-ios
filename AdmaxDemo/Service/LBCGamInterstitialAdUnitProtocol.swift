//
//  LBCGamInterstitialAdUnitProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCGamInterstitialAdUnitProtocol: LBCAdUnitProtocol {
    var isGoogleAdServerAd: Bool { get set }

    func isAdServerSdkRendering() -> Bool
    func loadAd()
    func isSmartAdServerSdkRendering() -> Bool
    func createDfpOnlyInterstitial()
}

extension GamInterstitialAdUnit: LBCGamInterstitialAdUnitProtocol {}

