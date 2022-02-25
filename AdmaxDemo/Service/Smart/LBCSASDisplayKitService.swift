//
//  LBCSASDisplayKitService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 25/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import UIKit

protocol LBCSASDisplayKitServiceProtocol: AnyObject {
    func createSASInterstitialManager(siteId: Int,
                                      pageId: Int,
                                      formatId: Int,
                                      delegate: LBCSASInterstitialManagerDelegate?) -> LBCSASInterstitialManager
    func createSASBannerView(width: CGFloat,
                             delegate: LBCSASBannerViewDelegateProtocol?,
                             modalParentViewContorller: UIViewController?) -> LBCSASBannerViewProtocol
}

final class LBCSASDisplayKitService: LBCSASDisplayKitServiceProtocol {
    func createSASInterstitialManager(siteId: Int, pageId: Int, formatId: Int, delegate: LBCSASInterstitialManagerDelegate?) -> LBCSASInterstitialManager {
        let sasAdPlacement = LBCSASAdPlacement(siteId: siteId,
                                               pageId: pageId,
                                               formatId: formatId)
        let sasInterstitialManager = LBCSASInterstitialManager(placement: sasAdPlacement,
                                                               delegate: delegate)
        delegate?.sasInterstitialManager = sasInterstitialManager
        return sasInterstitialManager
    }

    func createSASBannerView(width: CGFloat, delegate: LBCSASBannerViewDelegateProtocol?, modalParentViewContorller: UIViewController?) -> LBCSASBannerViewProtocol {
        let frame = CGRect(x: 0, y: 0, width: width, height: 50)
        let sasBannerView = LBCSASBannerView(frame: frame,
                                             delegate: delegate,
                                             modalParentViewController: modalParentViewContorller)
        return sasBannerView
    }
}
