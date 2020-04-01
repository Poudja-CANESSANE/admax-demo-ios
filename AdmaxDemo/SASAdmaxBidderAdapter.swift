//
//  SASAdmaxBidderAdapter.swift
//  AdmaxDemo
//
//  Created by Gwen on 15/06/2019.
//  Copyright © 2019 Admax. All rights reserved.
//

import Foundation
import SASDisplayKit
import AdmaxPrebidMobile

class SASAdmaxBidderAdapter: NSObject, SASBidderAdapterProtocol, UpdatableProtocol {
    
    var creativeRenderingType: SASBidderAdapterCreativeRenderingType = SASBidderAdapterCreativeRenderingType.typePrimarySDK
    
    var adapterName: String = "SASAdmaxBidderAdapter"
    
    var winningSSPName: String = ""
    
    var winningCreativeID: String = ""
    
    var hbCacheID: String = ""
    
    var price: Float = 0
    
    var currency: String = "USD"
    
    var dealID: String? = ""
    
    var targetingMap: String = ""
    
    var admaxAdDisplayed: Bool = false
    
    var admaxAdUnit: AdUnit
    
    var adContainer: UIView?
    
    init(adUnit: AdUnit, container: UIView) {
        admaxAdUnit = adUnit
        adContainer = container
    }
    
    init(adUnit: AdUnit) {
        admaxAdUnit = adUnit
    }
    
    public func update(keywords: [String: String]) {
        winningSSPName = keywords["hb_bidder"]!
        winningCreativeID = keywords["hb_cache_id"] ?? ""
        hbCacheID = keywords["hb_cache_id"] ?? ""
        price = Float(keywords["hb_pb"]!)!
        targetingMap = stringify(keywords: keywords)
    }
    
    func primarySDKDisplayedBidderAd() {
        print("primarySDKDisplayedBidderAd called")
        if (admaxAdUnit.winningBiddingManager == nil) {
            admaxAdUnit.sendBidWon(bidWonCacheId: hbCacheID)
        }
    }
    
    func primarySDKClickedBidderAd() {
        print("primarySDKClickedBidderAd called")
    }
    
    func primarySDKLostBidCompetition() {
        print("primarySDKLostBidCompetition called")
        admaxAdDisplayed = true
        if (admaxAdUnit.winningBiddingManager != nil) {
            if (adContainer != nil) {
                admaxAdUnit.winningBiddingManager?.loadAd(containerView: adContainer!)
            } else {
                admaxAdUnit.winningBiddingManager?.loadAd()
            }
        }
    }
    
    func bidderWinningAdMarkup() -> String {
        let appId: String = Bundle.main.bundleIdentifier!
        let adm: String = "<script src = \"https://cdn.admaxmedia.io/creative.js\"></script>\n" +
            "<script>\n" +
            "  var ucTagData = {};\n" +
            "  ucTagData.adServerDomain = \"\";\n" +
            "  ucTagData.pubUrl = \"" + appId + "\";\n" +
            "  ucTagData.targetingMap = " + targetingMap + ";\n" +
            "\n" +
            "  try {\n" +
            "    ucTag.renderAd(document, ucTagData);\n" +
            "  } catch (e) {\n" +
            "    console.log(e);\n" +
            "  }\n" +
        "</script>"
        return adm
    }
    
    private func stringify(keywords: [String: String]) -> String {
        let n: Int = keywords.count - 1
        var i: Int = 0
        var keywordsString = "{"
        for (key, value) in keywords {
            keywordsString.append("'")
            keywordsString.append(key)
            keywordsString.append("':['")
            keywordsString.append(value)
            keywordsString.append("']")
            if (i < n) {
                keywordsString.append(",")
            }
            i += 1
        }
        keywordsString.append("}")
        return keywordsString
    }

}
