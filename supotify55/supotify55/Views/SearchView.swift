import SwiftUI
import Foundation

// UserResultRow
struct UserResultRow: View {
    var user: User
    @State private var weAreFriend : Bool
    init(user: User) {
        self.user = user
        self._weAreFriend = State(initialValue: myUser.friends.contains(user.id))
    }
    var body: some View {
        NavigationLink(destination: FriendView(friendusername: user.id)) {
            HStack {
                if let url = user.profilePicture {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white) // Set the color to white
                }
                Text(user.id)
                    .foregroundColor(.white)
                Spacer()
                if (weAreFriend) {
                    Button(action: {
                        // Define the URL for the remove_friend endpoint with the user_id
                        let removeFriendURL = URL(string: "http://127.0.0.1:8008/remove_friend/\(myUser.username)")!
                        
                        // Define the friend_id to remove
                        let friendIDToRemove = user.id
                        
                        // Create the request payload
                        let requestData: [String: Any] = ["friend_id": friendIDToRemove]
                        
                        // Prepare the URLRequest
                        var request = URLRequest(url: removeFriendURL)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
                        
                        // Create URLSession task for the request
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            // Handle the response or error here
                            if let error = error {
                                print("Error: \(error)")
                            } else if let data = data, let response = response as? HTTPURLResponse {
                                // Check response status code
                                if response.statusCode == 200 {
                                    // Successful removal
                                    print("Friend removed successfully")
                                    myUser.friends.removeAll { $0 == user.id }
                                    weAreFriend = false
                                } else {
                                    // Handle other status codes if needed
                                    print("Error: \(response.statusCode)")
                                }
                            }
                        }
                        
                        // Start the URLSession task
                        task.resume()
                        
                    }) {
                        Text("Remove")
                            .foregroundColor(.red) // Customize button style
                    }
                }
                else {
                    Button(action: {
                        // Define the URL for the add_friend endpoint with the user_id
                        let addFriendURL = URL(string: "http://127.0.0.1:8008/add_friend/\(myUser.username)")!
                        
                        // Define the friend_id to add
                        let friendIDToAdd = user.id
                        
                        // Prepare the request payload
                        let requestData: [String: Any] = ["friend_id": friendIDToAdd]
                        
                        // Create the URLRequest
                        var request = URLRequest(url: addFriendURL)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
                        
                        // Create URLSession task for the request
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            // Handle the response or error here
                            if let error = error {
                                print("Error: \(error)")
                            } else if let data = data, let response = response as? HTTPURLResponse {
                                // Check response status code
                                if response.statusCode == 200 {
                                    // Successful addition
                                    print("Friend added successfully")
                                    myUser.friends.append(user.id)
                                    print(myUser.$friends)
                                    weAreFriend = true
                                } else {
                                    // Handle other status codes if needed
                                    print("Error: \(response.statusCode)")
                                }
                            }
                        }
                        task.resume()
                        
                    }) {
                        Text("Add")
                            .foregroundColor(.green) // Customize button style
                    }
                }
            }
        }
    }
}

// SongResultRow
struct SongResultRow: View {
    var song: SearchSong
    @State private var rating: Int

    init(song: SearchSong) {
        print(song)
        self.song = song
        _rating = State(initialValue: song.rate ?? 5)
    }
    var body: some View {
        NavigationLink(destination: LyricsView(artistNames: song.artistNames, songName: song.name)) {
            HStack {
                if let url = song.picture {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    Text(song.name)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text("Artist: \(song.artistNames.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    SongStarRatingView(rating: $rating, songId: song.id)
                }
                Spacer() // Pushes the button to the rightmost side
                Button(action: {
                    guard let url = URL(string: "http://127.0.0.1:8008/delete_song/\(song.id)") else { return }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST" // Use POST method to delete a song

                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            print("Status code: \(httpResponse.statusCode)")
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Deletion Successfull", message: "Song with name \(song.name) is deleted from database", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                // Access the top-most view controller to present the alert
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }                        }
                    }.resume()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red) // Customize the button appearance
                }
                .buttonStyle(PlainButtonStyle())


            }
        }
    }
}

// AlbumResultRow
struct AlbumResultRow: View {
    var album: SearchAlbum
    @State private var rating: Int

    init(album: SearchAlbum) {
        self.album = album
        _rating = State(initialValue: album.rate ?? 0)
    }

