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
    var localNISession: NISession?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green

        guard let session = session else {
            print("🚫 Sem sessão MPC ativa!")
            return
        }

        // Cria sua própria NISession
        localNISession = NISession()
        localNISession?.delegate = self

        if let localToken = localNISession?.discoveryToken {
            print("✅ [GREEN] Token local disponível")

            // Envia para todos os peers conectados
            for peer in session.getConnectedPeers() {
                print("📤 [GREEN] Enviando discoveryToken para \(peer.displayName)")
                session.sendDiscoveryToken(localToken, to: peer)
            }

            // ⚠️ IMPORTANTE: Salva o token no próprio MPCSession para que ele também envie quando outros peers se conectarem depois
            session.localDiscoveryToken = localToken

        } else {
            print("❌ [GREEN] Token local não disponível")
        }

        // Continua igual:
        session.nearbyDistanceHandler = { [weak self] peerID, distance in
            print("📏 [VIEW] \(peerID.displayName): \(distance)m")
            self?.peerDistances[peerID] = distance
            self?.checkForNearbyPeers()
        }
    }

    // MARK: - 🛑 Verifica distância e troca cor da tela
    func checkForNearbyPeers() {
        print("🧪 Verificando proximidade...")

        let minDistance = peerDistances.values.min() ?? Float.greatestFiniteMagnitude
        let isNearby = minDistance < nearbyDistanceThreshold

        print("🖥 [DEBUG] Menor distância detectada: \(minDistance)m")

        DispatchQueue.main.async {
            let newColor: UIColor = isNearby ? .red : .green
            if self.view.backgroundColor != newColor {
                print("🎨 [DEBUG] Mudando cor para \(isNearby ? "🔴 Vermelho" : "🟢 Verde")")
            }
            self.view.backgroundColor = newColor
        }
    }


    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("❌ Sessão NI inválida: \(error.localizedDescription)")
    }
    
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let nearbyObject = nearbyObjects.first,
              let distance = nearbyObject.distance else {
            print("⚠️ [GREEN] Objeto Nearby inválido ou distância ausente")
            return
        }

        print("📏 [GREEN] Distância detectada: \(distance)m")

        DispatchQueue.main.async {
            let isNearby = distance < self.nearbyDistanceThreshold
            self.view.backgroundColor = isNearby ? .red : .green
        }
    }

}
