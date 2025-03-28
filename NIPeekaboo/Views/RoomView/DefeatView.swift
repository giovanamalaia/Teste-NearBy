//
//  DefeatView.swift
//  NIPeekaboo
//
//  Created by Marina Cabral Meirelles on 28/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
struct DefeatView: View {
    var body: some View {
        ZStack {
            defeatBack
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer() // Spacer no topo para empurrar o título para baixo
                titleAlert
                subtitleAlert
                Spacer() // Spacer no meio para controlar espaço
                potatoAngry
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var defeatBack: some View {
        Image("defeatBackground")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
    
    private var potatoAngry: some View {
        Image("potatoAngry")
            .resizable()
            .scaledToFit()
    }
    
    private var titleAlert: some View {
        Text("VOCÊ ERROU!")
            .foregroundColor(.white)
            .font(.system(size: 40, weight: .bold))
            .lineSpacing(14)
            .lineLimit(2)
            .frame(maxWidth: 330, maxHeight: 100)
    }
    private var subtitleAlert: some View {
        Text("AGUARDE A PRÓXIMA JOGADA")
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .regular))
            .lineSpacing(8)
    }
}

#Preview {
    DefeatView()
}
