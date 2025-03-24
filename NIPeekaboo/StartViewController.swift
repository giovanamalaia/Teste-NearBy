//
//  StartViewController.swift
//  NIPeekaboo
//
//  Created by Giovana Malaia on 14/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import UIKit


class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        requestLocalNetworkPermission()
    }

    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Escolha uma opção"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let createRoomButton = UIButton(type: .system)
        createRoomButton.setTitle("Criar Sala", for: .normal)
        createRoomButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        createRoomButton.translatesAutoresizingMaskIntoConstraints = false

        let joinRoomButton = UIButton(type: .system)
        joinRoomButton.setTitle("Entrar na Sala", for: .normal)
        joinRoomButton.addTarget(self, action: #selector(joinRoom), for: .touchUpInside)
        joinRoomButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [titleLabel, createRoomButton, joinRoomButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func createRoom() {
        let alert = UIAlertController(title: "Criar Sala", message: "Digite um nome para a sala", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Nome da Sala"
        }
        alert.addAction(UIAlertAction(title: "Criar", style: .default, handler: { _ in
            if let roomName = alert.textFields?.first?.text, !roomName.isEmpty {
                let vc = ViewController(roomName: roomName, isCreatingRoom: true) // ✅ Agora passa `isCreatingRoom: true`
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }))
        present(alert, animated: true)
    }


    @objc func joinRoom() {
        let vc = JoinRoomViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

import Network

private func requestLocalNetworkPermission() {
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            print("✅ Acesso à rede local concedido.")
        } else {
            print("❌ Sem acesso à rede local.")
        }
        monitor.cancel()
    }
    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
}
