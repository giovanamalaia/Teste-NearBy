//
//  IntroGameView.swift
//  NIPeekaboo
//
//  Created by Filipe Pinto Cunha on 24/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

import SwiftUI

struct IntroGameView: View {
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                ZStack {
                    imageBackground
                    VStack{
                        Spacer()
                        potatoFace
                        Spacer()
                        buttonStart
                        Spacer()
                    }
                    
                }
            }
        } else {
            VStack{
                
                Image(systemName: "xmark")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .foregroundColor(.red)
                Text("Lamento, a versão desse aplicativo não está disponivel para o seu dispositivo.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            
        }
     
    }
}

private var imageBackground: some View {
    Image("backgroundIntro")
        .resizable()
        .edgesIgnoringSafeArea(.all)
    
}
private var potatoFace: some View {
    Image("potatoFace")
        .padding(.bottom, 150)
}
private var buttonStart: some View {
   NavigationLink(destination: RoomView()) {
        Text("JOGAR")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(Color(red: 0.851, green: 0.851, blue: 0.851))
            .frame(width: 296, height: 54)
            .background(Color(red: 0.106, green: 0.198, blue: 0.294))
            .cornerRadius(20)
    }
    .padding(.top, 20)
}

#Preview {
    IntroGameView()
}
