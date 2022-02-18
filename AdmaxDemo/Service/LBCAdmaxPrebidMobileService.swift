//
//  LBCAdmaxPrebidMobileService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile
import GoogleMobileAds
import SASDisplayKit

protocol LBCAdmaxPrebidMobileServiceProtocol: AnyObject {
    func loadInterstitial()
}

final class LBCAdmaxPrebidMobileService: NSObject, LBCAdmaxPrebidMobileServiceProtocol {
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
        guard let viewController = self.viewController else { return }
        let configId = self.getConfigId()
        self.interstitialUnit = GamInterstitialAdUnit(configId: configId, viewController: viewController)
        self.loadInterstialAccordingToAdServerName()
    }

    private func loadInterstialAccordingToAdServerName() {
        switch self.adServerName {
        case "DFP": self.loadDFPInterstitial()
        case "Smart": self.loadSmartInterstitial()
        default: return
        }
    }

    private func getConfigId() -> String {
        var configId = ""

        switch self.bidderName {
        case "Xandr": configId = "dbe12cc3-b986-4b92-8ddb-221b0eb302ef"
        case "Criteo": configId = "5ba30daf-85c5-471c-93b5-5637f3035149"
        case "Smart": configId = "2cd143f6-bb9d-4ca9-9c4b-acb527657177"
        default: configId = ""
        }

        return configId
    }

    private func loadDFPInterstitial() {
        print("entered \(self.adServerName) loop")
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        self.interstitialUnit.fetchDemand(adObject: self.request) { resultCode in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self.loadGAMInterstitialAd()
        }
    }

    private func loadGAMInterstitialAd() {
        GAMInterstitialAd.load(withAdManagerAdUnitID: "/21807464892/pb_admax_interstitial",
                               request: self.request) { ad, error in
            guard let ad = ad else {
                return  print("Failed to load interstitial ad with error: \(error?.localizedDescription ?? "error")")
            }

            self.dfpInterstitial = ad
            self.dfpInterstitial.appEventDelegate = self
            self.findPrebidCreativeBidder(ad: ad)
        }
    }

    private func findPrebidCreativeBidder(ad: GAMInterstitialAd) {
        Utils.shared.findPrebidCreativeBidder(
            ad,
            success: { bidder in
                print("bidder: \(bidder)")},
            failure: { error in
                print("error: \(error.localizedDescription)")
                if let viewController = self.viewController {
                    self.dfpInterstitial?.present(fromRootViewController: viewController)
                }
            }
        )
    }

    private func loadSmartInterstitial() {
        print("entered \(self.adServerName) loop")
        self.sasInterstitial = self.createSASInterstitialManager()
        self.interstitialUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_interstitial")
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: self.interstitialUnit)

        self.interstitialUnit.fetchDemand(adObject: admaxBidderAdapter) { resultCode in
            self.handleSmartFetchDemand(resultCode: resultCode, admaxBidderAdapter: admaxBidderAdapter)
        }
    }

    private func handleSmartFetchDemand(resultCode: ResultCode, admaxBidderAdapter: SASAdmaxBidderAdapter) {
        print("Prebid demand fetch for Smart \(resultCode.name())")
        guard let sasInterstitial = self.sasInterstitial else { return }
        switch resultCode {
        case .prebidDemandFetchSuccess: sasInterstitial.load(bidderAdapter: admaxBidderAdapter)
        default: sasInterstitial.load()
        }
    }

    private func createSASInterstitialManager() -> SASInterstitialManager {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017,
                                                            pageId: 1109572,
                                                            formatId: 80600)
        return SASInterstitialManager(placement: sasAdPlacement, delegate: self)
    }
}

extension LBCAdmaxPrebidMobileService: GADAppEventDelegate {
    func interstitialAd(_ interstitial: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD interstitialAd did receive app event")
        guard AnalyticsEventType.bidWon.name() == name else { return }
        self.interstitialUnit.isGoogleAdServerAd = false

        if !self.interstitialUnit.isAdServerSdkRendering() {
            self.interstitialUnit.loadAd()
        } else {
            guard let viewController = self.viewController else { return }
            self.dfpInterstitial?.present(fromRootViewController: viewController)
        }

    }
}

extension LBCAdmaxPrebidMobileService: SASInterstitialManagerDelegate {
    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        guard self.sasInterstitial == manager,
              self.interstitialUnit.isSmartAdServerSdkRendering(),
              let viewController = viewController
        else { return }
        print("Interstitial ad has been loaded")
        self.sasInterstitial.show(from: viewController)
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToLoadWithError error: Error) {
        guard self.sasInterstitial == manager else { return }
        print("Interstitial ad did fail to load: \(error.localizedDescription)")
        self.interstitialUnit.createDfpOnlyInterstitial()
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToShowWithError error: Error) {
        guard self.sasInterstitial == manager else { return }
        print("Interstitial ad did fail to show: \(error.localizedDescription)")
    }

    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        guard self.sasInterstitial == manager else { return }
        print("Interstitial ad did appear")
    }

    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        guard self.sasInterstitial == manager else { return }
        print("Interstitial ad did disappear")
    }
}
