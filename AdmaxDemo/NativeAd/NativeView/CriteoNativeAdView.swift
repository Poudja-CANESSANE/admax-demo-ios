//
//  CriteoNativeAdView.swift
//  PrebidDemoSwift
//
//  Created by Gwen on 25/08/2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import CriteoPublisherSdk

public class CriteoNativeAdView: CRNativeAdView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var clickToActionButton: UIButton!
    @IBOutlet weak var productMedia: CRMediaView!
}
