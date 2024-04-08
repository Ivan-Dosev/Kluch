//
//  DefaultSocketFactory.swift
//  Wallet2024
//
//  Created by Dosi Dimitrov on 1.02.24.
//

import Foundation
import Starscream
import WalletConnectRelay

extension WebSocket: WebSocketConnecting { }

struct DefaultSocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        return WebSocket(url: url)
    }
}
