//
//  NativeInAppViewController.swift
//  PrebidDemoSwift
//
//  Created by Gwen on 23/08/2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AdmaxPrebidMobile
import CriteoPublisherSdk

class NativeInAppViewController: UIViewController, GAMBannerAdLoaderDelegate, GADCustomNativeAdLoaderDelegate, CRNativeLoaderDelegate {

    //MARK: : IBOutlet
    @IBOutlet weak var adContainerView: UIView!
    
    //MARK: : Properties
    var adLoader: GADAdLoader?
    var nativeAd:NativeAd?
    var nativeAdView: NativeAdView?
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    var adServerName: String = ""
    var bidderName: String = ""

    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    //MARK: : ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (adServerName == "Google") {
            print("entered \(adServerName) loop" )
            setupAndLoadNativeInAppForDFP(bidder:bidderName)
        }
    }
    
    //MARK: Setup NativeAd
    func setupAndLoadNativeInAppForDFP(bidder: String) {
        if bidder == "Criteo" {
            setupPBNativeInApp(configId: "3a19f25f-affe-435c-a01b-876eeb5646bb")
        } else {
            setupPBNativeInApp(configId: "25e17008-5081-4676-94d5-923ced4359d3")
        }
        loadNativeInAppForDFP()
    }
    
    func setupPBNativeInApp(configId: String) {
        createNativeInAppView()
        loadNativeAssets(configId)
    }
    
    //MARK: : Native functions
    func loadNativeAssets(_ configId: String){
        
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        
        let body = NativeAssetData(type: DataAsset.description, required: true)
        
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        nativeUnit = NativeRequest(configId: configId, adContainer: self.adContainerView, viewController: self, assets: [icon,title,image,body,cta,sponsored])
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        
        let event1 = EventType.Impression
        eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    func createNativeInAppView(){
        removePreviousAds()
        let adNib = UINib(nibName: "NativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let NativeAdView = array.first as? NativeAdView{
            self.nativeAdView = NativeAdView
            NativeAdView.frame = CGRect(x: 0, y: 0, width: self.adContainerView.frame.size.width, height: 150 + self.screenWidth * 400 / 600)
            self.adContainerView.addSubview(NativeAdView)
        }
    }
    
    //MARK: Prebid NativeAd DFP
    func loadNativeInAppForDFP(){
        let dfpRequest = GAMRequest()
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            self?.callDFP(dfpRequest)
        }
    }
    
    func callDFP(_ dfpRequest: GAMRequest){
        adLoader = GADAdLoader(adUnitID: "/21807464892/pb_admax_native",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.customNative],
                               options: [ ])
        adLoader?.delegate  = self
        adLoader?.load(dfpRequest)
    }
    
    //MARK: : CRNativeLoaderDelegate
    func nativeLoader(_ loader: CRNativeLoader, didReceive ad: CRNativeAd) {
        
        let criteoNativeAdView = Bundle.main.loadNibNamed("CriteoNativeAdView", owner: nil, options: nil)?.first as? CriteoNativeAdView
        
        criteoNativeAdView?.nativeAd = ad
        
        criteoNativeAdView?.titleLabel.text = ad.title
        criteoNativeAdView?.descriptionLabel.text = ad.body
        criteoNativeAdView?.attributionLabel.text = "Ads by \(ad.advertiserDomain)"
        criteoNativeAdView?.productMedia.mediaContent = ad.productMedia
        criteoNativeAdView?.clickToActionButton.setTitle(ad.callToAction, for: UIControl.State.normal)
        criteoNativeAdView?.clickToActionButton.isUserInteractionEnabled = false
        
        if let nativeAdView = criteoNativeAdView {
            for subview in adContainerView.subviews {
                subview.removeFromSuperview()
            }
            adContainerView.addSubview(nativeAdView)
        }
    }
    
    func nativeLoader(_ loader: CRNativeLoader, didFailToReceiveAdWithError error: Error) {
        
    }
    
    func nativeLoaderDidDetectClick(_ loader: CRNativeLoader) {
        
    }
    
    func nativeLoaderDidDetectImpression(_ loader: CRNativeLoader) {
        
    }
    
    func nativeLoaderWillLeaveApplication(_ loader: CRNativeLoader) {
        
    }
    
    //MARK: : DFP Native Delegate
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: GAMBannerView) {
        nativeAdView?.addSubview(bannerView)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Prebid GADAdLoader failed \(error)")
    }
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(kGADAdSizeBanner)]
    }
    
    //MARK: GADCustomNativeAdLoaderDelegate
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["12049435"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        print("Prebid GADAdLoader received customTemplageAd")
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: customNativeAd)
    }
    
    //MARK: Rendering Prebid Native
    func renderNativeInAppAd() {
        nativeAdView?.titleLabel.text = nativeAd?.title
        nativeAdView?.bodyLabel.text = nativeAd?.text
        if let iconString = nativeAd?.iconUrl, let iconUrl = URL(string: iconString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: iconUrl)
                DispatchQueue.main.async {
                    if data != nil {
                        self.nativeAdView?.iconImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        if let imageString = nativeAd?.imageUrl,let imageUrl = URL(string: imageString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    if data != nil {
                     self.nativeAdView?.mainImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        nativeAdView?.callToActionButton.setTitle(nativeAd?.callToAction, for: .normal)
        nativeAdView?.sponsoredLabel.text = nativeAd?.sponsoredBy
    }
    
    //MARK: : Helper functions
    
    func registerNativeInAppView(){
        nativeAd?.delegate = self
        if  let nativeAdView = nativeAdView {
            nativeAd?.registerView(view: nativeAdView, clickableViews: [nativeAdView.callToActionButton])
        }
    }
    
    func removePreviousAds() {
        if nativeAdView != nil {
            nativeAdView?.iconImageView = nil
            nativeAdView?.mainImageView = nil
            nativeAdView!.removeFromSuperview()
            nativeAdView = nil
        }
        if nativeAd != nil {
            nativeAd = nil
        }
    }
}

extension NativeInAppViewController : NativeAdDelegate{
    
    func nativeAdLoaded(ad:NativeAd) {
        print("nativeAdLoaded")
        nativeAd = ad
        registerNativeInAppView()
        renderNativeInAppAd()
    }
    
    func criteoNativeAdLoaded() {
        nativeUnit.loadAd()
    }
    
    func nativeAdNotFound() {
        print("nativeAdNotFound")
        
    }
    func nativeAdNotValid() {
        print("nativeAdNotValid")
    }
}

extension NativeInAppViewController : NativeAdEventDelegate{
    
    func adDidExpire(ad:NativeAd){
        print("adDidExpire")
    }
    func adWasClicked(ad:NativeAd){
        print("adWasClicked")
    }
    func adDidLogImpression(ad:NativeAd){
        print("adDidLogImpression")
    }
}
