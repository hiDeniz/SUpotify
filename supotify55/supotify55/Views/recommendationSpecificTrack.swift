import SwiftUI

// Represents each song suggestion
struct SongSuggestion: Identifiable, Decodable {
    var id = UUID()
    let songName: String
    let artistNames: [String]
    let picture: String
    let songLength: Int
    let songId: String

    private enum CodingKeys: String, CodingKey {
        case songName = "song_name"
        case artistNames = "artist_name"
        case picture
        case songLength
        case songId = "song_id"
    }
}

// Represents the top-level JSON response
struct SongResponse: Decodable {
    let songs: [SongSuggestion]
}

// The view for displaying the list of song suggestions
struct SuggestionListView: View {
    @State private var songList: [SongSuggestion] = []
    let trackIdentifier: String

    var body: some View {
        NavigationView {
            VStack {
                Text("Recommendations by Specific Track")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                List(songList, id: \.id) { song in
                    SongRow(song: song)
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
            retrieveSuggestions()
        }
    }

    func retrieveSuggestions() {
        let endpoint = "http://127.0.0.1:8008/recommendations_track/\(trackIdentifier)"
        guard let url = URL(string: endpoint) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let songList = try JSONDecoder().decode([SongSuggestion].self, from: data)
                    DispatchQueue.main.async {
                        self.songList = songList
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Network request error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// The view for displaying a single song row
struct SongRow: View {
    var song: SongSuggestion

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.picture)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .padding(.trailing, 8)

            VStack(alignment: .leading) {
                Text("Title:")
                    .bold()
                    .foregroundColor(.white)
                Text(song.songName)
                    .foregroundColor(.white)

                Text("Artists:")
                    .bold()
                    .foregroundColor(.white)
                Text(song.artistNames.joined(separator: ", "))
                    .foregroundColor(.white)
                    .font(.subheadline)

                Text("Duration:")
                    .bold()
                    .foregroundColor(.white)
                Text("\(song.songLength) ms")
                    .foregroundColor(.white)
            }
        }
    }
}


// Preview Providers
struct SuggestionListView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionListView(trackIdentifier: "3VpxEo6vMpi4rQ6t2WVVkK")
    }
}
