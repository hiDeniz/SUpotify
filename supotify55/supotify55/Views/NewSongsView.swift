//
//  NewSongs.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 10.12.2023.
//

import SwiftUI

struct newSongModel
{
    var artist_name : [String]
    var rate : Int
    var release_date : Int
    var song_id :String
    var song_name : String
}

struct NewSongsView: View {
    @State private var jsonObject: [String: Any] = [:]
    @State private var songs: [newSongModel] = []

    var body: some View {
        NavigationView {
            VStack {
                Image("2023music") // Burada "2023cover" isimli bir resim dosyasını varsayarak gösteriliyor
                    .resizable()
                    .frame(height: 150)
                    .cornerRadius(10)
                    .padding(.horizontal, 120)

                Text("Best Tracks Of 2023")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                List(songs, id: \.song_id) { song in
                    newSongModelDisplaySongView(song: song)
                        .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.black)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .statusBar(hidden: true)
        .onAppear {
            guard let url = URL(string: "http://127.0.0.1:8008/\(myUser.username)/new_songs") else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let decodedData = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    if let decodedData = decodedData {
                        // Parse the JSON data into Song objects and add them to the songs array
                        var songsArray: [newSongModel] = []
                        for songData in decodedData {
                            // Parse individual song data
                            if let songID = songData["song_id"] as? String,
                               let songName = songData["song_name"] as? String,
                               let releaseYear = songData["release_date"] as? Int,
                               let artist = songData["artist_name"] as? [String],
                               let songRating = songData["rate"] as? Int {
                            var song = newSongModel(artist_name: artist, rate: songRating, release_date: releaseYear, song_id: songID, song_name: songName)
                                songsArray.append(song)
                            } else {
                                print("Invalid song data format")
                            }
                        }
                        DispatchQueue.main.async {
                            self.songs = songsArray
                        }
                    } else {
                        print("Invalid data format")
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
}

struct newSongModelDisplaySongView: View {
    var song: newSongModel
    @State private var rating: Int

    init(song: newSongModel) {
        self.song = song
        _rating = State(initialValue: song.rate)
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
                Text(song.artist_name.joined(separator: ", "))
                    .foregroundColor(.white)
                
                Text("Release Year:")
                    .bold()
                    .foregroundColor(.white)
                Text("\(song.release_date)")
                    .foregroundColor(.white)
                SongStarRatingView(rating: $rating, songId: song.song_id) // Updated argument label
                    .padding(.vertical)
            }
        }
    }
}
