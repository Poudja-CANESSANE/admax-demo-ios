//
//  LBCGoogleMobileAdsService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 24/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

protocol LBCGoogleMobileAdsServiceProtocol: AnyObject {
    var gamInterstitial: LBCGAMInterstitialAdProtocol { get set }

    func start(completion: GADInitializationCompletionHandler?)
    func createGAMRequest() -> LBCGAMRequestProtocol
    func createBannerView(adUnitId: String,
                          rootViewController: UIViewController?,
                          delegate: GADBannerViewDelegate?,
                          appEventDelegate: GADAppEventDelegate?) -> LBCGAMBannerViewProtocol
    func load(_ request: GADRequest?)
}

final class LBCGoogleMobileAdsService: LBCGoogleMobileAdsServiceProtocol {
    var gamInterstitial: LBCGAMInterstitialAdProtocol = GAMInterstitialAd()
    private var gamBannerView: GAMBannerView?

    func start(completion: GADInitializationCompletionHandler? = nil) {
        GADMobileAds.sharedInstance().start(completionHandler: completion)
    }

    func createGAMRequest() -> LBCGAMRequestProtocol {
        return GAMRequest()
    }

    func createBannerView(adUnitId: String,
                          rootViewController: UIViewController?,
                          delegate: GADBannerViewDelegate?,
                          appEventDelegate: GADAppEventDelegate?) -> LBCGAMBannerViewProtocol {
        let bannerView = GAMBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = rootViewController
        bannerView.delegate = delegate
        bannerView.appEventDelegate = appEventDelegate
        self.gamBannerView = bannerView
        return bannerView
    }

    func load(_ request: GADRequest?) {
        self.gamBannerView?.load(request)
    }
}
