import Foundation

struct Friend {
    var name: String
    var photo: String // This could be a URL or a local asset name
    var lastSong: String
}

//let myFriend = FriendData.sharedUser
//
//class FriendData: ObservableObject {
//    static let sharedUser = FriendData()
//    
//    @Published var email: String
//    @Published var username: String
//    @Published var profilePicture: String
//    @Published var lastListenedSong: String
//    @Published var friends: [String]
//    @Published var friendsCount: Int
//    
//    init()
//    {
//        email = "default"
//        username = "default"
//        profilePicture = "default"
//        lastListenedSong = "default"
//        friends = []
//        friendsCount = 0
//    }
//}
