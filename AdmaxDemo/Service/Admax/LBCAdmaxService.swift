//
//  LBCAdmaxService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import UIKit

protocol LBCAdmaxServiceProtocol: AnyObject {
    func loadInterstitial()
    func loadBanner(adContainer: UIView)
    func stopBannerUnitAutoRefresh()
}

final class LBCAdmaxService: NSObject, LBCAdmaxServiceProtocol {
    private let adServerName: String
    private let bidderName: String
    private let request: LBCGAMRequestProtocol
    private weak var viewController: UIViewController?

    // MARK: - Dependencie
    private let googleMobileAdsService: LBCGoogleMobileAdsServiceProtocol
    private let sasDisplayKitService: LBCSASDisplayKitServiceProtocol
    private let admaxPrebidMobileService: LBCAdmaxPrebidMobileServiceProtocol

    // MARK: - AdUnit
    private var interstitialAdUnit: LBCGamInterstitialAdUnitProtocol?
    private var bannerAdUnit: LBCBannerAdUnitProtocol?

    // MARK: - Delegate
    private let adSizeDelegate = LBCAdSizeDelegate()
    private let sasBannerViewDelegate: LBCSASBannerViewDelegateProtocol = LBCSASBannerViewDelegate()
    private let gadBannerViewDelegate = LBCGADBannerViewDelegate()

    private lazy var bannerAppEventDelegate: LBCBannerGADAppEventDelegate? = {
        guard let bannerAdUnit = bannerAdUnit else { return nil }
        return LBCBannerGADAppEventDelegate(bannerAdUnit: bannerAdUnit)
    }()

    private lazy var gadInterstitialAppEventDelegate: LBCGADInterstitialAppEventDelegate? = {
        guard let viewController = self.viewController,
              let interstitialAdUnit = self.interstitialAdUnit
        else { return nil }

        return LBCGADInterstitialAppEventDelegate(
            interstitialAdUnit: interstitialAdUnit,
            viewController: viewController,
            gamInterstitial: self.googleMobileAdsService.gamInterstitial
        )
    }()

    private lazy var sasInterstitialManagerDelegate: LBCSASInterstitialManagerDelegate? = {
        guard let viewController = self.viewController,
              let interstitialAdUnit = self.interstitialAdUnit
        else { return nil }

        return LBCSASInterstitialManagerDelegate(
            interstitialAdUnit: interstitialAdUnit,
            viewController: viewController
        )
    }()


    init(adServerName: String,
         bidderName: String,
         viewController: UIViewController,
         googleMobileAdsService: LBCGoogleMobileAdsServiceProtocol = LBCServices.shared.googleMobileAdsService,
         sasDisplayKitService: LBCSASDisplayKitServiceProtocol = LBCServices.shared.sasDisplayKitService,
         admaxPrebidMobileService: LBCAdmaxPrebidMobileServiceProtocol = LBCServices.shared.admaxPrebidMobileService
    ) {
        self.adServerName = adServerName
        self.bidderName = bidderName
        self.viewController = viewController
        self.googleMobileAdsService = googleMobileAdsService
        self.request = googleMobileAdsService.createGAMRequest()
        self.sasDisplayKitService = sasDisplayKitService
        self.admaxPrebidMobileService = admaxPrebidMobileService
    }

    // MARK: - INTERSTITIAL

    func loadInterstitial() {
        guard let interstitialUnit = self.createGamInterstitialAdUnit() else { return }
        self.loadInterstialAccordingToAdServerName(interstitialUnit: interstitialUnit)
    }

    private func createGamInterstitialAdUnit() -> LBCGamInterstitialAdUnitProtocol? {
        guard let viewController = self.viewController else { return  nil }
        let configId = self.getInterstitialConfigId()
        let interstitialAdUnit = self.admaxPrebidMobileService
            .createGamInterstitialAdUnit(configId: configId, viewController: viewController)
        self.interstitialAdUnit = interstitialAdUnit
        return interstitialAdUnit
    }

