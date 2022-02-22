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

final class BannerController: UIViewController {
    @IBOutlet var appBannerView: UIView!
    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""
    var bidderName: String = ""

    private lazy var admaxPrebidMobileService: LBCAdmaxPrebidMobileServiceProtocol = {
        return LBCAdmaxPrebidMobileService(adServerName: self.adServerName,
                                           bidderName: self.bidderName,
                                           viewController: self,
                                           bannerAdContainer: self.appBannerView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adServerLabel.text = self.adServerName
        self.admaxPrebidMobileService.loadBanner()
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        self.admaxPrebidMobileService.stopBannerUnitAutoRefresh()
    }

    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }
}