    var body: some View {
        HStack {
            if let url = album.image {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                Text(album.name)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Artist: \(album.artistName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                AlbumStarRatingView(rating: $rating, albumId: album.id)
            }
            Spacer() // Pushes the button to the rightmost side
            Button(action: {
                guard let url = URL(string: "http://127.0.0.1:8008/delete_album/\(album.id)") else { return }

                var request = URLRequest(url: url)
                request.httpMethod = "POST" // Use POST method to delete a song

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status code: \(httpResponse.statusCode)")
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Deletion Successfull", message: "Album with name \(album.name) is deleted from database", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            // Access the top-most view controller to present the alert
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                        }                        }
                }.resume()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red) // Customize the button appearance
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// ArtistResultRow
struct ArtistResultRow: View {
    var artist: SearchArtist
    @State private var rating: Int

    init(artist: SearchArtist) {
        self.artist = artist
        _rating = State(initialValue: artist.rate ?? 0)
    }

    var body: some View {
        HStack {
            if let url = artist.picture {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "person.crop.square")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                Text(artist.name)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Text("Popularity: \(artist.popularity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                ArtistStarRatingView(rating: $rating, artistId: artist.id)
            }
            Spacer() // Pushes the button to the rightmost side
            Button(action: {
                guard let url = URL(string: "http://127.0.0.1:8008/delete_artist/\(artist.id)") else { return }

                var request = URLRequest(url: url)
                request.httpMethod = "POST" // Use POST method to delete a song

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status code: \(httpResponse.statusCode)")
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Deletion Successfull", message: "Artist with name \(artist.name) is deleted from database", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            // Access the top-most view controller to present the alert
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                        }                        }
                }.resume()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red) // Customize the button appearance
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


// SearchView
struct SearchView: View {
    @State private var searchText = ""
    @State private var searchOption = "User"
    let searchOptions = ["User", "Song/Artist/Album"]
    @State private var userResults: [User] = []
    @State private var itemResults: SearchResult? // For song/artist/album search results
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all) // Set the background color of the ZStack to black
            VStack {
                Picker("Search Type", selection: $searchOption) {
                    ForEach(searchOptions, id: \.self) { option in
                        Text(option).foregroundColor(.blue)
                    }
                }
                .foregroundColor(.blue)
                .padding()
                
                TextField("Search...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                Button("Search") {
                    self.search()
                }
                .padding()
                
                if isLoading {
                    ProgressView()
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Group {
                    if searchOption == "User" {
                        ZStack{
                            Color.black.edgesIgnoringSafeArea(.all) // Set the background color of the ZStack to black
                            ScrollView {
                                VStack {
                                    Section(header: Text("Users")
                                        .foregroundColor(.white)) {
                                            ForEach(userResults) { user in
                                                UserResultRow(user: user).padding()
                                            }
                                    }
                                }
                            }

                        }
                    } else if let items = itemResults {
                        ZStack{
                            Color.black.edgesIgnoringSafeArea(.all) // Set the background color of the ZStack to black
                            ScrollView {
                                VStack {
                                    Section(header: Text("Songs")
                                        .foregroundColor(.white)) {
                                        ForEach(items.songs) { song in
                                            SongResultRow(song: song).padding()
                                        }
                                        }
                                        .padding()
                                    
                                    Section(header: Text("Albums")
                                        .foregroundColor(.white)) {
                                        ForEach(items.albums) { album in
                                            AlbumResultRow(album: album).padding()
                                        }
                                        }
                                        .padding()
                                    
                                    Section(header: Text("Artists")
                                        .foregroundColor(.white)) {
                                        ForEach(items.artists) { artist in
                                            ArtistResultRow(artist: artist).padding()
                                        }
                                        .padding()

                                    }
                                }
                            }

                        }
                    } else {
                        Text("No results found for items.")
                    }
                }
                Spacer()
            }}
            .background(Color.black) // Set the background color of the HStack
            .navigationBarTitle("Search", displayMode: .inline)
            .navigationBarColor(.black, textColor: .white)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func search() {
        isLoading = true
        errorMessage = nil

        if searchOption == "User" {
            apicaller.searchUsers(searchTerm: searchText) { result in
                isLoading = false
                switch result {
                case .success(let users):
                    self.userResults = users
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        } else {
            apicaller.searchItems(userId: "yourUserId", searchTerm: searchText) { result in
                isLoading = false
                switch result {
                case .success(let items):
                    self.itemResults = items
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor

    func body(content: Content) -> some View {
        content
            .onAppear {
                let coloredAppearance = UINavigationBarAppearance()
                coloredAppearance.configureWithOpaqueBackground()
                coloredAppearance.backgroundColor = backgroundColor
                coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
                coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]

                UINavigationBar.appearance().standardAppearance = coloredAppearance
                UINavigationBar.appearance().compactAppearance = coloredAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
                UINavigationBar.appearance().tintColor = textColor
            }
    }
}

extension View {
    func navigationBarColor(_ backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

struct ArtistStarRatingView: View {
    @Binding var rating: Int
    @State public var artistId: String
    @State private var jsonData: [String: Any] = [
        "artist_id": "",
        "user_id": myUser.username,
        "rating": 2
    ]

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(index <= rating ? .yellow : .gray)
                    .onTapGesture {
                        updateRating(index)
                        
                    }
            }
        }
    }

    private func updateRating(_ index: Int) {
            rating = index
            jsonData["artist_id"] = artistId
            jsonData["rating"] = index
            print(jsonData)

            // Convert jsonData to Data
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData) {
                // URL of the endpoint
                let url = URL(string: "http://127.0.0.1:8008/change_rating_artist")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // Perform the request
                URLSession.shared.dataTask(with: request) { data, response, error in
                    // Handle response or error here
                    if let error = error {
                        print("Error: \(error)")
                    } else if let data = data {
                        // Handle the data received from the server if needed
                        print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                }.resume()
            }
        }
}

struct AlbumStarRatingView: View {
    @Binding var rating: Int
    @State public var albumId: String
    @State private var jsonData: [String: Any] = [
        "album_id": "",
        "user_id": myUser.username,
        "rating": 1
    ]

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(index <= rating ? .yellow : .gray)
                    .onTapGesture {
                        updateRating(index)
                        
                    }
            }
        }
    }

    private func updateRating(_ index: Int) {
            rating = index
            jsonData["album_id"] = albumId
            jsonData["rating"] = index
        print(jsonData)

            // Convert jsonData to Data
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData) {
                // URL of the endpoint
                let url = URL(string: "http://127.0.0.1:8008/change_rating_album")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                URLSession.shared.dataTask(with: request) { data, response, error in
                    // Handle response or error here
                    if let error = error {
                        print("Error: \(error)")
                    } else if let data = data {
                        // Handle the data received from the server if needed
                        print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                }.resume()
            }
        }
}
