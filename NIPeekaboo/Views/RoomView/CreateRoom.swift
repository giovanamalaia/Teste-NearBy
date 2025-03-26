import SwiftUI

struct CreateRoom: View {
    @State private var inputText: String = ""
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var viewModel: RoomViewModel
    
    
    var roomAlreadyExists: Bool {
        viewModel.rooms.contains(inputText.uppercased())
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ZStack {
                imageBackground
                VStack {
                    HStack{
                        backButton
                            .padding(.bottom, 23)
                          
               
                        titleRoom
                        
                    }
                    Spacer()
                    textField1
                    Divider()
                    .frame(width: 300, height: 1)
                    .background(Color(red: 0.369, green: 0.365, blue: 0.365))
                    
                    if roomAlreadyExists && !inputText.isEmpty {
                                            Text("Esta sala já existe!")
                                                .foregroundColor(.red)
                                                .padding(.top, 10)
                                        }
                    
                    Spacer()
                    createRoom
                }
            }.navigationBarBackButtonHidden(true)
            
        } else {
            VStack {
                Image(systemName: "xmark")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .foregroundColor(.red)
                Text("Lamento, a versão desse aplicativo não está disponível para o seu dispositivo.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
           }) {
               Image(systemName: "chevron.backward")
                   .resizable()
                   .scaledToFit()
                   .frame(maxWidth: 32, maxHeight: 32)
                   .foregroundColor(Color(red: 0.288, green: 0.356, blue: 0.41))
                   
           }
           .padding(.trailing, 20)
    }
    private var imageBackground: some View {
        Image("backgroundIntro")
            .resizable()
            .edgesIgnoringSafeArea(.all)
    }
    private var titleRoom: some View {
        Text("ESCOLHA O NOME \n      DA SUA SALA")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(Color(red: 0.288, green: 0.356, blue: 0.41))
            .frame(maxWidth: 246, alignment: .trailing)
            .padding(.trailing, 25)
            
    }
    private var textField1: some View {
        TextField("SALA123", text: $inputText)
            .font(.largeTitle)
            .foregroundColor(Color(red: 0.288, green: 0.356, blue: 0.41))
            .frame(width: 300, height: 40, alignment: .center)
            .autocapitalization(.allCharacters)
                        .onChange(of: inputText) { newValue in
                            inputText = newValue.uppercased()
                        }
    }
    private var createRoom: some View {
        Button {
                    viewModel.addRoom(name: inputText)
                    inputText = ""
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("CRIAR SALA")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 296, height: 54)
                        .background(roomAlreadyExists || inputText.isEmpty ? Color.gray : Color(red: 0.106, green: 0.198, blue: 0.294))
                        .cornerRadius(20)
                }
                .disabled(roomAlreadyExists || inputText.isEmpty)
                .padding(.bottom, 35)
            
    }
    
    
}

#Preview {
    CreateRoom()
        .environmentObject(RoomViewModel())

}
