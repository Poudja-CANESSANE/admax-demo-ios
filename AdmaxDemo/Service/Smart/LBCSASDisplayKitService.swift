//
//  LBCSASDisplayKitService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 25/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import SASDisplayKit

protocol LBCSASDisplayKitServiceProtocol: AnyObject {
    func start()
    func createSASInterstitialManager(siteId: Int,
                                      pageId: Int,
                                      formatId: Int,
                                      delegate: LBCSASInterstitialManagerDelegate?) -> LBCSASInterstitialManagerProtocol
    func createSASAdPlacement(siteId: Int,
                              pageId: Int,
                              formatId: Int) -> LBCSASAdPlacementProtocol
    func createSASBannerView(width: CGFloat,
                             delegate: LBCSASBannerViewDelegateProtocol?,
                             modalParentViewContorller: UIViewController?) -> LBCSASBannerViewProtocol
}

final class LBCSASDisplayKitService: LBCSASDisplayKitServiceProtocol {
    private let SAS_SITE_ID: Int = 305017

    func start() {
        SASConfiguration.shared.configure(siteId: self.SAS_SITE_ID)
        SASConfiguration.shared.loggingEnabled = true
    }

    func createSASInterstitialManager(siteId: Int, pageId: Int, formatId: Int, delegate: LBCSASInterstitialManagerDelegate?) -> LBCSASInterstitialManagerProtocol {
        let sasAdPlacement = self.createSASAdPlacement(siteId: siteId, pageId: pageId, formatId: formatId)
        let sasInterstitialManager = SASInterstitialManager(placement: sasAdPlacement,
                                                            delegate: delegate)
        delegate?.sasInterstitialManager = sasInterstitialManager
        return sasInterstitialManager
    }

    func createSASAdPlacement(siteId: Int, pageId: Int, formatId: Int) -> LBCSASAdPlacementProtocol {
        return SASAdPlacement(siteId: siteId, pageId: pageId, formatId: formatId)
    }

    func createSASBannerView(width: CGFloat, delegate: LBCSASBannerViewDelegateProtocol?, modalParentViewContorller: UIViewController?) -> LBCSASBannerViewProtocol {
        let frame = CGRect(x: 0, y: 0, width: width, height: 50)
        let sasBannerView = LBCSASBannerView(frame: frame,
                                             delegate: delegate,
                                             modalParentViewController: modalParentViewContorller)
        return sasBannerView
    }
}
