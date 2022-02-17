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
import CoreLocation
import SASDisplayKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let SAS_SITE_ID: Int = 305017

    var window: UIWindow?

    var coreLocation: CLLocationManager?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //Declare in AppDelegate to the user agent could be passed in first call
        Prebid.shared.loggingEnabled = true
        Prebid.shared.admaxExceptionLogger = DemoAdmaxExceptionLogger()
        Prebid.shared.prebidServerAccountId = "4803423e-c677-4993-807f-6a1554477ced"
        Prebid.shared.shareGeoLocation = true
        Prebid.shared.initAdmaxConfig()
        
        SASConfiguration.shared.configure(siteId: SAS_SITE_ID)
        SASConfiguration.shared.loggingEnabled = true

        coreLocation = CLLocationManager()
        coreLocation?.requestWhenInUseAuthorization()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}