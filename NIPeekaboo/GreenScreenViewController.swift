//
//  GreenScreenViewController.swift
//  NIPeekaboo
//
//  Created by Giovana Malaia on 19/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import NearbyInteraction
import MultipeerConnectivity

class GreenScreenViewController: UIViewController, NISessionDelegate {

    var session: MPCSession?
    private var peerDistances: [MCPeerID: Float] = [:]

    let nearbyDistanceThreshold: Float = 0.3

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green

        guard let session = session else {
            print("🚫 Sem sessão MPC ativa!")
            return
        }
        
        session.didUpdateDistances = { [weak self] distances in
            print("👀 [\(UIDevice.current.name)] Recebeu atualizações de distância: \(distances)")
            guard let self = self else { return }

            let isNearby = distances.values.contains(where: { $0 < self.nearbyDistanceThreshold })

            DispatchQueue.main.async {
                let newColor: UIColor = isNearby ? .red : .green
                if self.view.backgroundColor != newColor {
                    print("🎨 Mudando cor para \(newColor == .red ? "🔴" : "🟢")")
                    self.view.backgroundColor = newColor
                }
            }
        }
    }

    // MARK: - 🛑 Verifica distância e troca cor da tela
    func checkForNearbyPeers() {
        let minDistance = peerDistances.values.min() ?? Float.greatestFiniteMagnitude
        let isNearby = minDistance < nearbyDistanceThreshold

        DispatchQueue.main.async {
            let newColor: UIColor = isNearby ? .red : .green
            if self.view.backgroundColor != newColor {
                self.view.backgroundColor = newColor
            }
        }
    }


    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("❌ Sessão NI inválida: \(error.localizedDescription)")
    }
}
