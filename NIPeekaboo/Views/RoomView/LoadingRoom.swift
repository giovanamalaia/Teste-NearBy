//
//  waitingRoom.swift
//  NIPeekaboo
//
//  Created by Filipe Pinto Cunha on 26/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//

//
//  GameRoom.swift
//  NIPeekaboo
//
//  Created by Filipe Pinto Cunha on 25/03/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI
@available(iOS 16.0, *)
struct LoadingRoom: View {
    @State private var numeroDeJogadores: String = ""
    @State var progress: CGFloat = 0.5
    
    var body: some View {
        ZStack{
            backImage
            .edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                potatoImage2
                    .padding(.bottom, 40)
                  
                
               
                
            
                barLoading
                titleLoading
          Spacer()
            }
        }
          
    }
    private var barLoading: some View {
        ProgressView(value: progress)
            .progressViewStyle(DashLineProgressStyle(totalWidth: 300, dashWidth: 8, dashSpacing: 2))
                .padding(.bottom, 25)
    }
    private var titleLoading:some View{
        Text("Prepare-se...")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(.white)
    }

    private var backImage: some View {
        Image("gameRoomBackground")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
    private var potatoImage2: some View {
        Image("potatoImage2")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 250, maxHeight: 250)
            .padding(.top, 50)
    }
    @available(iOS 16.0, *)
    struct DashLineProgressStyle: ProgressViewStyle {
        var totalWidth: CGFloat
        var dashWidth: CGFloat
        var dashSpacing: CGFloat
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading, spacing: 5){
                Text("\(Int((configuration.fractionCompleted ?? 0) * 100))%")
                    .font(.title3.bold())
                    .contentTransition(.numericText())
                    .foregroundColor(.white)
                ZStack (alignment: .leading){
                    Capsule()
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .frame(width: totalWidth + 4, height: 20)
                        .foregroundColor(.white)
                    HStack( spacing: dashSpacing){
                        ForEach(0 ..< Int(((configuration.fractionCompleted ?? 0) * totalWidth) / (dashWidth + dashSpacing)), id: \.self){ item in
                            Capsule()
                                .frame(width: dashWidth, height: 15)
                                .foregroundStyle(Color(red: 0.575, green: 0.14, blue: 0.116))
                            
                        }
                        
                    }
                    .offset(x: 3)
                   
                    
                }
            }
        }
        
        
        
    }
    
}
#Preview {
    if #available(iOS 16.0, *) {
        LoadingRoom()
    } else {
        // Fallback on earlier versions
    }
        

}
