//
//  LBCInterstitialViewModel.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile
import GoogleMobileAds
import SASDisplayKit

final class LBCInterstitialViewModel: NSObject {
    private let adServerName: String
    private let bidderName: String
    private let request = GAMRequest()
    private var sasInterstitial: SASInterstitialManager!
    private var interstitialUnit: GamInterstitialAdUnit!
    private var dfpInterstitial: GAMInterstitialAd!
    private weak var viewController: UIViewController?

    init(adServerName: String, bidderName: String, viewController: UIViewController) {
        self.adServerName = adServerName
        self.bidderName = bidderName
        self.viewController = viewController
    }

    func loadInterstitial() {
        guard let viewController = viewController else { return }

        if self.bidderName == "Xandr" {
            self.interstitialUnit = GamInterstitialAdUnit(configId: "dbe12cc3-b986-4b92-8ddb-221b0eb302ef", viewController: viewController)
        } else if self.bidderName == "Criteo" {
            self.interstitialUnit = GamInterstitialAdUnit(configId: "5ba30daf-85c5-471c-93b5-5637f3035149", viewController: viewController)
        } else if self.bidderName == "Smart" {
            self.interstitialUnit = GamInterstitialAdUnit(configId: "2cd143f6-bb9d-4ca9-9c4b-acb527657177", viewController: viewController)
        }

        if self.adServerName == "DFP" {
            print("entered \(self.adServerName) loop" )
            self.loadDFPInterstitial(adUnit: self.interstitialUnit)
        } else if self.adServerName == "Smart" {
            print("entered \(self.adServerName) loop")
            self.loadSmartInterstitial(adUnit: self.interstitialUnit)
        }
    }

    private func loadDFPInterstitial(adUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        adUnit.fetchDemand(adObject: self.request) { (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            GAMInterstitialAd.load(withAdManagerAdUnitID: "/21807464892/pb_admax_interstitial", request: self.request) { ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    self.dfpInterstitial = ad
                    self.dfpInterstitial.appEventDelegate = self
                    Utils.shared.findPrebidCreativeBidder(
                        ad,
                        success: { (bidder) in
                            print("bidder: \(bidder)")},
                        failure: { (error) in
                            print("error: \(error.localizedDescription)")
                            if let viewController = self.viewController {
                                self.dfpInterstitial?.present(fromRootViewController: viewController)
                            }
                        }
                    )
                }
            }
        }
    }

    private func loadSmartInterstitial(adUnit: AdUnit) {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80600)
        self.sasInterstitial = SASInterstitialManager(placement: sasAdPlacement, delegate: self)
        guard let adUnit = adUnit as? GamInterstitialAdUnit else { return }
        adUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_interstitial")
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: adUnit)

        adUnit.fetchDemand(adObject: admaxBidderAdapter) { resultCode in
            print("Prebid demand fetch for Smart \(resultCode.name())")
            if resultCode == ResultCode.prebidDemandFetchSuccess {
                self.sasInterstitial!.load(bidderAdapter: admaxBidderAdapter)
            } else {
                self.sasInterstitial!.load()
            }
        }
    }
}

extension LBCInterstitialViewModel: GADAppEventDelegate {
    func interstitialAd(_ interstitial: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD interstitialAd did receive app event")
        if (AnalyticsEventType.bidWon.name() == name) {
            self.interstitialUnit.isGoogleAdServerAd = false
            if !self.interstitialUnit.isAdServerSdkRendering() {
                self.interstitialUnit.loadAd()
            } else {
                guard let viewController = self.viewController else { return }
                self.dfpInterstitial?.present(fromRootViewController: viewController)
            }
        }
    }
}

extension LBCInterstitialViewModel: SASInterstitialManagerDelegate {
    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad has been loaded")
            if interstitialUnit.isSmartAdServerSdkRendering() {
                guard let viewController = viewController else { return }
                self.sasInterstitial.show(from: viewController)
            }
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToLoadWithError error: Error) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did fail to load: \(error.localizedDescription)")
            self.interstitialUnit.createDfpOnlyInterstitial()
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToShowWithError error: Error) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did fail to show: \(error.localizedDescription)")
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did appear")
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did disappear")
        }
    }
}
