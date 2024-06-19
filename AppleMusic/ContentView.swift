//
//  ContentView.swift
//  AppleMusic
//
//  Created by Artyom Petrichenko on 17.06.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SongsViewModel()
    @State private var searchText = ""
    @State private var showingSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 40/255, green: 0/255, blue: 71/255)
                    .edgesIgnoringSafeArea(.all)
                
                RadialGradient(gradient: Gradient(colors: [Color(red: 38/255, green: 0, blue: 190/255, opacity: 0.5), Color.clear]), center: .topTrailing, startRadius: 2, endRadius: 700)
                    .edgesIgnoringSafeArea(.all)

                RadialGradient(gradient: Gradient(colors: [Color(red: 118/255, green: 1/255, blue: 129/255, opacity: 0.5), Color.clear]), center: .bottomLeading, startRadius: 2, endRadius: 600)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showingSearch.toggle()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.white)
                            }
                        }
                        .padding()
                    }
                    List(viewModel.songs) { song in
                        SongRow(song: song, songs: viewModel.songs, viewModel: viewModel)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .animation(.default, value: showingSearch)
                    .onSubmit(of: .search) {
                        viewModel.searchSongs(keyword: searchText)
                    }
                }
                
                if showingSearch {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showingSearch = false
                            }
                        }

                    SearchBar(text: $searchText, isEditing: $showingSearch, viewModel: viewModel) {
                        viewModel.searchSongs(keyword: searchText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .transition(.move(edge: .top))
                    .animation(.default, value: showingSearch)
                    
                }
            }
            .onAppear {
                if let keyword = viewModel.lastSearchKeyword {
                    viewModel.searchSongs(keyword: keyword)
                } else {
                    viewModel.fetchTopSongs()
                }
            }
        }
    }
}

struct SongRow: View {
    var song: Song
    var songs: [Song]
    var viewModel: SongsViewModel
    @State private var isShowingDetail = false
    
    var body: some View {
        HStack {
            AsyncImage(url: song.artworkUrl100)
                .frame(width: 64, height: 64)
                .aspectRatio(contentMode: .fill)
                .cornerRadius(15)
                .clipped()
                .padding(.trailing, 23)
            
            VStack(alignment: .leading) {
                Text(song.trackName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(1)
                Text(song.artistName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(1)
            }
            Spacer()
            
            Button(action: {
                isShowingDetail = true
            }) {
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.white)
            }
            .background(
                NavigationLink(
                    destination: TrackDetailView(songs: songs, song: song, songIndex: songs.firstIndex(where: { $0.id == song.id }) ?? 0)
                        .navigationBarHidden(true),
                    isActive: $isShowingDetail
                ) {
                    EmptyView()
                }
                    .hidden()
            )
        }
    }
}

#Preview {
    ContentView()
}
