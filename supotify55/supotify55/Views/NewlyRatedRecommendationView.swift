import SwiftUI

struct Song7: Identifiable, Decodable {
    var id = UUID()
    let artistName: [String]
    let picture: URL
    let songLength: Int
    let songID: String
    let songName: String

    // Convert songLength from milliseconds to a formatted string (e.g., "3:30")
    var formattedSongLength: String {
        let minutes = songLength / 60000
        let seconds = (songLength % 60000) / 1000
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    enum CodingKeys: String, CodingKey {
        case artistName = "artist_name"
        case picture
        case songLength = "songLength"
        case songID = "song_id"
        case songName = "song_name"
    }
}

struct DisplaySongView3: View {
    var song: Song7
    @State private var rating: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: song.picture) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle().foregroundColor(.gray).frame(width: 80, height: 80)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(song.songName)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(song.artistName.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)

                    Text(song.formattedSongLength)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            
            SongStarRatingView(rating: $rating, songId: song.songID)
                .padding(.vertical, 4)
        }
        .padding(.horizontal)
        .background(Color.black)
    }
}

struct NewlyRatedRecommendationView: View {
    @State private var songs: [Song7] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    Text("Newly Rating Recommendations")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()

                    List {
                        ForEach(songs) { song in
                            DisplaySongView3(song: song)
                                .listRowBackground(Color.black)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                fetchNewlyRatingRecommendations(currentUserId: myUser.username)
            }
        }
        .accentColor(.white) // This ensures that the title and other nav bar items are white.
    }

    func fetchNewlyRatingRecommendations(currentUserId: String) {
        guard let url = URL(string: "http://127.0.0.1:8008/\(myUser.username)/newly_rating_recomendations") else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Song7].self, from: data) {
                    DispatchQueue.main.async {
                        self.songs = decodedResponse
                    }
                } else {
                    print("Failed to decode response")
                }
            } else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}

struct PlaylistView_Previews2: PreviewProvider {
    static var previews: some View {
        NewlyRatedRecommendationView()
    }
}
