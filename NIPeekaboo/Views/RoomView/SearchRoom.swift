import SwiftUI

@available(iOS 16.0, *)
struct SearchRoom: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: RoomViewModel
    
    var body: some View {
        ZStack {
            imageBackground
            VStack {
                HStack {
                    backButton
                    titleRoom
                }
                Spacer()
                listaSalas
                Spacer()
                getInRoom
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    private var listaSalas: some View {
        List {
            ForEach(viewModel.rooms, id: \.self) { room in
                HStack {
                    Text(room)
                        .font(.title.bold())
                        .foregroundColor(Color(red: 0.288, green: 0.356, blue: 0.41))
                    
                    Spacer()
                    
                    Image(systemName: viewModel.selectedRoom == room ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(Color(red: 0.288, green: 0.356, blue: 0.41))
                        .onTapGesture {
                            viewModel.selectedRoom = room
                        }
                }
                .padding(.vertical, 5)
                .listRowBackground(Color.clear) // Fundo transparente
                .swipeActions(edge: .leading) {
                    Button(role: .destructive) {
                        withAnimation {
                            deleteRoom(room)
                        }
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
            }
        }
        .scrollContentBackground(.hidden) // Remove fundo da lista
        .frame(height: 350)
    }
    private func deleteRoom(_ room: String) {
        if let index = viewModel.rooms.firstIndex(of: room) {
            viewModel.rooms.remove(at: index)
            if viewModel.selectedRoom == room {
                viewModel.selectedRoom = nil
            }
        }
    }
    private var backButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 32, maxHeight: 32)
                .foregroundColor(Color(red: 0.106, green: 0.198, blue: 0.294))
        }
        .padding(.leading, 20)
    }
    private var imageBackground: some View {
        Image("backgroundIntro")
            .resizable()
            .edgesIgnoringSafeArea(.all)
    }
    private var titleRoom: some View {
        Text("SALAS CRIADAS")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(Color(red: 0.288, green: 0.356, blue: 0.41))
            .frame(maxWidth: .infinity, alignment: .center)
    }
    private var getInRoom: some View {
        NavigationLink(destination: GameRoom()) {
            Text("ENTRAR")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 296, height: 54)
                .background(viewModel.selectedRoom == nil ? Color.gray : Color(red: 0.106, green: 0.198, blue: 0.294))
                .cornerRadius(20)
        }
        .disabled(viewModel.selectedRoom == nil)
        .padding(.bottom, 35)
    }
}
#Preview {
    if #available(iOS 16.0, *) {
        SearchRoom()
            .environmentObject(RoomViewModel())
    } else {
        // Fallback on earlier versions
    }
}
