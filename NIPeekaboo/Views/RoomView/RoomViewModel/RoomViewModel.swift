//
//  Untitled.swift
//  NIPeekaboo
//
//  Created by Filipe Pinto Cunha on 25/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

class RoomViewModel: ObservableObject {
    @Published var rooms: [String] = []
    @Published var selectedRoom: String?
    
    func addRoom(name: String) {
        let roomName = name.uppercased()
        if !rooms.contains(roomName) && !roomName.isEmpty {
            rooms.append(roomName)
        }
    }
}
