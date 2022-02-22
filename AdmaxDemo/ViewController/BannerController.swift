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
import AdmaxPrebidMobile
import GoogleMobileAds
import SASDisplayKit

final class BannerController: UIViewController {

    @IBOutlet var appBannerView: UIView!
    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""
    var bidderName: String = ""

    private let request = GAMRequest()
    private var sasBanner: SASBannerView!
    private var dfpBanner: GAMBannerView!
    private var bannerUnit: BannerAdUnit!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.adServerLabel.text = self.adServerName

        if (self.bidderName == "Xandr") {
            self.bannerUnit = BannerAdUnit(configId: "dbe12cc3-b986-4b92-8ddb-221b0eb302ef", size: CGSize(width: 320, height: 50), viewController: self, adContainer: self.appBannerView)
        } else if (self.bidderName == "Criteo") {
            self.bannerUnit = BannerAdUnit(configId: "fb5fac4a-1910-4d3e-8a93-7bdbf6144312", size: CGSize(width: 320, height: 50), viewController: self, adContainer: self.appBannerView)
        } else if (self.bidderName == "Smart") {
            self.bannerUnit = BannerAdUnit(configId: "fe7d0514-530c-4fb3-9a52-c91e7c426ba6", size: CGSize(width: 320, height: 50), viewController: self, adContainer: self.appBannerView)
        }
//        bannerUnit.setAutoRefreshMillis(time: 35000)
        self.bannerUnit.adSizeDelegate = self

        if (self.adServerName == "DFP") {
            print("entered \(self.adServerName) loop" )
            self.loadDFPBanner(bannerUnit: self.bannerUnit)
        } else if (self.adServerName == "Smart") {
            print("entered \(self.adServerName) loop")
            self.loadSmartBanner(bannerUnit: self.bannerUnit)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        self.bannerUnit?.stopAutoRefresh()
    }

    func loadDFPBanner(bannerUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        self.dfpBanner = GAMBannerView(adSize: kGADAdSizeBanner)
        self.dfpBanner.adUnitID = "/21807464892/pb_admax_320x50_top"
        self.dfpBanner.rootViewController = self
        self.dfpBanner.delegate = self
        self.dfpBanner.appEventDelegate = self
        self.appBannerView.addSubview(self.dfpBanner)

        bannerUnit.fetchDemand(adObject: self.request) { [weak self] resultCode in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self?.dfpBanner!.load(self?.request)
        }
    }
    
    func loadSmartBanner(bannerUnit: AdUnit) {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80250)
        self.sasBanner = SASBannerView(frame: CGRect(x: 0, y: 0, width: self.appBannerView.frame.width, height: 50))
        self.sasBanner.autoresizingMask = .flexibleWidth
        self.sasBanner.delegate = self
        self.sasBanner.modalParentViewController = self
        self.appBannerView.addSubview(self.sasBanner)
        
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: bannerUnit)
        bannerUnit.fetchDemand(adObject: admaxBidderAdapter) { [weak self] resultCode in
            print("Prebid demand fetch for Smart \(resultCode.name())")
            if resultCode == .prebidDemandFetchSuccess {
                self?.sasBanner!.load(with: sasAdPlacement, bidderAdapter: admaxBidderAdapter)
            } else {
                self?.sasBanner!.load(with: sasAdPlacement)
            }
        }
    }

    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }
}

extension BannerController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD adViewDidReceiveAd")
        Utils.shared.findPrebidCreativeSize(
            bannerView,
            success: { size in
                guard let bannerView = bannerView as? GAMBannerView else { return }
                bannerView.resize(GADAdSizeFromCGSize(size))
            },
            failure: { error in  print("error: \(error.localizedDescription)") }
        )
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
}

extension BannerController: GADAppEventDelegate {
    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD adView didReceiveAppEvent")
        if (AnalyticsEventType.bidWon.name() == name) {
            self.bannerUnit.isGoogleAdServerAd = false
            if !self.bannerUnit.isAdServerSdkRendering() {
                self.bannerUnit.loadAd()
            }
        }
    }
}

extension BannerController: SASBannerViewDelegate {
    func bannerViewDidLoad(_ bannerView: SASBannerView) {
        print("SAS bannerViewDidLoad")
    }

    func bannerView(_ bannerView: SASBannerView, didFailToLoadWithError error: Error) {
        print("SAS bannerView:didFailToLoadWithError: \(error.localizedDescription)")
    }
}

extension BannerController: AdSizeDelegate {
    func onAdLoaded(adUnit: AdUnit, size: CGSize, adContainer: UIView) {
        print("ADMAX onAdLoaded with Size: \(size)")
    }
}
