//
//  LBCGADInterstitialAppEventDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

final class LBCGADInterstitialAppEventDelegate: NSObject, GADAppEventDelegate {
    private let interstitialAdUnit: LBCGamInterstitialAdUnitProtocol
    private let viewController: UIViewController
    private weak var gamInterstitial: LBCGAMInterstitialAdProtocol?

    init(interstitialAdUnit: LBCGamInterstitialAdUnitProtocol,
         viewController: UIViewController,
         gamInterstitial: LBCGAMInterstitialAdProtocol?) {
        self.interstitialAdUnit = interstitialAdUnit
        self.viewController = viewController
        self.gamInterstitial = gamInterstitial
    }

    func interstitialAd(_ interstitial: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD interstitialAd did receive app event")
        guard LBCAnalyticsEventTypeName.bidWon.rawValue == name else { return }
        self.interstitialAdUnit.isGoogleAdServerAd = false

        !self.interstitialAdUnit.isAdServerSdkRendering()
        ? self.interstitialAdUnit.loadAd()
        : self.gamInterstitial?.present(fromRootViewController: self.viewController)

    }
}
