//
//  LBCGAMInterstitialAd.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

protocol LBCGAMInterstitialAdProtocol: AnyObject {
    var appEventDelegate: GADAppEventDelegate? { get set }

    static func load(withAdManagerAdUnitID id: String,
                     request: GAMRequest?,
                     completionHandler: @escaping GAMInterstitialAdLoadCompletionHandler)
    func present(fromRootViewController viewController: UIViewController)
}

final class LBCGAMInterstitialAd: LBCGAMInterstitialAdProtocol {
    var appEventDelegate: GADAppEventDelegate?

    static func load(withAdManagerAdUnitID id: String,
                     request: GAMRequest?,
                     completionHandler: @escaping (GAMInterstitialAd?, Error?) -> Void) {
        GAMInterstitialAd.load(withAdManagerAdUnitID: id,
                               request: request,
                               completionHandler: completionHandler)
    }

    func present(fromRootViewController viewController: UIViewController) {
        let dfpInterstitial = GAMInterstitialAd()
        dfpInterstitial.present(fromRootViewController: viewController)
    }
}

extension GAMInterstitialAd: LBCGAMInterstitialAdProtocol {}
