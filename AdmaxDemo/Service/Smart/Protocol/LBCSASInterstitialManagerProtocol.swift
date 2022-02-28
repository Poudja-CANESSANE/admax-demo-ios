//
//  LBCSASInterstitialManagerProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import SASDisplayKit

protocol LBCSASInterstitialManagerProtocol: AnyObject {
    func load()
    func load(bidderAdapter: SASBidderAdapterProtocol?)
}

extension SASInterstitialManager: LBCSASInterstitialManagerProtocol {}
