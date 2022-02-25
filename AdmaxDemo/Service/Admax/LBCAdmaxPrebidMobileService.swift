//
//  LBCAdmaxPrebidMobileService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCAdmaxPrebidMobileServiceProtocol: AnyObject {
    func loadInterstitial()
    func loadBanner(adContainer: UIView)
    func stopBannerUnitAutoRefresh()
}

final class LBCAdmaxPrebidMobileService: NSObject, LBCAdmaxPrebidMobileServiceProtocol {
    private let adServerName: String
    private let bidderName: String
    private let request: LBCGAMRequestProtocol
    private weak var viewController: UIViewController?

    private let googleMobileAdsService: LBCGoogleMobileAdsServiceProtocol

    private var sasInterstitial: LBCSASInterstitialManager!
    private var interstitialUnit: GamInterstitialAdUnit!

    private var sasBanner: LBCSASBannerViewProtocol!

    private var bannerAdUnit: BannerAdUnit!
    private let sasBannerViewDelegate: LBCSASBannerViewDelegateProtocol = LBCSASBannerViewDelegate()
    private let gadBannerViewDelegate = LBCGADBannerViewDelegate()
    private lazy var bannerAppEventDelegate = LBCBannerGADAppEventDelegate(bannerAdUnit: self.bannerAdUnit)

    private lazy var gadInterstitialAppEventDelegate: LBCGADInterstitialAppEventDelegate? = {
        guard let viewController = self.viewController else { return nil }
        return LBCGADInterstitialAppEventDelegate(
            interstitialUnit: self.interstitialUnit,
            viewController: viewController,
            gamInterstitial: self.googleMobileAdsService.gamInterstitial
        )
    }()

    private lazy var sasInterstitialManagerDelegate: LBCSASInterstitialManagerDelegate? = {
        guard let viewController = viewController else { return nil }
        return LBCSASInterstitialManagerDelegate(
            interstitialUnit: self.interstitialUnit,
            viewController: viewController
        )
    }()


    init(adServerName: String,
         bidderName: String,
         viewController: UIViewController,
         googleMobileAdsService: LBCGoogleMobileAdsServiceProtocol = LBCServices.shared.googleMobileAdsService
    ) {
        self.adServerName = adServerName
        self.bidderName = bidderName
        self.viewController = viewController
        self.googleMobileAdsService = googleMobileAdsService
        self.request = googleMobileAdsService.createGAMRequest()
    }

    // MARK: - Interstitial

    func loadInterstitial() {
        guard let viewController = self.viewController else { return }
        let configId = self.getInterstitialConfigId()
        self.interstitialUnit = GamInterstitialAdUnit(configId: configId, viewController: viewController)
        self.loadInterstialAccordingToAdServerName()
    }

