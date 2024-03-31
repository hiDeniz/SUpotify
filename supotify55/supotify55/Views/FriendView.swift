import SwiftUI
import SwiftUICharts
import Combine

struct FriendData: Decodable {
    var friends: [String]
    var friendsCount: Int
    var lastListenedSong: String?  // It's an optional String now
    var profilePicture: String?
    var username: String
    init(username: String = "") {
        self.username = username
        self.friends = []
        self.friendsCount = 0
        self.lastListenedSong = ""
        self.profilePicture = ""
    }
}


class NetworkServiceFriend {
    func fetchSongs(forUserId userId: String, completion: @escaping (Result<HighlyRated90sSongsResponse, Error>) -> Void) {
        let urlString = "http://127.0.0.1:8008/\(userId)/90s"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error when fetching songs: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data was returned by the request!")
                return
            }

            // Debug print for raw data
            print("Raw data received: \(data)")

            // Optionally, convert the data to a string and print it
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON String received: \(jsonString)")
            }

            do {
                let songsResponse = try JSONDecoder().decode(HighlyRated90sSongsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(songsResponse))
                }
            } catch {
                print("JSON decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

func fetchMostRatedFriendSongs(username: String, completion: @escaping ([Song6]) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:8008/\(username)/most_rated_songs") else {
        print("Invalid URL")
        return
    }

    let request = URLRequest(url: url)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            if let decodedResponse = try? JSONDecoder().decode(MostRatedSongsResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(decodedResponse.most_rated_songs)
                }
                return
            }
        }
        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }.resume()
}

struct FriendView: View {
    @StateObject var viewModel = RatingsViewModel()
    @StateObject var fetcher = ArtistFetcher()
    @State private var playlists: [Playlist] = []
    @State private var songs: [Song3] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var goToPlaylist : Bool = false
    @State private var songs2 = [Song6]()
    @State private var currentFriend: FriendData
    let friendusername: String

    init(friendusername: String) {
        self.friendusername = friendusername
        self._currentFriend = State(initialValue: FriendData(username: friendusername))
    }
    
    var body: some View {

        NavigationView {
            ScrollView {
                VStack {
                    VStack(alignment: .center, spacing: 20) {
                        AsyncImage(url: URL(string: currentFriend.profilePicture ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray) // Placeholder color
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))

                        Text(friendusername)
                            .font(.title2)
                            .foregroundColor(.white) // White color for username

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.3.fill") // Friends icon
                                    .foregroundColor(.white)
                                Text("\(currentFriend.friends.count) Friends")
                                    .foregroundColor(.white) // White color
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Text("Playlists")
                        .font(.headline)
                        .padding(.top, 20)
                        .foregroundColor(.white) // White color for "Playlists" text

                    // Vertical scroll view for playlists
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(playlists, id: \.playlistID) { playlist in
                                PlaylistDisplayView(playlist: playlist)
                            }
                        }
                    }
                    Spacer(minLength: 60)
                }

                VStack {
                    Text("90's Songs") // Başlık ekleniyor
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.bottom, 4) // Başlığın altındaki boşluğu ayarlamak için
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else if !songs.isEmpty {
                        ForEach(songs, id: \.title) { song in
                            HStack {

                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(song.artist.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Text("Release Year: \(song.releaseYear)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Text("Rating: \(song.rate)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No songs found")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .onAppear {
                    print("start decoding")

                    guard let url = URL(string: "http://127.0.0.1:8008/user_data_username/\(friendusername)") else {
                                    print("Invalid URL")
                                    return
                                }

                                URLSession.shared.dataTask(with: url) { data, response, error in
                                    if let error = error {
                                        print("Error with fetching data: \(error)")
                                        return
                                    }

                                    guard let data = data else {
                                        print("No data was returned by the request!")
                                        return
                                    }
                                    print("Raw data received: \(String(data: data, encoding: .utf8) ?? "Invalid data encoding")")
                                    do {
                                        let decodedFriendData = try JSONDecoder().decode(FriendData.self, from: data)
                                        DispatchQueue.main.async {
                                            print("lets check : ")
                                            print(decodedFriendData)

                                            self.currentFriend = decodedFriendData
                                        }
                                    } catch {
                                        print("Error decoding data: \(error)")
                                    }
                                }.resume()
                    print("end of  decoding")

                    apicaller.getUserPlaylists { fetchedPlaylists in
                        self.playlists = fetchedPlaylists // Update state with fetched playlists
                    }
                    isLoading = true
                    NetworkServiceFriend().fetchSongs(forUserId: friendusername) { result in
                        isLoading = false
                        switch result {
                        case .success(let response):
                            songs = response.highlyRated90sSongs
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                        
                    }
                    
                }
                VStack {
                                Text("Most Rated Songs")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()

                                ScrollView {
                                    VStack {
                                        ForEach(songs2, id: \.id) { song in
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(song.song_name)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                    Text(song.album_name)
                                                        .foregroundColor(.gray)
                                                    Text("Artists: \(song.artists.joined(separator: ", "))")
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                AsyncImage(url: URL(string: song.picture))
                                                    .frame(width: 50, height: 50)
                                                    .aspectRatio(contentMode: .fill)
                                                    .clipped()
                                            }
                                            .padding()
                                            .background(Color.black)
                                        }
                                    }
                                }
                                .background(Color.black)
                            }
                            .onAppear {
                                fetchMostRatedFriendSongs(username: friendusername) { songs in
                                    self.songs2 = songs
                                }
                            }
            }
            .padding(20)
            .navigationBarHidden(true)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

