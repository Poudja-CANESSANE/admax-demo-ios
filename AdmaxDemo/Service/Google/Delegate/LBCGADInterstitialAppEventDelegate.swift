//
//  LBCGADInterstitialAppEventDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

final class LBCGADInterstitialAppEventDelegate: NSObject, GADAppEventDelegate {
    private let interstitialUnit: LBCGamInterstitialAdUnitProtocol
    private let viewController: UIViewController
    private let gamInterstitial: LBCGAMInterstitialAdProtocol

    init(interstitialUnit: LBCGamInterstitialAdUnitProtocol,
         viewController: UIViewController,
         gamInterstitial: LBCGAMInterstitialAdProtocol) {
        self.interstitialUnit = interstitialUnit
        self.viewController = viewController
        self.gamInterstitial = gamInterstitial
    }

    func interstitialAd(_ interstitial: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD interstitialAd did receive app event")
        guard LBCAnalyticsEventTypeName.bidWon.rawValue == name else { return }
        self.interstitialUnit.isGoogleAdServerAd = false

        !self.interstitialUnit.isAdServerSdkRendering()
        ? self.interstitialUnit.loadAd()
        : self.gamInterstitial.present(fromRootViewController: self.viewController)

    }
}
