import Foundation

struct User: Identifiable, Decodable {
    let id: String
    let profilePicture: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case profilePicture = "profile_pic"
    }
}

struct SearchResult: Decodable {
    let songs: [SearchSong]
    let albums: [SearchAlbum]
    let artists: [SearchArtist]
}

struct SearchSong: Identifiable, Decodable {
    let id: String
    let name: String
    let artistNames: [String] // Because artist_name is an array of strings in JSON
    let picture: URL?
    let releaseDate: Int
    let rate: Int? // Made optional to handle potential null values

    enum CodingKeys: String, CodingKey {
        case id = "song_id"
        case name = "song_name"
        case artistNames = "artist_name"
        case picture
        case releaseDate = "release_date"
        case rate
    }
}

struct SearchAlbum: Identifiable, Decodable {
    let id: String
    let name: String
    let artistName: String // Single string in JSON
    let image: URL?
    let rate: Int? // Made optional to handle potential null values

    enum CodingKeys: String, CodingKey {
        case id = "album_id"
        case name = "album_name"
        case artistName = "artist_name"
        case image
        case rate
    }
}

struct SearchArtist: Identifiable, Decodable {
    let id: String
    let name: String
    let picture: URL?
    let popularity: Int
    let rate: Int? // Made optional to handle potential null values

    enum CodingKeys: String, CodingKey {
        case id = "artist_id"
        case name = "artist_name"
        case picture
        case popularity
        case rate
    }
}
