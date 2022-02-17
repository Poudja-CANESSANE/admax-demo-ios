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

final class InterstitialViewController: UIViewController {
    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""
    var bidderName: String = ""

    private let request = GAMRequest()
    private var sasInterstitial: SASInterstitialManager!
    private var interstitialUnit: GamInterstitialAdUnit!
    private var dfpInterstitial: GAMInterstitialAd!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adServerLabel.text = self.adServerName

        if self.bidderName == "Xandr" {
            self.interstitialUnit = GamInterstitialAdUnit(configId: "dbe12cc3-b986-4b92-8ddb-221b0eb302ef", viewController: self)
        } else if self.bidderName == "Criteo" {
            self.interstitialUnit = GamInterstitialAdUnit(configId: "5ba30daf-85c5-471c-93b5-5637f3035149", viewController: self)
        } else if self.bidderName == "Smart" {
            self.interstitialUnit = GamInterstitialAdUnit(configId: "2cd143f6-bb9d-4ca9-9c4b-acb527657177", viewController: self)
        }

        if self.adServerName == "DFP" {
            print("entered \(self.adServerName) loop" )
            self.loadDFPInterstitial(adUnit: self.interstitialUnit)
        } else if self.adServerName == "Smart" {
            print("entered \(self.adServerName) loop")
            self.loadSmartInterstitial(adUnit: self.interstitialUnit)
        }
    }

    func loadDFPInterstitial(adUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        adUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            GAMInterstitialAd.load(withAdManagerAdUnitID: "/21807464892/pb_admax_interstitial", request: self?.request) { [weak self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                } else if let ad = ad, let self = self {
                    self.dfpInterstitial = ad
                    self.dfpInterstitial.appEventDelegate = self
                    Utils.shared.findPrebidCreativeBidder(
                        ad,
                        success: { (bidder) in
                            print("bidder: \(bidder)")},
                        failure: { [weak self] (error) in
                            print("error: \(error.localizedDescription)")
                            if let self = self {
                                self.dfpInterstitial?.present(fromRootViewController: self)
                            }
                        }
                    )
                }
            }
        }
    }
    
    func loadSmartInterstitial(adUnit: AdUnit) {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80600)
        self.sasInterstitial = SASInterstitialManager(placement: sasAdPlacement, delegate: self)
        guard let adUnit = adUnit as? GamInterstitialAdUnit else { return }
        adUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_interstitial")
        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: adUnit)

        adUnit.fetchDemand(adObject: admaxBidderAdapter) { [weak self] resultCode in
            print("Prebid demand fetch for Smart \(resultCode.name())")
            if resultCode == ResultCode.prebidDemandFetchSuccess {
                self?.sasInterstitial!.load(bidderAdapter: admaxBidderAdapter)
            } else {
                self?.sasInterstitial!.load()
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension InterstitialViewController: GADAppEventDelegate {
    func interstitialAd(_ interstitial: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        print("GAD interstitialAd did receive app event")
        if (AnalyticsEventType.bidWon.name() == name) {
            self.interstitialUnit.isGoogleAdServerAd = false
            if !self.interstitialUnit.isAdServerSdkRendering() {
                self.interstitialUnit.loadAd()
            } else {
                self.dfpInterstitial?.present(fromRootViewController: self)
            }
        }
    }
}

extension InterstitialViewController: SASInterstitialManagerDelegate {
    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad has been loaded")
            if interstitialUnit.isSmartAdServerSdkRendering() {
                self.sasInterstitial.show(from: self)
            }
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToLoadWithError error: Error) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did fail to load: \(error.localizedDescription)")
            self.interstitialUnit.createDfpOnlyInterstitial()
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didFailToShowWithError error: Error) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did fail to show: \(error.localizedDescription)")
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did appear")
        }
    }

    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad did disappear")
        }
    }
}
