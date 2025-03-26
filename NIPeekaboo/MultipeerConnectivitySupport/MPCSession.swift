/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that manages peer discovery-token exchange over the local network by using MultipeerConnectivity.
*/
import Foundation
import MultipeerConnectivity
import NearbyInteraction

struct MPCSessionConstants {
    static let kKeyIdentity: String = "identity"
}

class MPCSession: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, NISessionDelegate {
    
    var peerConnectedHandler: ((MCPeerID) -> Void)?
    var peerDisconnectedHandler: ((MCPeerID) -> Void)?
    var dataReceivedHandler: ((Data, MCPeerID) -> Void)?
    var fileReceivedHandler: ((URL, MCPeerID) -> Void)?
    var foundRoomsHandler: (([String]) -> Void)?
    var connectedPeersHandler: (([MCPeerID]) -> Void)?

    private let localPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let mcSession: MCSession
    private var mcAdvertiser: MCNearbyServiceAdvertiser?
    private let mcBrowser: MCNearbyServiceBrowser?
    private let roomName: String
    private let isHost: Bool
    private var foundPeers: [String: MCPeerID] = [:]
    
    var discoveryTokenReceivedHandler: ((MCPeerID, NIDiscoveryToken) -> Void)?
    private var niSessions: [MCPeerID: NISession] = [:]
    var localDiscoveryToken: NIDiscoveryToken?
    var nearbyDistanceHandler: ((MCPeerID, Float) -> Void)?
    
    var didUpdateDistances: (([MCPeerID: Float]) -> Void)?
    private var peerDistances: [MCPeerID: Float] = [:]


