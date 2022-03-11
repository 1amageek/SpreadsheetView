//
//  HostingCell.swift
//  
//
//  Created by nori on 2022/03/11.
//

import SwiftUI
import SpreadsheetView

public class HostingCell<Content>: Cell where Content: View {

    // SwiftUI: -

    public weak var parentViewController: UIViewController?

    private var hostingViewController: UIViewController? {
        didSet(oldValue) {
            guard let parentViewController = self.parentViewController else { return }
            guard let hostingViewController: UIViewController = oldValue else { return }
            hostingViewController.willMove(toParent: parentViewController)
            hostingViewController.view.removeFromSuperview()
            hostingViewController.removeFromParent()
        }
    }

    func addContentView(_ contentView: Content) {
        guard let parentViewController = self.parentViewController else { return }
        let hostingViewController: UIViewController = UIHostingController(rootView: contentView)
        parentViewController.addChild(hostingViewController)
        self.contentView.addSubview(hostingViewController.view)
        if let hostingView = hostingViewController.view {
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [
                    hostingView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
                    hostingView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
                    hostingView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                    hostingView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
                ]
            )
        }
        hostingViewController.didMove(toParent: parentViewController)
        self.hostingViewController = hostingViewController
    }
}
