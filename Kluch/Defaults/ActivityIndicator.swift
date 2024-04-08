//
//  ActivityIndicator.swift
//  Wallet_Dossi
//
//  Created by Dosi Dimitrov on 9.02.24.
//

import UIKit

class ActivityIndicatorManager {
    static let shared = ActivityIndicatorManager()
    private var activityIndicator: UIActivityIndicatorView?
    private let serialQueue = DispatchQueue(label: "com.yourapp.activityIndicatorManager")

    private init() {}

    func start() {
        serialQueue.async {
            self.stopInternal()

            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

                let activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.center = window.center
                activityIndicator.color = .white
                activityIndicator.startAnimating()
                window.addSubview(activityIndicator)

                self.activityIndicator = activityIndicator
            }
        }
    }

    func stop() {
        serialQueue.async {
            self.stopInternal()
        }
    }

    private func stopInternal() {
        DispatchQueue.main.sync {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil
        }
    }
}

/*
 func disconnect() {
     if let session {
         Task { @MainActor in
             do {
                 ActivityIndicatorManager.shared.start()
                 try await Sign.instance.disconnect(topic: session.topic)
                 ActivityIndicatorManager.shared.stop()
                 accountsDetails.removeAll()
             } catch {
                 ActivityIndicatorManager.shared.stop()
                 showError.toggle()
                 errorMessage = error.localizedDescription
             }
         }
     }
 }
 */

/*
 Task {
     do {
         ActivityIndicatorManager.shared.start()
         try await Sign.instance.request(params: request)
         lastRequest = request
         ActivityIndicatorManager.shared.stop()
         requesting = true
         DispatchQueue.main.async { [weak self] in
             self?.openWallet()
         }
     } catch {
         ActivityIndicatorManager.shared.stop()
         requesting = false
         showError.toggle()
         errorMessage = error.localizedDescription
     }
 }
 */
