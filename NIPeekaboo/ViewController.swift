/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view controller that facilitates the sample app's primary user experience.
*/

import UIKit
import NearbyInteraction
import MultipeerConnectivity

class ViewController: UIViewController, NISessionDelegate {

    // MARK: - `IBOutlet` instances.
    @IBOutlet weak var monkeyLabel: UILabel!
    @IBOutlet weak var centerInformationLabel: UILabel!
    @IBOutlet weak var detailContainer: UIView!

    // MARK: - Distance and direction state.
    let nearbyDistanceThreshold: Float = 0.1

    enum DistanceDirectionState {
        case closeUpInFOV, notCloseUpInFOV, outOfFOV, unknown
    }
    
    // MARK: - Class variables
    var sessions: [MCPeerID: NISession] = [:]
    var distances: [MCPeerID: Float] = [:]  // 🔥 Guarda a distância mais recente de cada peer
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    var currentDistanceDirectionState: DistanceDirectionState = .unknown
    var mpc: MPCSession?
    var peerDisplayName: String?

    // MARK: - UI life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        monkeyLabel.alpha = 1.0
        monkeyLabel.text = "🥔"
        centerInformationLabel.alpha = 1.0
        detailContainer.alpha = 0.0

        startup()
    }

    func startup() {
        updateInformationLabel(description: "Discovering Peers ...")
        startupMPC()
    }

    // MARK: - `NISessionDelegate`
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let peer = sessions.first(where: { $0.value == session })?.key else {
            print("⚠️ Session update received, but no matching peer found.")
            return
        }

        guard let nearbyObjectUpdate = nearbyObjects.first else { return }

        // 🔥 Atualiza a distância do peer
        if let distance = nearbyObjectUpdate.distance {
            distances[peer] = distance
        }

        let nextState = getDistanceDirectionState(from: nearbyObjectUpdate)
        updateVisualization(from: currentDistanceDirectionState, to: nextState)
        currentDistanceDirectionState = nextState
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        currentDistanceDirectionState = .unknown
        startup()
    }

    func startupMPC() {
        if mpc == nil {
            #if targetEnvironment(simulator)
            mpc = MPCSession(service: "nisample", identity: "com.example.simulator.peekaboo-nearbyinteraction", maxPeers: 3)
            #else
            mpc = MPCSession(service: "nisample", identity: "com.example.peekaboo-nearbyinteraction", maxPeers: 3)
            #endif
            mpc?.peerConnectedHandler = connectedToPeer
            mpc?.peerDataHandler = dataReceivedHandler
            mpc?.peerDisconnectedHandler = disconnectedFromPeer
        }
        mpc?.invalidate()
        mpc?.start()
    }

    func connectedToPeer(peer: MCPeerID) {
        print("✅ Connected to peer: \(peer.displayName)")

        let newSession = NISession()
        newSession.delegate = self
        sessions[peer] = newSession
        distances[peer] = Float.greatestFiniteMagnitude  // 🔥 Inicializa a distância como muito grande

        guard let myToken = newSession.discoveryToken else {
            fatalError("Failed to initialize Nearby Interaction session for \(peer.displayName)")
        }

        shareMyDiscoveryToken(token: myToken, toPeer: peer)
        
        DispatchQueue.main.async {
            self.monkeyLabel.text = "🥔"
        }
    }

    func disconnectedFromPeer(peer: MCPeerID) {
        print("❌ Peer \(peer.displayName) disconnected")

        // Remove a sessão do peer e sua distância
        sessions[peer]?.invalidate()
        sessions.removeValue(forKey: peer)
        distances.removeValue(forKey: peer)

        DispatchQueue.main.async {
            self.updateInformationLabel(description: "Peer Disconnected")
            self.monkeyLabel.text = "🥔"
        }
    }

    func dataReceivedHandler(data: Data, peer: MCPeerID) {
        guard let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
            print("⚠️ Failed to decode discovery token from \(peer.displayName)")
            return
        }

        print("🔄 Received discovery token from \(peer.displayName)")

        guard let session = sessions[peer] else {
            print("⚠️ No session found for \(peer.displayName)")
            return
        }

        let config = NINearbyPeerConfiguration(peerToken: discoveryToken)
        session.run(config)
    }

    func shareMyDiscoveryToken(token: NIDiscoveryToken, toPeer peer: MCPeerID) {
        guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            print("⚠️ Failed to encode discovery token for \(peer.displayName)")
            return
        }

        mpc?.sendData(data: encodedData, peers: [peer], mode: .reliable)
        print("📤 Sent discovery token to \(peer.displayName)")
    }

    // MARK: - Visualizations
    func isNearby(_ distance: Float) -> Bool {
        return distance < nearbyDistanceThreshold
    }

    func getDistanceDirectionState(from nearbyObject: NINearbyObject) -> DistanceDirectionState {
        let isNearby = nearbyObject.distance.map(isNearby(_:)) ?? false
        let directionAvailable = nearbyObject.direction != nil

        if isNearby && directionAvailable {
            return .closeUpInFOV
        }
        if !isNearby && directionAvailable {
            return .notCloseUpInFOV
        }
        return .outOfFOV
    }

    func updateVisualization(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState) {
        if currentState == .notCloseUpInFOV && nextState == .closeUpInFOV || currentState == .unknown {
            impactGenerator.impactOccurred()
        }

        // 🔥 Pega a menor distância registrada
        let minDistance = distances.values.min() ?? Float.greatestFiniteMagnitude
        let isTouching = minDistance < nearbyDistanceThreshold

        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = isTouching ? .red : .green

            // 🔥 Atualiza o emoji corretamente
            switch nextState {
            case .closeUpInFOV:
                self.monkeyLabel.text = "🥔"
            case .notCloseUpInFOV:
                self.monkeyLabel.text = "🥔"
            case .outOfFOV:
                self.monkeyLabel.text = "🥔"
            case .unknown:
                self.monkeyLabel.text = "❓"
            }
        })
    }

    func updateInformationLabel(description: String) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
                self.centerInformationLabel.alpha = 1.0
                self.centerInformationLabel.text = description
            })
        }
    }
}

