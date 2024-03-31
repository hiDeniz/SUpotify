//
//  RecommendationView.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 9.12.2023.
//

import SwiftUI

struct RecommendedSong: Identifiable, Decodable {
    let id = UUID() // Her önerilen şarkı için benzersiz bir UUID oluşturacak
    let songName: String
    let artistNames: [String]
    let pictureURL: String
    let songLength: Int
    let songID: String
    var rate: Int?           // New field
    var releaseDate: Int?    // New field

    private enum CodingKeys: String, CodingKey {
        case songName = "song_name"
        case artistNames = "artist_name"
        case pictureURL = "picture"
        case songLength
        case songID = "song_id"
    }
}

func fetchEnrichedRecommendation(user_id: String, genre: String, completion: @escaping ([RecommendedSong]) -> Void) {
    let urlString = "http://127.0.0.1:8008/enrich_rec/\(user_id)/\(genre)"
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            if let decodedResponse = try? JSONDecoder().decode([RecommendedSong].self, from: data) {
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
            } else {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        } else {
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                completion([])
            }
        }
    }.resume()
}

struct  RecommendationView: View {
    @State private var recomendedsongs: [RecommendedSong] = []
    let genre: String
    var body: some View {
        NavigationView {
            VStack {
                Text(genre)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                List(recomendedsongs, id: \.id) { song in
                    DisplayRecommendedSong(song: song)
                        .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                    fetchEnrichedRecommendation(user_id: "yeren", genre: genre) { newSongs in
                        if let newSong = newSongs.randomElement(), !self.recomendedsongs.contains(where: { $0.songID == newSong.songID }) {
                            self.recomendedsongs.append(newSong)
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.blue))
                }
                .padding()

            }
            .background(Color.black)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .statusBar(hidden: true)
        .onAppear {
            apicaller.getRecommendations(for: genre) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let recommendations = try decoder.decode([RecommendedSong].self, from: data)
                        DispatchQueue.main.async {
                            self.recomendedsongs = recommendations
                        }
                    } catch {
                        print("recommendation JSON decode error: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct DisplayRecommendedSong: View {
    var song: RecommendedSong
    @State var songRating = 0  // Örnek bir State değişkeni
    var body: some View {
        HStack {
            if let imageURL = URL(string: song.pictureURL),
               let imageData = try? Data(contentsOf: imageURL),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .padding(.trailing, 8)
            }

            VStack(alignment: .leading) {
                Text("Song Title:")
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
                Text("\(song.songLength) seconds")
                    .foregroundColor(.white)
                SongStarRatingView(rating: $songRating, songId: song.songID)
                
            }
        }
    }
}


// Örnek bir URL'den resim alma işlevi
struct URLImage: View {
    let url: String

    var body: some View {
        // Bu kısım resmi URL'den alacak şekilde değiştirilmelidir
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.gray)
    }
}

//struct RecommendationView_Previews: PreviewProvider {
//static var previews: some View {
//    RecommendationView(genre: ["": ""])
//  }
//}

