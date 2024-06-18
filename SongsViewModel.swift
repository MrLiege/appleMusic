//
//  SongsViewModel.swift
//  AppleMusic
//
//  Created by Artyom Petrichenko on 17.06.2024.
//

import Foundation

class SongsViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var selectedSong: Song?
    @Published var lastSearchKeyword: String?
    private var songService = SongService()

    func searchSongs(keyword: String) {
        lastSearchKeyword = keyword
        songService.fetchSongs(with: keyword) { result in
            switch result {
            case .success(let songs):
                DispatchQueue.main.async {
                    self.songs = songs
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchTopSongs() {
        songService.fetchTopSongs { result in
            switch result {
            case .success(let songs):
                DispatchQueue.main.async {
                    self.songs = songs
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func selectSong(_ song: Song) {
        DispatchQueue.main.async {
            self.selectedSong = song
        }
    }
}
