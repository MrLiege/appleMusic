//
//  SearchBar.swift
//  AppleMusic
//
//  Created by Artyom Petrichenko on 17.06.2024.
//

import SwiftUI


struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    var viewModel: SongsViewModel
    let onCommit: () -> Void

    var body: some View {
        HStack {
            TextField("Search for songs", text: $text, onCommit: onCommit)
            Button(action: {
                withAnimation {
                    isEditing = false
                    text = ""
                    viewModel.fetchTopSongs()
                }
            }) {
                Text("Cancel")
            }
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
        .padding(.horizontal)
        .transition(.move(edge: .top))
        .animation(.default, value: isEditing)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//#Preview {
//    SearchBar()
//}
