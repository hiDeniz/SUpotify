//
//  SpotifyMainPageView.swift
//  SUpotify_Mobile
//
//  Created by Halil İbrahim Deniz on 6.11.2023.
//

import SwiftUI

struct MainPageView: View {
    @State private var playlists: [Playlist] = []
    @State private var rating: Int = 0
    @State public var DarkModeOn = true
    @State private var showSideMenu = false
    @State private var showFriendSideView = false
    @State private var goToUserPage : Bool = false
    @State private var goToSearchPage : Bool = false
    @State private var goToImportExportPage : Bool = false
    @State private var goToSaveSongPage : Bool = false
    @State private var goToAllSongsPage : Bool = false
    @State private var goToMyPlaylist : Bool = false
    @State private var goToImportfromDatabasePage : Bool = false
    @State private var goToStatisticalData : Bool = false
    @State private var goToMerge : Bool = false
    @State private var goToWorldChat : Bool = false
    @State private var goToConcertView : Bool = false
    
    
    init() {
        Color.self.hex = { hex in
            let scanner = Scanner(string: hex)
            var rgbValue: UInt64 = 0
            scanner.scanHexInt64(&rgbValue)
            
            let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
            let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
            let b = Double(rgbValue & 0x0000ff) / 255.0
            
            return Color(red: r, green: g, blue: b)
        }
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                let startColor = Color.hex("#0d2316")
                let endColor = Color.hex("#301629")
                
                LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)
                
                Rectangle()
                    .fill(.black)
                    .frame(width: 370, height: 750)
                    .cornerRadius(15)
                
                VStack {
                    
                    HStack {
                        Button(action: {
                            print(myUser.password)
                            print(myUser.friendsCount)
                            print(myUser.friends)
                            print(myUser.username)
                            withAnimation {
                                showSideMenu.toggle()
                            }
                        }) {
                            Image(systemName: "ellipsis")
                                .resizable()
                                .frame(width: 20, height: 5)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        Text("Evening")
                            .font(Font.custom("Avantgarde Gothic", size: 28))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            DarkModeOn.toggle()
                        }){
                            Image(systemName: "moon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showFriendSideView.toggle()
                            }
                        }) {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading) {
                            Text("Your Playlists")
                                .font(Font.custom("Avantgarde Gothic", size: 24))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(playlists, id: \.playlistID) { playlist in
                                        PlaylistDisplayView(playlist: playlist)
                                    }
                                }
                            }
                            Text("Recommended Genres")
                                .font(Font.custom("Avantgarde Gothic", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            
                            ForEach(musicRecommendations, id: \.genre) { recommendation in
                                RecommendationRow(recommendation: recommendation)
                            }
                            .padding()
                            Text("Recommended Moods")
                                .font(Font.custom("Avantgarde Gothic", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            
                            ForEach(moodRecommendations, id: \.genre) { recommendation in
                                RecommendationRow(recommendation: recommendation)
                            }
                            .padding()

                            Text("Recently Rated Recommendations")
                                .font(Font.custom("Avantgarde Gothic", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            NewRatedSongsRow().padding()
                            Text("New Released Songs")
                                .font(Font.custom("Avantgarde Gothic", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            NewSongRow().padding()
                            Text("Artist Recommendation Based Friend")
                                .font(Font.custom("Avantgarde Gothic", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            FriendArtistRow().padding()
                            
                        }
                    }
                }
                .padding()
                if showSideMenu {
                    SideMenuView(goToUserPage: goToUserPage, goToSearchPage: goToSearchPage, goToImportExportPage: goToImportExportPage, goToSaveSongPage: goToSaveSongPage, goToAllSongsPage: goToAllSongsPage, showSideMenu: showSideMenu, goToImportfromDatabasePage: goToImportfromDatabasePage, goToStatisticalData  : goToStatisticalData, goToMerge: goToMerge, goToWorldChat: goToWorldChat, goToConcertView: goToConcertView)
                }
                if showFriendSideView {
                    FriendsSideView(showFriendSideView: showFriendSideView)
                }
                
            }.navigationBarBackButtonHidden(true)
                    .onAppear{
                        apicaller.getUserPlaylists { fetchedPlaylists in
                            self.playlists = fetchedPlaylists
                        }
                    }
        }.navigationBarBackButtonHidden(true)

        }
    }
