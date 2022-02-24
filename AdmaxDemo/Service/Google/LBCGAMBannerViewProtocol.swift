//
//  LBCGAMBannerViewProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 24/02/2022.
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

extension GAMBannerView: LBCGAMBannerViewProtocol {}
