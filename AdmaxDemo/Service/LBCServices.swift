//
//  LBCServices.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

final class LBCServices {
    static let shared = LBCServices()
    private init() {}

    let prebidService: LBCPrebidServiceProtocol = LBCPrebidService()
    let admaxConfigUtil: LBCAdmaxConfigUtilServiceProtocol = LBCAdmaxConfigUtilService()
    let utilsService: LBCUtilsServiceProtocol = LBCUtilsService()
    let googleMobileAdsService: LBCGoogleMobileAdsServiceProtocol = LBCGoogleMobileAdsService()
    let sasDisplayKitService: LBCSASDisplayKitServiceProtocol = LBCSASDisplayKitService()
    let admaxPrebidMobileService: LBCAdmaxPrebidMobileServiceProtocol = LBCAdmaxPrebidMobileService()
}
