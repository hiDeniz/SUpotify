//
//  User.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 17.11.2023.
//

import Foundation

let myUser = UserData.sharedUser

class UserData: ObservableObject {
    static let sharedUser = UserData()
    
    @Published var email: String
    @Published var password: String
    @Published var username: String
    @Published var profilePicture: String
    @Published var lastListenedSong: String
    @Published var friends: [String]
    @Published var friendsCount: Int
    init()
    {
        email = "default"
        password = "default"
        username = "default"
        profilePicture = "default"
        lastListenedSong = "default"
        friends = []
        friendsCount = 0
    }
}
