//
//  VictoryView.swift
//  NIPeekaboo
//
//  Created by Marina Cabral Meirelles on 28/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI
struct VictoryView: View {
    var body: some View {
        ZStack {
            victoryBack
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                titleAlert
                subtitleAlert
                Spacer()
                potatoWon
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack {
                VStack {
                    Spacer()
                    playAgainButton
                        .padding(.bottom, 110)
                }
            }
            
            HStack {
                Spacer()
//                Button(action: { RoomView() }) {
//                    Image(systemName: "rectangle.portrait.and.arrow.right")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding(.trailing, 20)
//                        .padding(.top, 20)
//                }
                backToHomeButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }
    
    private var victoryBack: some View {
        Image("victoryBackground")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
    
    private var potatoWon: some View {
        Image("potatoWon")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: 500) // Altura aumentada

    }
    
    private var titleAlert: some View {
        Text("PARABÉNS!")
            .foregroundColor(.white)
            .font(.system(size: 40, weight: .bold))
            .lineSpacing(14)
            .lineLimit(2)
            .frame(maxWidth: 330, maxHeight: 100)
    }
    
    private var subtitleAlert: some View {
        Text("VOCÊ SALVOU A BATATA!")
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .regular))
            .lineSpacing(8)
    }
    private var playAgainButton: some View {
        Button(action: {  }) {
            Text("JOGAR NOVAMENTE")
                .foregroundColor(.white)
                .font(.system(size: 25, weight: .bold))
                .padding()
                .background(Color.blue)
                .cornerRadius(20)
        }
    }
    private var backToHomeButton: some View {
        NavigationLink(destination: RoomView()) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.trailing, 20)
                .padding(.top, 20)
        }
    }
}

#Preview {
    VictoryView()
}