    init(roomName: String, isHost: Bool) {
        self.roomName = roomName
        self.isHost = isHost
        self.mcSession = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .required)
        if !isHost {
            self.mcBrowser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: "mpc-room")
        } else {
            self.mcBrowser = nil
        }

        super.init()

        mcSession.delegate = self
        mcBrowser?.delegate = self

        if isHost {
            self.mcAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["room": roomName], serviceType: "mpc-room")
            self.mcAdvertiser?.delegate = self
        }
        startNearbyInteraction() 
    }

    // MARK: - 🔎 **MCNearbyServiceBrowserDelegate**
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let room = info?["room"] else { return }

        if !foundPeers.keys.contains(room) {
            foundPeers[room] = peerID
            DispatchQueue.main.async {
                self.foundRoomsHandler?(Array(self.foundPeers.keys))
            }
        }
        print("✅ Encontrou sala: \(room) - Host: \(peerID.displayName)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("⚠️ Sala perdida: \(peerID.displayName)")
    }

    // MARK: - 📨 **Convites para conexão**
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📩 Convite recebido de \(peerID.displayName)")
        invitationHandler(true, mcSession)
    }

    // MARK: - 🛠 **Gerenciamento de Conexões**
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("✅ \(peerID.displayName) conectou-se com sucesso!")

            DispatchQueue.main.async {
                self.connectedPeersHandler?(session.connectedPeers)
            }

            // 👇 Envia o token local para o peer conectado
            if let token = self.localDiscoveryToken {
                for peer in session.connectedPeers {
                    if peer != self.localPeerID {
                        print("📤 Enviando token local para \(peer.displayName)")
                        self.sendDiscoveryToken(token, to: peer)
                    }
                }
            }


        case .notConnected:
            print("❌ \(peerID.displayName) desconectou-se!")

            DispatchQueue.main.async {
                self.connectedPeersHandler?(session.connectedPeers)
            }

        case .connecting:
            print("⏳ \(peerID.displayName) está tentando conectar...")

        @unknown default:
            fatalError("⚠️ Estado desconhecido da sessão")
        }
    }

    // MARK: - 📩 **MCSessionDelegate (Recebendo Dados)**
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("📩 Dados recebidos de \(peerID.displayName)")

        // 📡 Se for um discovery token...
        if let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            print("📡 Token de descoberta recebido de \(peerID.displayName)")

            DispatchQueue.main.async {
                self.discoveryTokenReceivedHandler?(peerID, token)
            }

            let config = NINearbyPeerConfiguration(peerToken: token)

            if let niSession = self.niSessions[peerID] {
                niSession.run(config)
                print("🚀 Executando NI com sessão existente para \(peerID.displayName)")
            } else {
                if self.niSessions[peerID] != nil {
                    print("ℹ️ Sessão com \(peerID.displayName) já existe. Ignorando nova.")
                    return
                }

                let newSession = NISession()
                newSession.delegate = self
                self.niSessions[peerID] = newSession
                newSession.run(config)
                print("🆕 Criando e executando nova NI session para \(peerID.displayName)")
            }

            return
        }



        // 📌 Se for um comando "START"...
        if let message = String(data: data, encoding: .utf8), message == "START" {
            print("🎮 Comando START recebido! Trocando para a tela verde...")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("GameStarted"), object: nil, userInfo: ["session": self])
            }
            return
        }

        // 📨 Se for outro tipo de dado
        DispatchQueue.main.async {
            self.dataReceivedHandler?(data, peerID)
        }
    }



    // MARK: - 📡 **MCSessionDelegate (Recebendo Stream)**
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    // MARK: - ⬇️ **MCSessionDelegate (Recebendo Arquivos)**
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func startHosting() {
        if isHost {
            print("📢 Criando e anunciando a sala: \(roomName)")
            mcAdvertiser?.startAdvertisingPeer()
        }
    }
    
    func startBrowsing() {
        if !isHost {
            print("🔍 Procurando por salas disponíveis...")
            mcBrowser!.startBrowsingForPeers()
        }
    }
    
    func connectToRoom(room: String) {
        guard let peerID = foundPeers[room] else {
            print("⚠️ Sala \(room) não encontrada.")
            return
        }
        
        print("📩 Enviando convite para \(peerID.displayName)")
        mcBrowser!.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
    }
    
    func sendDataToAllPeers(data: Data) {
        guard !mcSession.connectedPeers.isEmpty else {
            print("⚠️ Nenhum peer conectado. Não foi possível enviar os dados.")
            return
        }

        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            print("✅ Dados enviados com sucesso.")
        } catch {
            print("❌ Erro ao enviar dados: \(error.localizedDescription)")
        }
    }
    
    func notifyConnectedPeers() {
        let peerNames = mcSession.connectedPeers.map { $0.displayName }

        guard let data = try? JSONEncoder().encode(peerNames) else {
            print("❌ Erro ao codificar lista de peers.")
            return
        }

        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            print("📡 Lista de dispositivos enviada para os peers: \(peerNames)")
        } catch {
            print("❌ Erro ao enviar lista de dispositivos: \(error.localizedDescription)")
        }
    }
    
    func getConnectedPeers() -> [MCPeerID] {
        return mcSession.connectedPeers
    }
    
    private func startNearbyInteraction() {
        print("🔥 [DEBUG] Tentando iniciar Nearby Interaction...")

        if NISession.isSupported {
            let niSession = NISession()
            niSessions[localPeerID] = niSession
            niSession.delegate = self

            if let token = niSession.discoveryToken {
                localDiscoveryToken = token
                print("✅ [DEBUG] Token de descoberta local obtido.")
            } else {
                print("❌ [DEBUG] Falha ao obter token de descoberta local")
            }
        } else {
            print("❌ [DEBUG] Dispositivo não suporta Nearby Interaction")
        }
    }

    func sendDiscoveryToken(_ token: NIDiscoveryToken, to peer: MCPeerID) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            print("⚠️ Erro ao codificar discoveryToken.")
            return
        }

        do {
            try mcSession.send(data, toPeers: [peer], with: .reliable)
            print("📤 Enviando discoveryToken para \(peer.displayName)")
        } catch {
            print("❌ Erro ao enviar discoveryToken: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        print("🧠 [\(UIDevice.current.name)] delegate NI disparou. Objects: \(nearbyObjects)")
        guard let nearbyObject = nearbyObjects.first,
              let distance = nearbyObject.distance,
              let peerID = niSessions.first(where: { $0.value == session })?.key else {
            print("⚠️ NI: Objeto ou peer não encontrado na sessão.")
            return
        }

        print("📏 [NI] Distância detectada com \(peerID.displayName): \(distance)m")

        // Atualiza a lista
        peerDistances[peerID] = distance

        // Notifica quem estiver escutando
        DispatchQueue.main.async {
            self.didUpdateDistances?(self.peerDistances)
        }
    }



}
