//
//  RectangleController.swift
//  AdmaxDemo
//
//  Created by Gwen on 15/06/2019.
//  Copyright © 2019 Admax. All rights reserved.
//

import UIKit

import PrebidMobile

import GoogleMobileAds

import SASDisplayKit

class RectangleController: UIViewController, GADBannerViewDelegate, GADAppEventDelegate, SASBannerViewDelegate {
    
    @IBOutlet var appRectangleView: UIView!
    
    @IBOutlet var adServerLabel: UILabel!
    
    var adServerName: String = ""
    
    let request = DFPRequest()
    
    var sasBanner: SASBannerView!
    
    var dfpBanner: DFPBannerView!
    
    var bannerUnit: BannerAdUnit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = adServerName
        
        bannerUnit = BannerAdUnit(configId: "366c2e80-8932-4acd-ab9a-a2d7dd5abdfd", size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 35000)
        
        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            loadDFPBanner(bannerUnit: bannerUnit)
        } else if (adServerName == "Smart") {
            print("entered \(adServerName) loop")
            loadSmartBanner(bannerUnit: bannerUnit)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        bannerUnit?.stopAutoRefresh()
    }
    
    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        if (AnalyticsEventType.bidWon.rawValue == name) {
            bannerUnit.sendBidWon(bidWonCacheId: info!)
        }
    }
    
    func loadDFPBanner(bannerUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = "/21807464892/pb_admax_300x250_top"
        dfpBanner.rootViewController = self
        dfpBanner.delegate = self
        dfpBanner.appEventDelegate = self
        appRectangleView.addSubview(dfpBanner)
        request.testDevices = [ kGADSimulatorID, "2de8cd2491690938185052d38337abcf" ]
        
        bannerUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self?.dfpBanner!.load(self?.request)
        }
    }
    
    func loadSmartBanner(bannerUnit: AdUnit) {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80235)
        self.sasBanner = SASBannerView(frame: CGRect(x: 0, y: 0, width: appRectangleView.frame.width, height: 250))
        self.sasBanner.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.sasBanner.delegate = self
        self.sasBanner.modalParentViewController = self
        appRectangleView.addSubview(sasBanner)
        
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: bannerUnit)
        bannerUnit.fetchDemand(adObject: admaxBidderAdapter) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for Smart \(resultCode.name())")
            self?.sasBanner!.load(with: sasAdPlacement, bidderAdapter: admaxBidderAdapter)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        self.dfpBanner.resize(bannerView.adSize)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adViewDidReceiveAd(_ bannerView: DFPBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: DFPBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }
    
    func bannerViewDidLoad(_ bannerView: SASBannerView) {
        print("SAS bannerViewDidLoad")
    }
    
    func bannerView(_ bannerView: SASBannerView, didFailToLoadWithError error: Error) {
        print("SAS bannerView:didFailToLoadWithError: \(error.localizedDescription)")
    }
}
