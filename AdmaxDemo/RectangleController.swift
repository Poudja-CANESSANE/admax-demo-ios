//
//  RectangleController.swift
//  AdmaxDemo
//
//  Created by Gwen on 15/06/2019.
//  Copyright © 2019 Admax. All rights reserved.
//

import UIKit

import AdmaxPrebidMobile

import GoogleMobileAds

import SASDisplayKit

class RectangleController: UIViewController, GADBannerViewDelegate, GADAppEventDelegate, SASBannerViewDelegate, GamBannerAdListener, AdSizeDelegate {
    
    @IBOutlet var appRectangleView: UIView!
    
    @IBOutlet var adServerLabel: UILabel!
    
    var adServerName: String = ""
    
    var bidderName: String = ""
    
    let request = DFPRequest()
    
    var sasBanner: SASBannerView!
    
    var dfpBanner: DFPBannerView!
    
    var bannerUnit: GamBannerAdUnit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = adServerName
        
        if (bidderName == "Xandr") {
            bannerUnit = GamBannerAdUnit(configId: "dbe12cc3-b986-4b92-8ddb-221b0eb302ef", size: CGSize(width: 300, height: 250), viewController: self, adContainer: appRectangleView)
        } else if (bidderName == "FAN") {
            bannerUnit = GamBannerAdUnit(configId: "54c11f7a-2174-462f-b1f3-7dfd06c94c1a", size: CGSize(width: 300, height: 250), viewController: self, adContainer: appRectangleView)
        } else if (bidderName == "Criteo") {
            bannerUnit = GamBannerAdUnit(configId: "dbe12cc3-b986-4b92-8ddb-221b0eb302ef", size: CGSize(width: 300, height: 250), viewController: self, adContainer: appRectangleView)
        } else if (bidderName == "Smart") {
            bannerUnit = GamBannerAdUnit(configId: "dbe12cc3-b986-4b92-8ddb-221b0eb302ef", size: CGSize(width: 300, height: 250), viewController: self, adContainer: appRectangleView)
        }

//        bannerUnit.setAutoRefreshMillis(time: 35000)
        bannerUnit.adSizeDelegate = self
        
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
        print("GAD adView didReceiveAppEvent")
        if (AnalyticsEventType.bidWon.name() == name) {
            bannerUnit.isGoogleAdServerAd = false
            if (!bannerUnit.isAdServerSdkRendering()) {
                bannerUnit.loadAd()
            }
        }
    }
    
    func onAdLoaded(adUnit: AdUnit, size: CGSize, adContainer: UIView) {
        print("ADMAX onAdLoaded with Size: \(size)")
    }
    
    func loadDFPBanner(bannerUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = "/21807464892/pb_admax_300x250_top"
        dfpBanner.rootViewController = self
        dfpBanner.delegate = self
        dfpBanner.appEventDelegate = self
        appRectangleView.addSubview(dfpBanner)
        
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
        guard let bannerUnit = bannerUnit as? GamBannerAdUnit else {
            return
        }
//        bannerUnit.addAdditionalSize(sizes: [CGSize(width: 320, height: 50)])
        bannerUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_300x250_top")
        bannerUnit.setGamBannerAdListener(adListener: self)
        
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: bannerUnit)
        bannerUnit.fetchDemand(adObject: admaxBidderAdapter) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for Smart \(resultCode.name())")
            if (resultCode == ResultCode.prebidDemandFetchSuccess) {
                self?.sasBanner!.load(with: sasAdPlacement, bidderAdapter: admaxBidderAdapter)
            } else {
                self?.sasBanner!.load(with: sasAdPlacement)
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD adViewDidReceiveAd")
        Utils.shared.findPrebidCreativeSize(bannerView,
                                            success: { (size) in
                                                guard let bannerView = bannerView as? DFPBannerView else {
                                                    return
                                                }
                                                bannerView.resize(GADAdSizeFromCGSize(size))},
                                            failure: { (error) in
                                                print("error: \(error.localizedDescription)");
        })
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
        bannerUnit.createDFPOnlyBanner()
    }
        
    func onAdLoaded(bannerUnit: GamBannerAdUnit, size: GADAdSize) {
        print("DFP Ad loaded with size \(size.size)")
    }
    
    func onAdFailedToLoad(error: GADRequestError) {
        print("DFP Ad failed to load with error \(error)")
    }
}
