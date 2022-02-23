//
//  LBCGAMRequest.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 18/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import GoogleMobileAds

protocol LBCGAMRequestProtocol: AnyObject {
    func createRequest() -> GAMRequest
}

final class LBCGAMRequest: LBCGAMRequestProtocol {
    func createRequest() -> GAMRequest {
        return GAMRequest()
    }
}
