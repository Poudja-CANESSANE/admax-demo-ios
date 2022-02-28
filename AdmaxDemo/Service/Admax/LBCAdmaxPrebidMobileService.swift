//
//  LBCAdmaxPrebidMobileService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 28/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCAdmaxPrebidMobileServiceProtocol: AnyObject {
    var admaxConfig: Data? { get }

    func start()
    func createGamInterstitialAdUnit(configId: String,
                                     viewController: UIViewController) -> LBCGamInterstitialAdUnitProtocol
    func createBannerAdUnit(configId: String,
                            size: CGSize,
                            viewController: UIViewController?,
                            adContainer: UIView?) -> LBCBannerAdUnitProtocol
    func getKeyvaluePrefix(admaxConfig: Data?) -> String
    func findPrebidCreativeSize(_ adView: UIView,
                                success: @escaping (CGSize) -> Void,
                                failure: @escaping (Error) -> Void)
    func findPrebidCreativeBidder(_ adObject: NSObject,
                                  success: @escaping (String) -> Void,
                                  failure: @escaping (Error) -> Void)
}

final class LBCAdmaxPrebidMobileService: LBCAdmaxPrebidMobileServiceProtocol {
    var admaxConfig: Data? {
        return Prebid.shared.admaxConfig
    }

    func start() {
        Prebid.shared.loggingEnabled = true
        Prebid.shared.admaxExceptionLogger = DemoAdmaxExceptionLogger()
        Prebid.shared.prebidServerAccountId = "4803423e-c677-4993-807f-6a1554477ced"
        Prebid.shared.shareGeoLocation = true
        Prebid.shared.initAdmaxConfig()
    }

    func createGamInterstitialAdUnit(configId: String, viewController: UIViewController) -> LBCGamInterstitialAdUnitProtocol {
        return GamInterstitialAdUnit(configId: configId, viewController: viewController)
    }

    func createBannerAdUnit(configId: String,
                            size: CGSize,
                            viewController: UIViewController?,
                            adContainer: UIView?) -> LBCBannerAdUnitProtocol {
        return BannerAdUnit(configId: configId,
                            size: size,
                            viewController: viewController,
                            adContainer: adContainer)
    }

    func getKeyvaluePrefix(admaxConfig: Data?) -> String {
        AdmaxConfigUtil.getKeyvaluePrefix(admaxConfig: admaxConfig)
    }

    func findPrebidCreativeSize(_ adView: UIView,
                                success: @escaping (CGSize) -> Void,
                                failure: @escaping (Error) -> Void) {
        Utils.shared.findPrebidCreativeSize(adView, success: success, failure: failure)
    }

    func findPrebidCreativeBidder(_ adObject: NSObject,
                                  success: @escaping (String) -> Void,
                                  failure: @escaping (Error) -> Void) {
        Utils.shared.findPrebidCreativeBidder(adObject, success: success, failure: failure)
    }
}
