//
//  LBCGADAppEventDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds
import AdmaxPrebidMobile

final class LBCGADAppEventDelegate: NSObject, GADAppEventDelegate {
    private let interstitialUnit: LBCGamInterstitialAdUnitProtocol
    private let viewController: UIViewController
    private let dfpInterstitial: GAMInterstitialAd

    init(interstitialUnit: LBCGamInterstitialAdUnitProtocol,
         viewController: UIViewController,
         dfpInterstitial: GAMInterstitialAd) {
        self.interstitialUnit = interstitialUnit
        self.viewController = viewController
        self.dfpInterstitial = dfpInterstitial
    }

    func interstitialAd(_ interstitial: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD interstitialAd did receive app event")
        guard name == AnalyticsEventType.bidWon.name() else { return }
        self.interstitialUnit.isGoogleAdServerAd = false

        !self.interstitialUnit.isAdServerSdkRendering()
        ? self.interstitialUnit.loadAd()
        : self.dfpInterstitial.present(fromRootViewController: viewController)

    }
}
