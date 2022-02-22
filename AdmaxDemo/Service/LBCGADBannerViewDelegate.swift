//
//  LBCGADBannerViewDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

final class LBCGADBannerViewDelegate: NSObject, GADBannerViewDelegate {
    private let utilsService: LBCUtilsServiceProtocol

    init(utilsService: LBCUtilsServiceProtocol = LBCServices.shared.utilsService) {
        self.utilsService = utilsService
    }

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD adViewDidReceiveAd")
        self.utilsService.findPrebidCreativeSize(
            bannerView,
            success: { size in
                guard let bannerView = bannerView as? GAMBannerView else { return }
                bannerView.resize(GADAdSizeFromCGSize(size))
            },
            failure: { error in  print("error: \(error.localizedDescription)") }
        )
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
}
