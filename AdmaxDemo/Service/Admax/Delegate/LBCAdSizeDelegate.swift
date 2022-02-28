//
//  LBCAdSizeDelegate.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 28/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

final class LBCAdSizeDelegate: AdSizeDelegate {
    func onAdLoaded(adUnit: AdUnit, size: CGSize, adContainer: UIView) {
        print("ADMAX onAdLoaded with Size: \(size)")
    }
}
