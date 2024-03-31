//
//  WorldChartsView.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 27.12.2023.
//

import SwiftUI

struct TopSongByCountry: Decodable {
    var artistName: [String]
    var picture: String
    var songLength: Int
    var songId: String
    var songName: String

    enum CodingKeys: String, CodingKey {
        case artistName = "artist_name"
        case picture
        case songLength = "songLength"
        case songId = "song_id"
        case songName = "song_name"
    }
}

typealias Songs = [Song]


struct TopSongsListView: View {
    @Binding var country: String // Change to Binding
    @State private var songs = [TopSongByCountry]()// Initialize as an empty array

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Set the entire background to black
            List(songs, id: \.songId) { song in
                HStack {
                    AsyncImage(url: URL(string: song.picture)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50) // Set the image size
                    .cornerRadius(8) // Optional corner radius

                    VStack(alignment: .leading) {
                        Text(song.songName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Artist: \(song.artistName.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 8) // Add padding to the VStack content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Stretch to fill width
                .background(Color.black) // Set the background color of the VStack to black
                .listRowInsets(EdgeInsets()) // Remove the default list row insets
            }
            .listStyle(PlainListStyle()) // Use a plain list style
            .background(Color.black) // Set the List's background to black
        }
        .onAppear {
            let urlString = "http://127.0.0.1:8008/get_top_songs/\(country)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data returned from the request")
                    return
                }

                // Print the raw data as a String for debugging
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Received data: \(dataString)")
                }

                do {
                    let songs = try JSONDecoder().decode([TopSongByCountry].self, from: data)
                    DispatchQueue.main.async {
                        self.songs = songs
                        print("Decoded \(songs.count) songs successfully")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()
        }
        .onChange(of: country) { _ in
            let urlString = "http://127.0.0.1:8008/get_top_songs/\(country)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data returned from the request")
                    return
                }

                // Print the raw data as a String for debugging
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Received data: \(dataString)")
                }

                do {
                    let songs = try JSONDecoder().decode([TopSongByCountry].self, from: data)
                    DispatchQueue.main.async {
                        self.songs = songs
                        print("Decoded \(songs.count) songs successfully")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()        }
    }

}

struct WorldChartsView: View {
    let countries = ["USA", "Canada", "UK", "Germany", "France", "Japan", "Australia", "India", "Brazil", "SouthAfrica"]
    @State private var selectedCountry = "United States"

    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Picker("Select a Country", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(country)
                                .foregroundColor(.white) // Set the text color to white
                                .tag(country)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .background(Color.black)
                    .compositingGroup() // This can help with rendering the background properly
                    .padding()


                    Text("Selected Country: \(selectedCountry)")
                        .foregroundColor(.white)
                        .padding()
                    Spacer() // This will push the WorldChartsView to the left
                    ZStack{
                        Color.black.edgesIgnoringSafeArea(.all) // Set the entire background to black
                        TopSongsListView(country: $selectedCountry)
                    }
                    .background(Color.black)

                }
                .background(Color.black)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Set frame to maximum
        .background(Color.black) // Apply the background color
        .edgesIgnoringSafeArea(.all)
    }
}


struct WorldChartsView_Previews: PreviewProvider {
    static var previews: some View {
        WorldChartsView()
    }
}
