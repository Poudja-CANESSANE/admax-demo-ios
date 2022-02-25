//
//  LBCSASBannerViewProtocol.swift
//  AdmaxDemo
//
//  Created by Poudja.canessane on 22/02/2022.
//  Copyright © 2022 Admax. All rights reserved.
//

import SASDisplayKit

protocol LBCSASBannerViewProtocol: UIView {
    var delegate: SASBannerViewDelegate? { get set }
    var modalParentViewController: UIViewController? { get set }

    func load(with placement: SASAdPlacement)
    func load(with placement: SASAdPlacement, bidderAdapter: SASBidderAdapterProtocol?)
}

final class LBCSASBannerView: UIView, LBCSASBannerViewProtocol {
    private let sasBannerView: SASBannerView

    init(frame: CGRect,
         delegate: LBCSASBannerViewDelegateProtocol?,
         modalParentViewController: UIViewController?) {
        self.sasBannerView = SASBannerView(frame: frame)
        self.sasBannerView.delegate = delegate
        self.sasBannerView.modalParentViewController = modalParentViewController
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var delegate: SASBannerViewDelegate? {
        get { self.sasBannerView.delegate }
        set {}
    }

    var modalParentViewController: UIViewController? {
        get { self.sasBannerView.modalParentViewController }
        set {}
    }

    func load(with placement: SASAdPlacement) {
        self.sasBannerView.load(with: placement)
    }

    func load(with placement: SASAdPlacement, bidderAdapter: SASBidderAdapterProtocol?) {
        self.sasBannerView.load(with: placement, bidderAdapter: bidderAdapter)
    }
}
