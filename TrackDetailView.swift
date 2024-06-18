//
//  TrackDetailView.swift
//  AppleMusic
//
//  Created by Artyom Petrichenko on 17.06.2024.
//

import SwiftUI
import AVKit

struct TrackDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    var songs: [Song]
    @State var song: Song
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var progress = 0.0
    @State private var currentTime = 0.0
    @State private var duration = 0.0
    @State var songIndex: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 40/255, green: 0/255, blue: 71/255)
                .edgesIgnoringSafeArea(.all)
            
            RadialGradient(gradient: Gradient(colors: [Color(red: 38/255, green: 0, blue: 190/255, opacity: 0.5), Color.clear]), center: .topTrailing, startRadius: 2, endRadius: 700)
                .edgesIgnoringSafeArea(.all)

            RadialGradient(gradient: Gradient(colors: [Color(red: 118/255, green: 1/255, blue: 129/255, opacity: 0.5), Color.clear]), center: .bottomLeading, startRadius: 2, endRadius: 600)
                .edgesIgnoringSafeArea(.all)

            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white)
                }
            }
            .padding([.top, .leading])

            VStack {
                Spacer(minLength: 52)
                
                let highResImageUrl = song.artworkUrl100.deletingLastPathComponent().appendingPathComponent("632x632bb-60.jpg")
                AsyncImage(url: highResImageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 239, height: 274)
                        .cornerRadius(20)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 239, height: 274)
                .padding(.bottom, 35)
                
                Text(song.trackName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                Text(song.artistName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Slider(value: $progress, in: 0...1, onEditingChanged: { editing in
                    if !editing {
                        let targetTime = CMTime(seconds: self.duration * self.progress, preferredTimescale: 600)
                        player?.seek(to: targetTime)
                    }
                })
                .accentColor(Color.white)
                .padding(.horizontal, 68)
                HStack {
                    Text(formatTime(seconds: currentTime))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.4))
                    Spacer()
                    Text("\(formatTime(seconds: duration - currentTime))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                .padding(.horizontal, 68)
                Spacer()
                HStack(spacing: 53) {
                    Button(action: playPrevious) {
                        Image(systemName: "backward.end.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color.white)
                    }
                    Button(action: playPauseAction) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 78, height: 78)
                            .background(Circle().fill(Color.black))
                    }
                    Button(action: playNext) {
                        Image(systemName: "forward.end.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.horizontal, 68)
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    func setupPlayer() {
        let playerItem = AVPlayerItem(url: song.previewUrl)
        player = AVPlayer(playerItem: playerItem)
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { time in
            guard let duration = player?.currentItem?.duration else { return }
            self.duration = duration.seconds
            self.currentTime = time.seconds
            self.progress = self.currentTime / self.duration
        }
        duration = playerItem.asset.duration.seconds
    }

    func playPauseAction() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }

    func playNext() {
        let nextIndex = songIndex + 1 < songs.count ? songIndex + 1 : 0
        updateSong(to: songs[nextIndex], at: nextIndex)
    }

    func playPrevious() {
        let prevIndex = songIndex - 1 >= 0 ? songIndex - 1 : songs.count - 1
        updateSong(to: songs[prevIndex], at: prevIndex)
    }

    func updateSong(to newSong: Song, at newIndex: Int) {
        song = newSong
        songIndex = newIndex
        player?.pause()
        setupPlayer()
        playPauseAction()
    }

    func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds)) ?? "0:00"
    }
}


//#Preview {
//    TrackDetailView()
//}
