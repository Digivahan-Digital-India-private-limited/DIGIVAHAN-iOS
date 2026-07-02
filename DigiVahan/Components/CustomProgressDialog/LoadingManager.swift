//
//  LoadingManager.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

import UIKit

class LoadingManager {
    
    /*
     show
     LoadingManager.shared.show(on: self.view)
     
     Hide
     LoadingManager.shared.hide()
     */

    static let shared = LoadingManager()

    private var loadingView: LoadingView?

    func show(on view: UIView) {

        hide()

        let loader = LoadingView(frame: view.bounds)

        view.addSubview(loader)

        loader.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: view.topAnchor),
            loader.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loader.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        loader.startLoading()

        loadingView = loader
    }

    func hide() {

        loadingView?.stopLoading()
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}
