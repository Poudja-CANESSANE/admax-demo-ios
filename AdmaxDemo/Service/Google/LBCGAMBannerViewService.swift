//
//  LBCGAMBannerViewService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

protocol LBCGAMBannerViewProtocol: UIView {
    var adUnitID: String? { get set }
    var rootViewController: UIViewController? { get set }
    var delegate: GADBannerViewDelegate? { get set }
    var appEventDelegate: GADAppEventDelegate? { get set }

    func load(_ request: GADRequest?)
}

protocol LBCGAMBannerViewServiceProtocol: AnyObject {
    func createBannerView(adUnitId: String,
                          rootViewController: UIViewController?,
                          delegate: GADBannerViewDelegate?,
                          appEventDelegate: GADAppEventDelegate?) -> LBCGAMBannerViewProtocol
    func load(_ request: GADRequest?)
}

extension GAMBannerView: LBCGAMBannerViewProtocol {}

final class LBCGAMBannerViewService: LBCGAMBannerViewServiceProtocol {
    private var gamBannerView: GAMBannerView?

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
