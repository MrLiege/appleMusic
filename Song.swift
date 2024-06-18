//
//  Song.swift
//  AppleMusic
//
//  Created by Artyom Petrichenko on 17.06.2024.
//

import Foundation

struct Song: Identifiable, Codable, Equatable {
    var id: Int
    var trackName: String
    var artistName: String
    var artworkUrl100: URL
    var previewUrl: URL

    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case artistName
        case trackName
        case previewUrl
        case artworkUrl100
    }
}

