//
//  LBCResultCode.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 28/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

enum LBCResultCode {
    case success
    case failure
}

extension ResultCode {
    func convertToLBCResultCode() -> LBCResultCode {
        switch self {
        case .prebidDemandFetchSuccess: return .success
        default: return .failure
        }
    }
}
