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

class InterstitialViewController: UIViewController, GADInterstitialDelegate, GADAppEventDelegate {

    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""

    let request = GADRequest()
    
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

        }
    }
    
    func interstitial(_ interstitial: GADInterstitial, didReceiveAppEvent name: String, withInfo info: String?) {
        interstitialUnit.sendBidWon(bidWonCacheId: info!)
    }

    func loadDFPInterstitial(adUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")

        dfpInterstitial = DFPInterstitial(adUnitID: "/21807464892/pb_admax_interstitial")
        dfpInterstitial.delegate = self
        dfpInterstitial.appEventDelegate = self
        request.testDevices = [ kGADSimulatorID, "2de8cd2491690938185052d38337abcf" ]
        adUnit.fetchDemand(adObject: self.request) { (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self.dfpInterstitial!.load(self.request)
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

}