    private func loadInterstialAccordingToAdServerName() {
        switch self.adServerName {
        case "Google": self.loadGoogleInterstitial()
        case "Smart": self.loadSmartInterstitial()
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

    private func loadGoogleInterstitial() {
        print("entered \(self.adServerName) loop")
        self.interstitialUnit.fetchDemand(adObject: self.request) { resultCode in
            print("Prebid demand fetch for Google \(resultCode.name())")
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
        Utils.shared.findPrebidCreativeBidder(
            object,
            success: { bidder in print("bidder: \(bidder)") },
            failure: { error in
                print("error: \(error.localizedDescription)")
                guard let viewController = self.viewController else { return }
                self.googleMobileAdsService.gamInterstitial.present(fromRootViewController: viewController)
            }
        )
    }

    private func loadSmartInterstitial() {
        print("entered \(self.adServerName) loop")
        self.sasInterstitial = self.createSASInterstitialManager()
        self.interstitialUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_interstitial")
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: self.interstitialUnit)

        self.interstitialUnit.fetchDemand(adObject: admaxBidderAdapter) { resultCode in
            self.handleInterstitialSmartFetchDemand(resultCode: resultCode, admaxBidderAdapter: admaxBidderAdapter)
        }
    }

    private func handleInterstitialSmartFetchDemand(resultCode: ResultCode, admaxBidderAdapter: SASAdmaxBidderAdapter) {
        print("Prebid demand fetch for Smart \(resultCode.name())")
        guard let sasInterstitial = self.sasInterstitial else { return }
        switch resultCode {
        case .prebidDemandFetchSuccess: sasInterstitial.load(bidderAdapter: admaxBidderAdapter)
        default: sasInterstitial.load()
        }
    }

    private func createSASInterstitialManager() -> LBCSASInterstitialManager {
        let sasAdPlacement = LBCSASAdPlacement(siteId: 305017,
                                               pageId: 1109572,
                                               formatId: 80600)
        let sasInterstitialManager = LBCSASInterstitialManager(placement: sasAdPlacement,
                                                               delegate: self.sasInterstitialManagerDelegate)
        self.sasInterstitialManagerDelegate?.sasInterstitialManager = sasInterstitialManager
        return sasInterstitialManager
    }

    // MARK: - Banner

    func stopBannerUnitAutoRefresh() {
        guard let bannerUnit = self.bannerAdUnit else { return }
        bannerUnit.stopAutoRefresh()
    }

    func loadBanner(adContainer: UIView) {
        let configId = self.getBannerConfigId()
        self.bannerAdUnit = BannerAdUnit(configId: configId,
                                         size:  CGSize(width: 320, height: 50),
                                         viewController: self.viewController,
                                         adContainer: adContainer)
//        self.bannerAdUnit.setAutoRefreshMillis(time: 35000)
        self.bannerAdUnit.adSizeDelegate = self
        self.loadBannerAccordingToAdServerName(adContainer: adContainer)
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

    private func loadBannerAccordingToAdServerName(adContainer: UIView) {
        switch self.adServerName {
        case "Google": self.loadGoogleBanner(adContainer: adContainer)
        case "Smart": self.loadSmartBanner(adContainer: adContainer)
        default: return
        }
    }

    private func loadGoogleBanner(adContainer: UIView) {
        print("entered \(self.adServerName) loop")
        let gamBannerView = self.googleMobileAdsService.createBannerView(adUnitId: "/21807464892/pb_admax_320x50_top",
                                                                         rootViewController: self.viewController,
                                                                         delegate: self.gadBannerViewDelegate,
                                                                         appEventDelegate: self.bannerAppEventDelegate)
        adContainer.addSubview(gamBannerView)
        self.bannerAdUnit.fetchDemand(adObject: self.request) { resultCode in
            print("Prebid demand fetch for Google \(resultCode.name())")
            gamBannerView.load(self.request)
        }
    }

    private func loadSmartBanner(adContainer: UIView) {
        print("entered \(self.adServerName) loop")
        self.setupSASBanner(adContainer: adContainer)
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: self.bannerAdUnit)
        self.bannerAdUnit.fetchDemand(adObject: admaxBidderAdapter) { resultCode in
            self.handleBannerSmartFetchDemand(resultCode: resultCode, bidderAdapter: admaxBidderAdapter)
        }
    }

    private func handleBannerSmartFetchDemand(resultCode: ResultCode, bidderAdapter: SASAdmaxBidderAdapter) {
        print("Prebid demand fetch for Smart \(resultCode.name())")
        let sasAdPlacement = LBCSASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80250)

        switch resultCode {
        case .prebidDemandFetchSuccess: self.sasBanner.load(with: sasAdPlacement, bidderAdapter: bidderAdapter)
        default: self.sasBanner.load(with: sasAdPlacement)
        }
    }

    private func setupSASBanner(adContainer: UIView) {
        let frame = CGRect(x: 0, y: 0, width: adContainer.frame.width, height: 50)
        self.sasBanner = LBCSASBannerView(frame: frame)
        self.sasBanner.delegate = self.sasBannerViewDelegate
        self.sasBanner.modalParentViewController = self.viewController
        adContainer.addSubview(self.sasBanner)
    }
}

extension LBCAdmaxPrebidMobileService: AdSizeDelegate {
    func onAdLoaded(adUnit: AdUnit, size: CGSize, adContainer: UIView) {
        print("ADMAX onAdLoaded with Size: \(size)")
    }
}
