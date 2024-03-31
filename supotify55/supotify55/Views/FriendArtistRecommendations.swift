//
//  FriendArtistRecommendations.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 11.12.2023.
//

import SwiftUI
import Combine

// Adapted Artist model to resemble the Song model
struct Artist2: Identifiable, Decodable {
    var id = UUID()  // UUID for Identifiable conformance
    let artistID: String
    let artistName: String
    let followers: Int
    let genres: String
    let picture: URL   // Changed to URL for consistency
    let popularity: Int

    // Custom decoding keys similar to Song7
    enum CodingKeys: String, CodingKey {
        case artistID = "artist_id"
        case artistName = "artist_name"
        case followers
        case genres
        case picture
        case popularity
    }
}

// Adapted main data model to follow the second block's approach
struct ArtistsData: Decodable {
    let recommendations: [Artist2]
}

class ArtistsViewModel: ObservableObject {
    @Published var artistsData: ArtistsData?  // Use the original published property
    @Published var isLoading = false

    // Using the original working function
    func fetchArtistData() {
        isLoading = true
        let urlString = "http://127.0.0.1:8008/yeren/friend_artist_recommendations"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(ArtistsData.self, from: data) {
                        self?.artistsData = decodedResponse
                        return
                    }
                }
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}
// Adapted SwiftUI view for displaying each artist
struct ArtistView: View {
    let artist: Artist2
    @State private var rating : Int = 0
    init(artist: Artist2) {
        self.artist = artist
    }

    var body: some View {
        HStack {
            AsyncImage(url: artist.picture) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(artist.artistName)
                    .font(.headline)
                Text("Followers: \(artist.followers)")
                    .font(.subheadline)
                Text("Popularity: \(artist.popularity)")
                    .font(.subheadline)
                ArtistStarRatingView(rating: $rating, artistId: artist.artistID)
            }
            
            Spacer()
        }
    }
}

struct FriendArtistRecommendations: View {
    @StateObject var viewModel = ArtistsViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack{
                    Text("Friend Artist Recommendations")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
                VStack {
                    if viewModel.isLoading {
                        Text("Loading...")
                            .foregroundColor(.white)
                    } else if let artists = viewModel.artistsData?.recommendations {
                        ForEach(artists) { artist in
                            ArtistRowView(artist: artist)
                                .background(Color.black) // Set each row's background to black
                        }
                    } else {
                        Text("Failed to load artists")
                            .foregroundColor(.white)
                    }
                }
                .background(Color.black) // Set the VStack background to black
            }
            .background(Color.black) // Set the ScrollView background to black
            .onAppear {
                viewModel.fetchArtistData()
            }
            .navigationBarHidden(true)
        }
    }
}

// ArtistRowView to display each artist in HStack and VStack
struct ArtistRowView: View {
    let artist: Artist2
    @State private var rating : Int = 0

    var body: some View {
        HStack {
            AsyncImage(url: artist.picture) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                    Text(artist.artistName)
                        .font(.headline)
                        .foregroundColor(.white) // Set text color to white
                    Text("Followers: \(artist.followers)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("Genres: \(artist.genres)")
                        .font(.subheadline)
                        .foregroundColor(.white) // Set text color to white
                    Text("Popularity: \(artist.popularity)")
                        .font(.subheadline)
                        .foregroundColor(.white) // Set text color to white
                ArtistStarRatingView(rating: $rating, artistId: artist.artistID)
            }

            Spacer()
        }
        .padding()
        .background(Color.black) // Set the HStack background to black
    }
}


// The preview for SwiftUI Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FriendArtistRecommendations()
    }
}

