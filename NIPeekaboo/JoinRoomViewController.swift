//
//  JoinRoomViewController.swift
//  NIPeekaboo
//
//  Created by Giovana Malaia on 14/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit

import UIKit

class JoinRoomViewController: UIViewController {
    
    var availableRooms: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let tableView = UITableView()
    var session: MPCSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Salas Disponíveis"

        setupTableView()
        
        session = MPCSession(roomName: "Browser", isHost: false)
        session?.foundRoomsHandler = { [weak self] rooms in
            self?.availableRooms = rooms
        }
        session?.startBrowsing()
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

extension JoinRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let roomName = availableRooms[indexPath.row]
        
        let joinButton = UIButton(type: .system)
        joinButton.setTitle("Entrar na sala: \(roomName)", for: .normal)
        joinButton.setTitleColor(.blue, for: .normal)
        joinButton.addTarget(self, action: #selector(joinRoom(_:)), for: .touchUpInside)
        joinButton.tag = indexPath.row
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            joinButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            joinButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }

    @objc func joinRoom(_ sender: UIButton) {
        let selectedRoom = availableRooms[sender.tag]
        print("🔹 Escolheu entrar na sala: \(selectedRoom)")

        session?.connectToRoom(room: selectedRoom) 

        let vc = ViewController(roomName: selectedRoom, isCreatingRoom: false)
        present(vc, animated: true)
    }

}
