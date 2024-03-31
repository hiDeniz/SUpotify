//
//  AllSongsView.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 7.12.2023.
//


import Foundation
import Combine
import SwiftUI


struct Song2: Codable, Identifiable {
    var id: String { song_id }
    let song_id: String
    let artist_name: [String]?
    let album_name: String?
    let song_name: String
    let picture: String?
    let rate: Double
    let tempo: Double?
    let popularity: Int?
    let valence: Double?
    let duration: Int?
    let energy: Double?
    let danceability: Double?
    let genre: String?
    let release_date: Int? // Changed from String? to Int?
    let play_count: Int?
    let date_added: String?
}



struct SongsResponse: Codable {
    let songs: [Song2]
}

//http://127.0.0.1:8008/all_songs

class AllSongsViewModel: ObservableObject {
    @Published var songs = [Song2]()

    func fetchAllSongs() async {
        guard let url = URL(string: "http://127.0.0.1:8008/\(myUser.username)/all_songs") else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(SongsResponse.self, from: data)
            DispatchQueue.main.async {
                self.songs = decodedResponse.songs
            }
        } catch {
            DispatchQueue.main.async {
                print("ALL songs Error: \(error.localizedDescription)")
            }
        }
    }
}



struct DisplaySongView2: View {
    var song: Song2
    @State private var rating: Int

    init(song: Song2) {
        self.song = song
        _rating = State(initialValue: Int(song.rate ))
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Song Title:")
                    .bold()
                    .foregroundColor(.white)
                Text(song.song_name)
                    .foregroundColor(.white)
                
                Text("Artists:")
                    .bold()
                    .foregroundColor(.white)
                if let artistNames = song.artist_name, !artistNames.isEmpty {
                    Text(artistNames.joined(separator: ", "))
                        .foregroundColor(.white)
                } else {
                    Text("Unknown Artist")
                        .foregroundColor(.white)
                }
                
                Text("Duration:")
                    .bold()
                    .foregroundColor(.white)
                if let duration = song.duration {
                    Text("\(duration) seconds")
                        .foregroundColor(.white)
                } else {
                    Text("Unknown Duration")
                        .foregroundColor(.white)
                }

                Text("Release Date:")
                    .bold()
                    .foregroundColor(.white)
                if let releaseDate = song.release_date {
                    Text("\(releaseDate)")
                        .foregroundColor(.white)
                } else {
                    Text("Unknown Release Date")
                        .foregroundColor(.white)
                }

                SongStarRatingView(rating: $rating, songId: song.song_id)
                    .padding(.vertical)
            }

        }
    }
}

struct AllSongsView: View {
    @ObservedObject var viewModel = AllSongsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("All Songs")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                List(viewModel.songs, id: \.id) { song in
                    DisplaySongView2(song: song)
                        .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.black)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .statusBar(hidden: true)
        .onAppear {
            Task {
                await viewModel.fetchAllSongs()
            }
        }
    }
}

struct AllSongsView_Previews: PreviewProvider {
    static var previews: some View {
        AllSongsView()
    }
}
