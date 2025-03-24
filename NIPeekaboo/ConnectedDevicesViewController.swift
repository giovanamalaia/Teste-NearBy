//
//  ConnectedDevicesViewController.swift
//  NIPeekaboo
//
//  Created by Giovana Malaia on 14/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConnectedDevicesViewController: UIViewController {
    
    var session: MPCSession?
    private var tableView = UITableView()
    private var connectedDevices: [MCPeerID] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dispositivos Conectados"

        setupTableView()
        
        // ✅ Atualiza a lista de dispositivos conectados
        session?.connectedPeersHandler = { [weak self] peers in
            self?.connectedDevices = peers
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ConnectedDevicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = connectedDevices[indexPath.row].displayName
        return cell
    }
}
