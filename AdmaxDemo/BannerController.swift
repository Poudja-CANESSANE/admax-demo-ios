/*   Copyright 2018-2019 ADMAX.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

import PrebidMobile

import GoogleMobileAds

import SASDisplayKit

class BannerController: UIViewController, GADBannerViewDelegate, GADAppEventDelegate, SASBannerViewDelegate {

   @IBOutlet var appBannerView: UIView!

    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""

    let request = DFPRequest()
    
    var sasBanner: SASBannerView!

    var dfpBanner: DFPBannerView!

    var bannerUnit: BannerAdUnit!

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName

        bannerUnit = BannerAdUnit(configId: "366c2e80-8932-4acd-ab9a-a2d7dd5abdfd", size: CGSize(width: 320, height: 50))
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
        bannerUnit.sendBidWon(bidWonCacheId: info!, eventName: name)
    }

    func loadDFPBanner(bannerUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        dfpBanner = DFPBannerView(adSize: kGADAdSizeBanner)
        dfpBanner.adUnitID = "/21807464892/pb_admax_320x50_top"
        dfpBanner.rootViewController = self
        dfpBanner.delegate = self
        dfpBanner.appEventDelegate = self
        appBannerView.addSubview(dfpBanner)
        request.testDevices = [ kGADSimulatorID, "2de8cd2491690938185052d38337abcf" ]

        bannerUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self?.dfpBanner!.load(self?.request)
        }
    }
    
    func loadSmartBanner(bannerUnit: AdUnit) {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80250)
        self.sasBanner = SASBannerView(frame: CGRect(x: 0, y: 0, width: appBannerView.frame.width, height: 50))
        self.sasBanner.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.sasBanner.delegate = self
        self.sasBanner.modalParentViewController = self
        appBannerView.addSubview(sasBanner)
        
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
        print("adViewDidReceiveAd")
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
    }
}
