//
//  LBCSASInterstitialManagerDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import SASDisplayKit

final class LBCSASInterstitialManagerDelegate: NSObject, SASInterstitialManagerDelegate {
    weak var sasInterstitialManager: SASInterstitialManager?
    private let interstitialAdUnit: LBCGamInterstitialAdUnitProtocol
    private let viewController: UIViewController

    init(interstitialAdUnit: LBCGamInterstitialAdUnitProtocol,
         viewController: UIViewController) {
        self.interstitialAdUnit = interstitialAdUnit
        self.viewController = viewController
    }

    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        guard self.sasInterstitialManager == manager,
              self.interstitialAdUnit.isSmartAdServerSdkRendering()
        else { return }
        print("Interstitial ad has been loaded")
        self.sasInterstitialManager?.show(from: self.viewController)
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToLoadWithError error: Error) {
        guard self.sasInterstitialManager == manager else { return }
        print("Interstitial ad did fail to load: \(error.localizedDescription)")
        self.interstitialAdUnit.createDfpOnlyInterstitial()
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToShowWithError error: Error) {
        guard self.sasInterstitialManager == manager else { return }
        print("Interstitial ad did fail to show: \(error.localizedDescription)")
    }

    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        guard self.sasInterstitialManager == manager else { return }
        print("Interstitial ad did appear")
    }

    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        guard self.sasInterstitialManager == manager else { return }
        print("Interstitial ad did disappear")
    }
}
