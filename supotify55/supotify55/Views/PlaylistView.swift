import SwiftUI

struct SongStarRatingView: View {
    @Binding var rating: Int
    @State public var songId: String

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(index <= rating ? .yellow : .gray)
                    .onTapGesture {
                        rating = index
                        apicaller.fetchSongDetails(with: songId)
                        apicaller.postSongRating(for: songId, with: rating)
                    }
            }
        }
    }
}

struct DisplaySongView: View {
    var song: Song
    @State private var rating: Int

    init(song: Song) {
        self.song = song
        _rating = State(initialValue: song.songRating)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Song Title:")
                    .bold()
                    .foregroundColor(.white)
                Text(song.songName)
                    .foregroundColor(.white)
                
                Text("Artists:")
                    .bold()
                    .foregroundColor(.white)
                Text(song.artists.joined(separator: ", "))
                    .foregroundColor(.white)
                
                Text("Duration:")
                    .bold()
                    .foregroundColor(.white)
                Text("\(song.duration) seconds")
                    .foregroundColor(.white)
                
                Text("Release Year:")
                    .bold()
                    .foregroundColor(.white)
                Text(song.releaseYear)
                    .foregroundColor(.white)
                
                SongStarRatingView(rating: $rating, songId: song.songID) // Updated argument label
                    .padding(.vertical)
            }
        }
    }
}

struct PlaylistView: View {
    @State var playlistID: String
    @State private var songs: [Song] = []
    @State private var playlistPhotoURL: URL? = URL(string: "https://example.com/playlist_cover.jpg")
    @State private var playlistName: String = ""
    @State private var jsonObject: [String: Any] = [:]
    let placeholderURL = URL(string: "https://example.com/placeholder_image.jpg")!

    var body: some View {
        NavigationView {
            VStack {
                AsyncImage(url: playlistPhotoURL) { image in
                    image.resizable()
                        .frame(height: 150)
                        .cornerRadius(10)
                } placeholder: {
                    Color.gray
                        .frame(height: 150)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 120)

                Text(playlistName)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                List(songs, id: \.songID) { song in
                    DisplaySongView(song: song)
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
            apicaller.getPlaylistInfo(playlistID: playlistID) { playlistInfo in
                if let playlistInfo = playlistInfo {
                    jsonObject = playlistInfo

                    if let playlistNameAny = playlistInfo["playlistName"] as? String {
                        playlistName = playlistNameAny
                    }

                    if let playlistPictureAny = playlistInfo["playlistPicture"] as? String,
                       let url = URL(string: playlistPictureAny) {
                        playlistPhotoURL = url
                    }

                    if let songsData = jsonObject["songs"] as? [[String: Any]] {
                        songs = songsData.map { songData in
                            return Song(
                                songID: songData["song_id"] as? String ?? "",
                                songName: songData["song_name"] as? String ?? "",
                                duration: songData["duration"] as? Int ?? 0,
                                releaseYear: songData["release_year"] as? String ?? "",
                                artists: songData["artist"] as? [String] ?? [],
                                songRating: songData["song_rating"] as? Int ?? 0
                            )
                        }
                    }
                }
            }
        }
    }
}

// Preview code (for testing purposes)
struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(playlistID: "3HAdIN8wtU2UBo94fznOTm")
    }
}
