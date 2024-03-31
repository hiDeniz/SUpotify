//
//  MergeTwoPlaylists.swift
//  supotify55
//
//  Created by Ayça Ataer on 3.01.2024.
//

import SwiftUI
import Combine

struct PlaylistView5: View {
    var songs: [Song11]

    var body: some View {
        List(songs, id: \.id) { song in
            VStack(alignment: .leading) {
                Text(song.song_name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Artist: \(song.artist_name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Duration: \(song.duration) ms")
                    .font(.caption)
                    .foregroundColor(.secondary)

                AsyncImage(url: song.picture) { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }
            }
            .padding(.vertical, 4)
        }
        .navigationBarTitle("Merged Playlist", displayMode: .inline)
    }
}




struct Song11: Decodable, Identifiable {
    var id: String { song_id }
    let song_id: String
    let song_name: String
    let duration: Int
    let artist_name: String
    let picture: URL

    enum CodingKeys: String, CodingKey {
        case song_id
        case song_name
        case duration = "songLength"
        case artist_name = "artist_name"
        case picture
    }
}


struct MergeTwoPlaylists: View {
    @State private var selectedPlaylist1: String?
    @State private var selectedPlaylist2: String?
    @State private var playlists: [Playlist] = []
    @State private var songs: [Song11] = []
    @State private var showMergedPlaylist = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Arka planı siyah yap

            VStack {
                // İlk Dropdown Menü
                Picker("Select Playlist 1", selection: $selectedPlaylist1) {
                    ForEach(playlists, id: \.playlistID) { playlist in
                        Text(playlist.name).tag(playlist.playlistID as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                // İkinci Dropdown Menü
                Picker("Select Playlist 2", selection: $selectedPlaylist2) {
                    ForEach(playlists, id: \.playlistID) { playlist in
                        Text(playlist.name).tag(playlist.playlistID as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                // Merge Butonu
                Button(action: {
                                   mergePlaylists()
                                   showMergedPlaylist = true
                               }){
                                   Text("Merge")
                                       .foregroundColor(.white)
                                       .padding()
                                       .frame(maxWidth: .infinity)
                                       .background(Color.green)
                                       .cornerRadius(10)
                               }
                               .padding()
                               .sheet(isPresented: $showMergedPlaylist) {
                                           PlaylistView5(songs: songs)  // Binding olmadan doğrudan dizi
                                       }
                           }
                           .padding()
                           
                       }
                       .onAppear {
                           apicaller.getUserPlaylists { fetchedPlaylists in
                               self.playlists = fetchedPlaylists
                               
                           }
                       }
                   }

                   func mergePlaylists() {
                       if let playlist1ID = selectedPlaylist1, let playlist2ID = selectedPlaylist2 {
                           fetchSongsFromPlaylists(playlistID1: playlist1ID, playlistID2: playlist2ID) { fetchedSongs in
                               self.songs = fetchedSongs
                               print("Alınan şarkılar: \(self.songs)")
                               showMergedPlaylist = true
                           }
                       }
                   }

                   func fetchSongsFromPlaylists(playlistID1: String, playlistID2: String, completion: @escaping ([Song11]) -> Void) {
                       let urlString = "http://127.0.0.1:8008/get_playlists_songs/\(playlistID1)/\(playlistID2)"
                       guard let url = URL(string: urlString) else { return }

                       URLSession.shared.dataTask(with: url) { data, _, error in
                           if let error = error {
                               print("API Hatası: \(error.localizedDescription)")
                               return
                           }

                           guard let data = data else {
                               print("Veri yok.")
                               return
                           }

                           do {
                               let songs = try JSONDecoder().decode([Song11].self, from: data)
                               DispatchQueue.main.async {
                                   completion(songs)
                               }
                           } catch {
                               print("JSON Decoding Hatası: \(error)")
                           }
                       }.resume()
                   }
               }

// SwiftUI Preview
struct MergeTwoPlaylists_Previews: PreviewProvider {
    static var previews: some View {
        MergeTwoPlaylists()
    }
}
