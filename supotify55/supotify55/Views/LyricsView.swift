import SwiftUI

struct LyricsView: View {
    let artistNames: [String] // Now an array of artist names
    let songName: String
    @State private var lyrics: String?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            // Display the song name at the top
            Text(songName)
                .font(.title) // You can customize the font as needed
                .foregroundColor(.white)
                .padding(.top)

            ScrollView {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let lyrics = lyrics {
                    Text(lyrics)
                        .foregroundColor(.white)
                        .padding()
                        .font(.body)
                        .lineSpacing(4)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white)
                }
            }
        }
        .background(Color.black) // Black background for the whole VStack
        .onAppear {
            fetchLyrics()
        }
    }

    func fetchLyrics() {
        guard let firstArtistName = artistNames.first else {
            errorMessage = "No artist name provided"
            isLoading = false
            return
        }

        let encodedArtistName = firstArtistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedSongName = songName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: "http://127.0.0.1:8008/lyrics/\(encodedArtistName)/\(encodedSongName)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }

                if let lyricsString = String(data: data, encoding: .utf8) {
                    lyrics = lyricsString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                } else {
                    errorMessage = "Failed to decode lyrics"
                }
            }
        }

        task.resume()
    }
}

struct LyricsView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsView(artistNames: ["21_Savage"], songName: "redrum")
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

