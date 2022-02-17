//
//  LBCServices.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

final class LBCServices {
    static let shared = LBCServices()
    private init() {}

    let prebidService: LBCPrebidServiceProtocol = LBCPrebidService()
}
