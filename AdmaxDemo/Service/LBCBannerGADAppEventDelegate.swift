//
//  LBCBannerGADAppEventDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

final class LBCBannerGADAppEventDelegate: NSObject, GADAppEventDelegate {
    private let bannerAdUnit: LBCBannerAdUnitProtocol

    init(bannerAdUnit: LBCBannerAdUnitProtocol) {
        self.bannerAdUnit = bannerAdUnit
    }

    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD adView didReceiveAppEvent")
        if name == LBCAnalyticsEventTypeName.bidWon.rawValue {
            self.bannerAdUnit.isGoogleAdServerAd = false
            if !self.bannerAdUnit.isAdServerSdkRendering() {
                self.bannerAdUnit.loadAd()
            }
        }
    }
}
