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

class InterstitialViewController: UIViewController, GADInterstitialDelegate, GADAppEventDelegate, SASInterstitialManagerDelegate {

    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""

    let request = GADRequest()
    
    var sasInterstitial: SASInterstitialManager!
    
    var interstitialUnit: InterstitialAdUnit!

    var dfpInterstitial: DFPInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName

        Prebid.shared.prebidServerAccountId = "0dfe3a52-aeb2-4562-bdea-31bd2d69f214"
        interstitialUnit = InterstitialAdUnit(configId: "366c2e80-8932-4acd-ab9a-a2d7dd5abdfd")

        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            loadDFPInterstitial(adUnit: interstitialUnit)
        } else if (adServerName == "Smart") {
            print("entered \(adServerName) loop")
            loadSmartInterstitial(adUnit: interstitialUnit)
        }
    }
    
    func interstitial(_ interstitial: GADInterstitial, didReceiveAppEvent name: String, withInfo info: String?) {
        interstitialUnit.sendBidWon(bidWonCacheId: info!, eventName: name)
    }

    func loadDFPInterstitial(adUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")

        dfpInterstitial = DFPInterstitial(adUnitID: "/21807464892/pb_admax_interstitial")
        dfpInterstitial.delegate = self
        dfpInterstitial.appEventDelegate = self
        adUnit.fetchDemand(adObject: self.request) { (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self.dfpInterstitial!.load(self.request)
        }
    }
    
    func loadSmartInterstitial(adUnit: AdUnit) {
        let sasAdPlacement: SASAdPlacement = SASAdPlacement(siteId: 305017, pageId: 1109572, formatId: 80600)
        sasInterstitial = SASInterstitialManager(placement: sasAdPlacement, delegate: self)
        adUnit.setGamAdUnitId(gamAdUnitId: "/21807464892/pb_admax_interstitial")
        adUnit.rootViewController = self

        let admaxBidderAdapter = SASAdmaxBidderAdapter(adUnit: adUnit)
        adUnit.fetchDemand(adObject: admaxBidderAdapter) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for Smart \(resultCode.name())")
//            if (resultCode == ResultCode.prebidDemandFetchSuccess) {
//                self?.sasInterstitial!.load(bidderAdapter: admaxBidderAdapter)
//            } else {
//                self?.sasInterstitial!.load()
//            }
            self?.sasInterstitial!.load()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("Ad presented")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // Send another GADRequest here
        print("Ad dismissed")
    }

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {

        if (self.dfpInterstitial?.isReady ?? true) {
            print("Ad ready")
            self.dfpInterstitial?.present(fromRootViewController: self)
        } else {
            print("Ad not ready")
        }
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        if (manager == self.sasInterstitial) {
            print("Interstitial ad has been loaded")
            self.sasInterstitial.show(from: self)
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
