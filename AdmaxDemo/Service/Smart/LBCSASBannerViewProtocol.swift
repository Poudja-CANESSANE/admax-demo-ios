//
//  LBCSASBannerViewProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import SASDisplayKit

protocol LBCSASBannerViewProtocol: UIView {
    var delegate: SASBannerViewDelegate? { get set }
    var modalParentViewController: UIViewController? { get set }

    func load(with placement: SASAdPlacement)
    func load(with placement: SASAdPlacement, bidderAdapter: SASBidderAdapterProtocol?)
}

extension SASBannerView: LBCSASBannerViewProtocol {}
