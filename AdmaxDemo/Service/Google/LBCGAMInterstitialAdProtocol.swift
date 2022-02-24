//
//  LBCGAMInterstitialAdProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 24/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

protocol LBCGAMInterstitialAdProtocol: AnyObject {
    var appEventDelegate: GADAppEventDelegate? { get set }

    func load(withAdManagerAdUnitID id: String,
              request: GAMRequest?,
              completionHandler: @escaping GAMInterstitialAdLoadCompletionHandler)
    func present(fromRootViewController viewController: UIViewController)
}

extension GAMInterstitialAd: LBCGAMInterstitialAdProtocol {
    func load(withAdManagerAdUnitID id: String, request: GAMRequest?, completionHandler: @escaping GAMInterstitialAdLoadCompletionHandler) {
        Self.load(withAdManagerAdUnitID: id, request: request, completionHandler: completionHandler)
    }
}
