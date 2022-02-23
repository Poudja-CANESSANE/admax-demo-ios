//
//  LBCSASBannerViewDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import SASDisplayKit

protocol LBCSASBannerViewDelegateProtocol: SASBannerViewDelegate {}

final class LBCSASBannerViewDelegate: NSObject, LBCSASBannerViewDelegateProtocol {
    func bannerViewDidLoad(_ bannerView: SASBannerView) {
        print("SAS bannerViewDidLoad")
    }

    func bannerView(_ bannerView: SASBannerView, didFailToLoadWithError error: Error) {
        print("SAS bannerView:didFailToLoadWithError: \(error.localizedDescription)")
    }
}
