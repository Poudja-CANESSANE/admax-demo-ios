//
//  LBCAdmaxConfigUtilService.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 17/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import AdmaxPrebidMobile

protocol LBCAdmaxConfigUtilServiceProtocol: AnyObject {
    func getKeyvaluePrefix(admaxConfig: Data?) -> String
}

final class LBCAdmaxConfigUtilService: LBCAdmaxConfigUtilServiceProtocol {
    func getKeyvaluePrefix(admaxConfig: Data?) -> String {
        AdmaxConfigUtil.getKeyvaluePrefix(admaxConfig: admaxConfig)
    }
}
