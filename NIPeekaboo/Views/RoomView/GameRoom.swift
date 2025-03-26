//
//  GameRoom.swift
//  NIPeekaboo
//
//  Created by Filipe Pinto Cunha on 25/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI
@available(iOS 16.0, *)
struct GameRoom: View {
    @State private var numeroDeJogadores: String = ""

    var body: some View {
        ZStack{
            backImage
            .edgesIgnoringSafeArea(.all)
            
            VStack{
                
                Spacer()
                qtdPlayers
                titleAlert
                    .padding(.bottom, 30)
                potatoImage
                Spacer()
                startButton
                Spacer()
            }
        }
          
    }
    private var qtdPlayers:some View{
        Text("1/8 JOGADORES")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    private var titleAlert:some View{
        Text("VOCÊ É O DONO DA SALA, INICIE O JOGO QUANDO ESTIVER PRONTO!")
            .foregroundColor(.white)
            .font(.title3)
            .fontWeight(.semibold)
            .lineSpacing(14)
            .lineLimit(2)
            .frame(maxWidth: 330, maxHeight: 100)
            .padding(.bottom, 50)
    }
    private var backImage: some View {
        Image("gameRoomBackground")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
    private var potatoImage: some View {
        Image("potatoSmile")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 250, maxHeight: 250)
    }
    private var startButton: some View {
        
        NavigationLink(destination: LoadingRoom()) {
            Text("INICIAR")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 296, height: 54)
                .background(Color(red: 0.563, green: 0.137, blue: 0.113))
                .cornerRadius(20)
        }
        .padding(.bottom, 35)
       
            
    }
    
}
#Preview {
    if #available(iOS 16.0, *) {
        GameRoom()
    } else {
        // Fallback on earlier versions
    }
        

}
