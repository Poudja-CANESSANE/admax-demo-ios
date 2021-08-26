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

import Foundation

import UIKit

class IndexController: UIViewController {
    @IBOutlet var adServerSegment: UISegmentedControl!
    @IBOutlet var bidderSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Admax Demo"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BannerController {
            let vc = segue.destination as? BannerController
            vc?.adServerName = adServerSegment.titleForSegment(at: adServerSegment.selectedSegmentIndex)!
            vc?.bidderName = bidderSegment.titleForSegment(at: bidderSegment.selectedSegmentIndex)!
        }
        if segue.destination is RectangleController {
            let vc = segue.destination as? RectangleController
            vc?.adServerName = adServerSegment.titleForSegment(at: adServerSegment.selectedSegmentIndex)!
            vc?.bidderName = bidderSegment.titleForSegment(at: bidderSegment.selectedSegmentIndex)!
        }

        if segue.destination is InterstitialViewController {
            let vc = segue.destination as? InterstitialViewController
            vc?.adServerName = adServerSegment.titleForSegment(at: adServerSegment.selectedSegmentIndex)!
            vc?.bidderName = bidderSegment.titleForSegment(at: bidderSegment.selectedSegmentIndex)!
        }
        
        if segue.destination is NativeInAppViewController {
            let vc = segue.destination as? NativeInAppViewController
            vc?.adServerName = adServerSegment.titleForSegment(at: adServerSegment.selectedSegmentIndex)!
            vc?.bidderName = bidderSegment.titleForSegment(at: bidderSegment.selectedSegmentIndex)!
        }

    }

}