    private func loadInterstialAccordingToAdServerName(interstitialUnit: LBCGamInterstitialAdUnitProtocol) {
        switch self.adServerName {
        case "Google": self.loadGoogleInterstitial(interstitialUnit: interstitialUnit)
        case "Smart": self.loadSmartInterstitial(interstitialUnit: interstitialUnit)
        default: return
        }
    }

    private func getInterstitialConfigId() -> String {
        var configId = ""

        switch self.bidderName {
        case "Xandr": configId = "dbe12cc3-b986-4b92-8ddb-221b0eb302ef"
        case "Criteo": configId = "5ba30daf-85c5-471c-93b5-5637f3035149"
        case "Smart": configId = "2cd143f6-bb9d-4ca9-9c4b-acb527657177"
        default: configId = ""
        }

        return configId
    }

    // MARK: Google

    private func loadGoogleInterstitial(interstitialUnit: LBCGamInterstitialAdUnitProtocol) {
        print("entered \(self.adServerName) loop")
        interstitialUnit.fetchLBCDemand(adObject: self.request) { resultCode in
            print("Prebid demand fetch for Google \(resultCode)")
            self.loadGAMInterstitialAd()
        }
    }

    private func loadGAMInterstitialAd() {
        self.googleMobileAdsService.gamInterstitial.load(withAdManagerAdUnitID: "/21807464892/pb_admax_interstitial",
                                                         request: self.request) { ad, error in
            guard let ad = ad else {
                return  print("Failed to load interstitial ad with error: \(error?.localizedDescription ?? "error")")
            }

            self.googleMobileAdsService.gamInterstitial = ad
            self.googleMobileAdsService.gamInterstitial.appEventDelegate = self.gadInterstitialAppEventDelegate
            self.findPrebidCreativeBidder(ad: ad)
        }
    }

    private func findPrebidCreativeBidder(ad object: NSObject) {
        self.admaxPrebidMobileService.findPrebidCreativeBidder(
            object,
            success: { bidder in print("bidder: \(bidder)") },
            failure: { error in
                print("error: \(error.localizedDescription)")
                guard let viewController = self.viewController else { return }
                self.googleMobileAdsService.gamInterstitial.present(fromRootViewController: viewController)
            }
        )
    }

    // MARK: Smart

    private func loadSmartInterstitial(interstitialUnit: LBCGamInterstitialAdUnitProtocol) {
        print("entered \(self.adServerName) loop")
        let sasInterstitialManager = self.createSASInterstitialManager()
        interstitialUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_interstitial")
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: interstitialUnit)

