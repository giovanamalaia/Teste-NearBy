/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view controller that facilitates the sample app's primary user experience.
 */

import UIKit
import NearbyInteraction
import MultipeerConnectivity
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var session: MPCSession?
    private var roomName: String
    private var isCreatingRoom: Bool // Indica se o usuário está criando a sala
    private var tableView = UITableView()
    private var connectedDevices: [MCPeerID] = []
    private let roomLabel = UILabel()
    private let devicesLabel = UILabel() // Exibe a quantidade de dispositivos conectados
    private let startButton = UIButton(type: .system)
    private let waitingLabel = UILabel()

    init(roomName: String, isCreatingRoom: Bool) {
        self.roomName = roomName
        self.isCreatingRoom = isCreatingRoom
        super.init(nibName: nil, bundle: nil)
        
        self.session = MPCSession(roomName: roomName, isHost: isCreatingRoom)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(roomName:isCreatingRoom:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showGreenScreen), name: NSNotification.Name("GameStarted"), object: nil)


        guard let session = session else { return }

        // Se este dispositivo é o criador da sala, ele deve anunciar a sala
        if isCreatingRoom {
            print("📢 Criando e anunciando a sala: \(roomName)")
            session.startHosting()
        } else {
            print("🔍 Procurando por salas disponíveis...")
            session.startBrowsing()
        }

        // ✅ Configurar o `connectedPeersHandler` aqui para **todos** os dispositivos
        print("📡 Configurando connectedPeersHandler na tela...")

        session.connectedPeersHandler = { [weak self] peers in
            guard let self = self else { return }

            print("📡 Atualizando UI com novos peers conectados: \(peers.map { $0.displayName })")

            DispatchQueue.main.async {
                self.connectedDevices = peers
                self.devicesLabel.text = "Devices Conectados: \(peers.count)"
                self.tableView.reloadData()

                if !self.isCreatingRoom {
                    self.waitingLabel.text = "Aguardando o host iniciar... (\(peers.count) conectados)"
                }

                // 🔥 Força atualização da UI para garantir que o SwiftUI renderize as mudanças
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }

    }

    
    func setupUI() {
            roomLabel.text = "Sala: \(roomName)"
            roomLabel.font = UIFont.boldSystemFont(ofSize: 22)
            roomLabel.textAlignment = .center
            roomLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(roomLabel)

            devicesLabel.text = "Devices Conectados: 0"
            devicesLabel.font = UIFont.systemFont(ofSize: 18)
            devicesLabel.textAlignment = .center
            devicesLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(devicesLabel)

            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            view.addSubview(tableView)

            if isCreatingRoom {
                // ✅ O host vê o botão "Start"
                startButton.setTitle("Start", for: .normal)
                startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                startButton.setTitleColor(.white, for: .normal)
                startButton.backgroundColor = .systemBlue
                startButton.layer.cornerRadius = 10
                startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
                startButton.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(startButton)
            } else {
                // ✅ Participantes veem "Aguardando..."
                waitingLabel.text = "Aguardando o host iniciar..."
                waitingLabel.font = UIFont.systemFont(ofSize: 18)
                waitingLabel.textAlignment = .center
                waitingLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(waitingLabel)

                
            }


            // ✅ Layout para todos os elementos
            NSLayoutConstraint.activate([
                roomLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                roomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                devicesLabel.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 10),
                devicesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                tableView.topAnchor.constraint(equalTo: devicesLabel.bottomAnchor, constant: 10),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])

            if isCreatingRoom {
                NSLayoutConstraint.activate([
                    startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                    startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    startButton.widthAnchor.constraint(equalToConstant: 150),
                    startButton.heightAnchor.constraint(equalToConstant: 50)
                ])
            } else {
                NSLayoutConstraint.activate([
                    waitingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                    waitingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
            }
        }
    
    @objc func startGame() {
        guard let session = session else { return }

        let startSignal = "START".data(using: .utf8)!
        session.sendDataToAllPeers(data: startSignal)

        print("🎮 Jogo iniciado pelo host!")
        
        DispatchQueue.main.async {
            let greenVC = GreenScreenViewController()
            greenVC.session = session // ✅ Aqui é essencial!
            greenVC.modalPresentationStyle = .fullScreen
            self.present(greenVC, animated: true)
        }
    }



    // MARK: - ✅ Métodos Obrigatórios de UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count // ✅ Retorna o número de dispositivos conectados
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = connectedDevices[indexPath.row].displayName // ✅ Mostra o nome do dispositivo conectado
        return cell
    }
    
    @objc func showGreenScreen() {
        guard let session = self.session else { return }

        let greenVC = GreenScreenViewController()
        greenVC.session = session
        greenVC.modalPresentationStyle = .fullScreen
        self.present(greenVC, animated: true)
    }


}

