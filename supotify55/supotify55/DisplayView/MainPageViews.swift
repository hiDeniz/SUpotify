//
//  MainPageViews.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 17.11.2023.
//

import SwiftUI

struct Recommendation {
    let title: String
    let coverPictureName: String // Dosya adı için String kullanıyoruz
    let genre: String
    
    init(title: String, coverPictureName: String, genre: String) {
        self.title = title
        self.coverPictureName = coverPictureName
        self.genre = genre
    }
}


let musicRecommendations: [Recommendation] = [
    Recommendation(
        title: "Epic Rock Anthems",
        coverPictureName: "rock", // Assets'teki rockImage görsel adı
        genre: "Rock"
    ),
    Recommendation(
        title: "Smooth Jazz Vibes",
        coverPictureName: "jazz", // Assets'teki jazzImage görsel adı
        genre: "Jazz"
    ),
    Recommendation(
        title: "Electro Beats Mix",
        coverPictureName: "electronic", // Assets'teki electroImage görsel adı
        genre: "Electronic"
    ),
    Recommendation(
        title: "Country Roads Playlist",
        coverPictureName: "country", // Assets'teki countryImage görsel adı
        genre: "Country"
    ),
    Recommendation(
        title: "Pop Hits Collection",
        coverPictureName: "pop", // Assets'teki popImage görsel adı
        genre: "Pop"
    )
]
let moodRecommendations : [Recommendation] = [
    Recommendation(
        title: "Cheerful Melodies Mix",
        coverPictureName: "happymood", // Assets'teki rockImage görsel adı
        genre: "happy"
    ),
    Recommendation(
        title: "Sadness in Sound",
        coverPictureName: "sadmood", // Assets'teki jazzImage görsel adı
        genre: "sad"
    ),
    Recommendation(
        title: "Serenity Falls",
        coverPictureName: "chillmood", // Assets'teki electroImage görsel adı
        genre: "chill"
    ),
    Recommendation(
        title: "Twilight Echoes",
        coverPictureName: "ambientmood", // Assets'teki countryImage görsel adı
        genre: "ambient"
    ),
    Recommendation(
        title: "Gentle Melodies Haven",
        coverPictureName: "housemood", // Assets'teki popImage görsel adı
        genre: "house"
    )
]
let newSongsRecommendation = Recommendation(title: "2023 Songs", coverPictureName: "2023Cover", genre: "Random")
struct SideMenuView: View {
    @State var goToUserPage : Bool
    @State var goToSearchPage : Bool
    @State var goToImportExportPage : Bool
    @State var goToSaveSongPage : Bool
    @State var goToAllSongsPage : Bool
    @State var showSideMenu: Bool
    @State var goToImportfromDatabasePage : Bool
    @State var goToStatisticalData : Bool
    @State var goToMerge : Bool
    @State var goToWorldChat : Bool
    @State var goToConcertView : Bool
    var body: some View {
        ZStack {
            // Dark overlay to disable the background view
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.5))
            .opacity(showSideMenu ? 1 : 0)
            .animation(Animation.easeIn.delay(0.25))
            .onTapGesture {
                withAnimation {
                    showSideMenu = false
                }
            }

