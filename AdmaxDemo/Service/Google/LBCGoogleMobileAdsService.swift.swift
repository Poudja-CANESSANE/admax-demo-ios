//
//  LBCGoogleMobileAdsService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 24/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

protocol LBCGoogleMobileAdsServiceProtocol: AnyObject {
    func createGAMRequest() -> LBCGAMRequestProtocol
}

final class LBCGoogleMobileAdsService: LBCGoogleMobileAdsServiceProtocol {
    func createGAMRequest() -> LBCGAMRequestProtocol {
        return GAMRequest()
    }
}