        interstitialUnit.fetchLBCDemand(adObject: admaxBidderAdapter) { resultCode in
            self.handleInterstitialSmartFetchDemand(resultCode: resultCode,
                                                    sasInterstitialManager: sasInterstitialManager,
                                                    admaxBidderAdapter: admaxBidderAdapter)
        }
    }

    private func createSASInterstitialManager() -> LBCSASInterstitialManagerProtocol {
        self.sasDisplayKitService.createSASInterstitialManager(siteId: 305017,
                                                               pageId: 1109572,
                                                               formatId: 80600,
                                                               delegate: self.sasInterstitialManagerDelegate)
    }

    private func handleInterstitialSmartFetchDemand(resultCode: LBCResultCode,
                                                    sasInterstitialManager: LBCSASInterstitialManagerProtocol,
                                                    admaxBidderAdapter: SASAdmaxBidderAdapter) {
        print("Prebid demand fetch for Smart \(resultCode)")
        switch resultCode {
        case .success: sasInterstitialManager.load(bidderAdapter: admaxBidderAdapter)
        case .failure: sasInterstitialManager.load()
        }
    }

    // MARK: - BANNER

    func stopBannerUnitAutoRefresh() {
        guard let bannerUnit = self.bannerAdUnit else { return }
        bannerUnit.stopAutoRefresh()
    }

    func loadBanner(adContainer: UIView) {
        let bannerAdUnit = self.createBannerAdUnit(adContainer: adContainer)
        self.loadBannerAccordingToAdServerName(adContainer: adContainer, bannerAdUnit: bannerAdUnit)
    }

    private func createBannerAdUnit(adContainer: UIView) -> LBCBannerAdUnitProtocol {
        let configId = self.getBannerConfigId()
        let size = CGSize(width: 320, height: 50)
        let bannerAdUnit = self.admaxPrebidMobileService.createBannerAdUnit(
            configId: configId,
            size: size,
            viewController: self.viewController,
            adContainer: adContainer
        )
//        self.bannerAdUnit.setAutoRefreshMillis(time: 35000)
        bannerAdUnit.adSizeDelegate = self.adSizeDelegate
        self.bannerAdUnit = bannerAdUnit
        return bannerAdUnit
    }

    private func getBannerConfigId() -> String {
        var configId = ""

        switch self.bidderName {
        case "Xandr": configId = "dbe12cc3-b986-4b92-8ddb-221b0eb302ef"
        case "Criteo": configId = "fb5fac4a-1910-4d3e-8a93-7bdbf6144312"
        case "Smart": configId = "fe7d0514-530c-4fb3-9a52-c91e7c426ba6"
        default: configId = ""
        }

        return configId
    }

    private func loadBannerAccordingToAdServerName(adContainer: UIView, bannerAdUnit: LBCBannerAdUnitProtocol) {
        switch self.adServerName {
        case "Google": self.loadGoogleBanner(adContainer: adContainer, bannerAdUnit: bannerAdUnit)
        case "Smart": self.loadSmartBanner(adContainer: adContainer, bannerAdUnit: bannerAdUnit)
        default: return
        }
    }

    // MARK: Google

    private func loadGoogleBanner(adContainer: UIView, bannerAdUnit: LBCBannerAdUnitProtocol) {
        print("entered \(self.adServerName) loop")
        let gamBannerView = self.createBannerView(adContainer: adContainer)
        bannerAdUnit.fetchLBCDemand(adObject: self.request) { resultCode in
            print("Prebid demand fetch for Google \(resultCode)")
            gamBannerView.load(self.request)
        }
    }

    private func createBannerView(adContainer: UIView) -> LBCGAMBannerViewProtocol {
        let gamBannerView = self.googleMobileAdsService.createBannerView(adUnitId: "/21807464892/pb_admax_320x50_top",
                                                                         rootViewController: self.viewController,
                                                                         delegate: self.gadBannerViewDelegate,
                                                                         appEventDelegate: self.bannerAppEventDelegate)
        adContainer.addSubview(gamBannerView)
        return gamBannerView
    }

    // MARK: Smart

    private func loadSmartBanner(adContainer: UIView, bannerAdUnit: LBCBannerAdUnitProtocol) {
        print("entered \(self.adServerName) loop")
        let sasBannerView = self.createSASBannerView(adContainer: adContainer)
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: bannerAdUnit)
        bannerAdUnit.fetchLBCDemand(adObject: admaxBidderAdapter) { resultCode in
            self.handleBannerSmartFetchDemand(resultCode: resultCode,
                                              sasBannerView: sasBannerView,
                                              bidderAdapter: admaxBidderAdapter)
        }
    }

    private func createSASBannerView(adContainer: UIView) -> LBCSASBannerViewProtocol {
        let sasBannerView = self.sasDisplayKitService.createSASBannerView(width: adContainer.frame.width,
                                                                          delegate: self.sasBannerViewDelegate,
                                                                          modalParentViewContorller: self.viewController)
        adContainer.addSubview(sasBannerView)
        return sasBannerView
    }

    private func handleBannerSmartFetchDemand(resultCode: LBCResultCode,
                                              sasBannerView: LBCSASBannerViewProtocol,
                                              bidderAdapter: SASAdmaxBidderAdapter) {
        print("Prebid demand fetch for Smart \(resultCode)")
        let sasAdPlacement = self.sasDisplayKitService.createSASAdPlacement(siteId: 305017,
                                                                            pageId: 1109572,
                                                                            formatId: 80250)
        switch resultCode {
        case .success: sasBannerView.load(with: sasAdPlacement, bidderAdapter: bidderAdapter)
        case .failure: sasBannerView.load(with: sasAdPlacement)
        }
    }
}