            // Side menu content
            HStack {
                MenuContent()
                    .frame(width: 250)
                    .background(Color.black) // Set the side menu background to black
                    .offset(x: showSideMenu ? 0 : -250)
                    .transition(.move(edge: .trailing))
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private func MenuContent() -> some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation {
                    showSideMenu = false
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 40) // To push down from the top edge
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Profile and other menu items
            NavigationLink(destination: UserView(), isActive: $goToUserPage) {
                Button("View Profile") {
                    goToUserPage = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: SearchView(), isActive: $goToSearchPage) {
                Button("Search Item") {
                    goToSearchPage = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: ImportExportView(), isActive: $goToImportExportPage) {
                Button("Import/Export File") {
                    goToImportExportPage = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: SongRegistrationView(), isActive: $goToSaveSongPage) {
                Button("Save Song") {
                    goToSaveSongPage = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: AllSongsView(), isActive: $goToAllSongsPage) {
                Button("All Songs") {
                    goToAllSongsPage = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: StatisticalDataView(), isActive: $goToStatisticalData) {
                Button("Statistical Data") {
                    goToStatisticalData = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: MergeTwoPlaylists(), isActive: $goToMerge) {
                Button("Merge Playlist") {
                    goToMerge = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: WorldChartsView(), isActive: $goToWorldChat) {
                Button("World Chart") {
                    goToWorldChat = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            NavigationLink(destination: ConcertView(), isActive: $goToConcertView) {
                Button("Event List") {
                    goToConcertView = true
                    showSideMenu = false
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FriendRowView: View {
    @State private var friendName: String
    @State private var friendActivity: String
    @State private var profilePicture: String?
    
    init(friendName: String, friendActivity: String, profilePicture: String?) {
        self._friendName = State(initialValue: friendName)
        self._friendActivity = State(initialValue: friendActivity)
        self._profilePicture = State(initialValue: profilePicture)
    }
    
    var body: some View {
        HStack {
            if let profilePictureURLString = profilePicture,
               let profilePictureURL = URL(string: profilePictureURLString) {
                AsyncImage(url: profilePictureURL) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading) {
                Text(friendName)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(friendActivity)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
    }
}


struct FriendActivity: Decodable, Hashable {
    let lastListenedSong: String
    let name: String
    let profilePicture: String?
}

struct FriendsSideView: View {
    @State var showFriendSideView: Bool
    @State var allFriendsActivity : [FriendActivity] = []
    var body: some View {
        ZStack {
            // Dark overlay to disable the background view
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.5))
            .opacity(showFriendSideView ? 1 : 0)
            .animation(Animation.easeIn.delay(0.25))
            .onTapGesture {
                withAnimation {
                    showFriendSideView = false
                }
            }

            // Side view content
            HStack {
                Spacer()
                friendsMenuContent
                    .frame(width: 250)
                    .background(Color.black) // Set the side view background to black
                    .offset(x: showFriendSideView ? 0 : 250) // Adjust the offset to slide in from the right
                    .transition(.move(edge: .trailing)) // Use trailing edge for right-to-left appearance
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // `friendsMenuContent` as a computed property
    private var friendsMenuContent: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation {
                    showFriendSideView = false
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 40)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            ForEach(allFriendsActivity, id: \.self) { friend in
                FriendRowView(friendName: friend.name, friendActivity: friend.lastListenedSong, profilePicture: friend.profilePicture)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear{
            fetchFriendsActivity()
        }
    }
    private func fetchFriendsActivity() {
        guard let url = URL(string: "http://127.0.0.1:8008/friends_activity/\(myUser.username)") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([FriendActivity].self, from: data) {
                    DispatchQueue.main.async {
                        self.allFriendsActivity = decodedResponse
                    }
                }
            }
        }
        task.resume()
    }
}

struct RecommendationRow: View {
    let recommendation: Recommendation

    var body: some View {
        NavigationLink(destination: RecommendationView(genre : recommendation.genre)) {
            HStack(spacing: 10) {
                Image(recommendation.coverPictureName)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.5))
                VStack(alignment: .leading) {
                    Text(recommendation.title)
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .foregroundStyle(Color.cyan)
                }
                .foregroundColor(.white)
            }
            .frame(height: 100)
        }
    }
}
struct NewSongRow: View {
    var body: some View {
        NavigationLink(destination: NewSongsView()) {
            HStack(spacing: 10) {
                Image("2023cover")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.5))
                                
                VStack(alignment: .leading) {
                    Text("Top Hits Of 2023")
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .foregroundStyle(Color.cyan)
                }
                .foregroundColor(.white)
            }
            .frame(height: 100)
        }
    }
}

struct NewRatedSongsRow: View {
    var body: some View {
        NavigationLink(destination: NewlyRatedRecommendationView()) {
            HStack(spacing: 10) {
                Image("kopke")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.5))
                                
                VStack(alignment: .leading) {
                    Text("The Recent Hitlist: Personal Favorites")
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .foregroundStyle(Color.cyan)
                }
                .foregroundColor(.white)
            }
            .frame(height: 100)
        }
    }
}
struct FriendArtistRow: View {
    var body: some View {
        NavigationLink(destination: FriendArtistRecommendations()) {
            HStack(spacing: 10) {
                Image("yakisikliguvenlik")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.5))
                                
                VStack(alignment: .leading) {
                    Text("Friendship-Fueled Artist Suggestions")
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .foregroundStyle(Color.cyan)
                }
                .foregroundColor(.white)
            }
            .frame(height: 100)
        }
    }
}

struct PlaylistDisplayView: View {
    @State private var goToMyPlaylist: Bool = false
    let playlist: Playlist // Assuming you have a Playlist instance to display
    
    @State private var playlistImage: UIImage? // State variable to hold the image
    let placeholderImage = UIImage(systemName: "photo") // Placeholder image
    
    var body: some View {
        NavigationLink(destination: PlaylistView(playlistID: playlist.playlistID), isActive: $goToMyPlaylist) {
            HStack(spacing: 10) {
                // Cover Page on the left
                if let image = playlistImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.5))
                } else {
                    Image(uiImage: placeholderImage ?? UIImage(systemName: "photo")!)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.5))
                }

                VStack(alignment: .leading) {
                    Text(playlist.name)
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .foregroundStyle(Color.cyan)
                }
                .foregroundColor(.white)
            }
            .frame(height: 100)
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to remove default button styles
        
        .onTapGesture {
            // Activate the NavigationLink when tapped
            goToMyPlaylist = true
        }
        .onAppear {
            // Load image asynchronously when the view appears
            loadImage(from: playlist.playlistPic)
        }
    }

    // Function to load image asynchronously from URL
    private func loadImage(from url: URL?) {
        guard let imageURL = url else {
            return
        }

        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: imageURL)
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.playlistImage = loadedImage
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}
