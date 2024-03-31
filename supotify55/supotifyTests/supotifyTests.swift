//
//  supotifyTests.swift
//  supotifyTests
//
//  Created by Ayça Ataer on 21.01.2024.
//

import XCTest
@testable import supotify55

struct RecommendedSong2: Identifiable, Decodable {
    let id = UUID()
    let songName: String
    let artistName: String // Corrected to a single String
    let pictureURL: String
    let songLength: Int
    let songID: String

    private enum CodingKeys: String, CodingKey {
        case songName = "song_name"
        case artistName = "artist_name" // Now a single String to match JSON
        case pictureURL = "picture"
        case songLength
        case songID = "song_id"
    }
}

struct MostRatedSongsResponse: Decodable {
    let mostRatedSongs: [Song6]
    
    private enum CodingKeys: String, CodingKey {
        case mostRatedSongs = "most_rated_songs"
    }
}


final class supotifyTests: XCTestCase {
    
    private var apicaller = APICaller.apicaller
    private var playlists: [Playlist]!
    private var artists: [Artist2]!
    private var recommendedSongs: [RecommendedSong2]!
    private var newSongs: [newSongModel]!
    private var mostRatedSongs: [Song6]!
    var songSuggestions: [SongSuggestion]!

    override func setUp() {
        super.setUp()
        playlists = .init()
        artists = .init()
        recommendedSongs = .init()
        newSongs = .init()
        mostRatedSongs = .init()
        songSuggestions = .init()
    }
    
    override func tearDown() {
        playlists = nil
        artists = nil
        recommendedSongs = nil
        newSongs = nil
        mostRatedSongs = nil
        songSuggestions = nil
        super.tearDown()
    }
    
    func testRetrieveSuggestionsParsesCorrectly() {
        retrieveSuggestions()
        XCTAssertNotEqual(songSuggestions.count, 0, "Song suggestions list should not be empty after parsing")
    }


    func testSongSuggestionDataValidity() {
        retrieveSuggestions()
        for suggestion in songSuggestions {
            XCTAssertFalse(suggestion.songName.isEmpty, "Song name should not be empty")
            XCTAssertFalse(suggestion.artistNames.isEmpty, "Artist names should not be empty")
            XCTAssertFalse(suggestion.picture.isEmpty, "Picture URL should not be empty")
            XCTAssert(suggestion.songLength > 0, "Song length should be greater than 0")
            XCTAssertFalse(suggestion.songId.isEmpty, "Song ID should not be empty")
        }
    }
    
    private func retrieveSuggestionsWithFileName(_ fileName: String) {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("Missing file: \(fileName).json")
            return
        }

        do {
            let jsonData = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                parseJSON(json)
            } else {
                XCTFail("JSON data could not be parsed")
            }
        } catch {
            XCTFail("Error parsing JSON: \(error.localizedDescription)")
        }
    }

    private func parseJSON(_ json: [[String: Any]]) {
        for suggestionData in json {
            if let songName = suggestionData["song_name"] as? String,
               let artistNames = suggestionData["artist_name"] as? [String],
               let picture = suggestionData["picture"] as? String,
               let songLength = suggestionData["songLength"] as? Int,
               let songId = suggestionData["song_id"] as? String {

                let suggestion = SongSuggestion(songName: songName, artistNames: artistNames, picture: picture, songLength: songLength, songId: songId)
                songSuggestions.append(suggestion)
            }
        }
    }

    private func retrieveSuggestions() {
        retrieveSuggestionsWithFileName("recommendationByTrack")
    }
    
    
    // Test for Correct Playlist Names
    func testPlaylistNamesAreCorrect() {
        playlistJSONParsing()
        for playlist in playlists {
            XCTAssertFalse(playlist.name.isEmpty, "Playlist name should not be empty")
        }
    }


    // Test for Non-Negative Song Numbers
    func testPlaylistSongNumbersAreNonNegative() {
        playlistJSONParsing()
        for playlist in playlists {
            XCTAssert(playlist.songNumber >= 0, "Playlist song number should be non-negative")
        }
    }

    // Test for Playlist IDs Format
    func testPlaylistIDsMatchExpectedFormat() {
        playlistJSONParsing()
        for playlist in playlists {
            // Assuming Spotify IDs are non-empty alphanumeric strings
            let idRegex = "^[0-9a-zA-Z]+$"
            let idTest = NSPredicate(format:"SELF MATCHES %@", idRegex)
            XCTAssertTrue(idTest.evaluate(with: playlist.playlistID), "Playlist ID does not match expected format")
        }
    }

    // Test for Playlist Object Integrity
    func testPlaylistObjectIntegrity() {
        playlistJSONParsing()
        for playlist in playlists {
            XCTAssertNotNil(playlist.name, "Playlist name should not be nil")
            XCTAssertNotNil(playlist.playlistID, "Playlist ID should not be nil")
            XCTAssertNotNil(playlist.playlistPic, "Playlist picture URL should not be nil")
            // Add similar checks for any other properties that must not be nil
        }
    }

    
    func test_userPlaylists() {
        XCTAssertEqual(playlists.count, 0, "list is empty")
        playlistJSONParsing()
        XCTAssertEqual(playlists.count, 10)
        XCTAssertEqual(playlists[0].name, "Zeey + 6 others")
        XCTAssertEqual(playlists[0].playlistID, "37i9dQZF1EJG9CeXAz76yo")
    }
    
    func playlistJSONParsing() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "userPlaylist", withExtension: "json") else {
            XCTFail("Missing file: userPlaylist.json")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                for playlistData in json {
                    let playlist = Playlist()
                    playlist.name = playlistData["name"] as? String ?? "default"
                    playlist.playlistID = playlistData["playlistID"] as? String ?? "default"
                    if let picString = playlistData["playlistPic"] as? String, let picURL = URL(string: picString) {
                        playlist.playlistPic = picURL
                    }
                    playlist.songNumber = playlistData["songNumber"] as? Int ?? -1
                    playlists.append(playlist)
                }
                XCTAssertNotEqual(playlists.count, 0, "The playlist should not be empty")
            } else {
                XCTFail("JSON data could not be parsed")
            }
        } catch {
            XCTFail("Error reading JSON data: \(error.localizedDescription)")
        }
    }
    
    func testFriendArtistReccomendation(){
        XCTAssertEqual(artists.count, 0)
        artistJSONParsing()
        XCTAssertEqual(artists.count, 8)
        XCTAssertEqual(artists[0].artistName, "Nora En Pure")
        XCTAssertEqual(artists[0].followers, 401806 )
        
    }
    
    func artistJSONParsing() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "friend_artist_recommendations", withExtension: "json") else {
            XCTFail("Missing file: friend_artist_recommendations.json")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let recommendations = json["recommendations"] as? [[String: Any]] {
                
                for artistData in recommendations {
                    let artist = Artist2(
                        artistID: artistData["artist_id"] as? String ?? "default",
                        artistName: artistData["artist_name"] as? String ?? "default",
                        followers: artistData["followers"] as? Int ?? -1,
                        genres: artistData["genres"] as? String ?? "default",
                        picture: URL(string: artistData["picture"] as? String ?? "")!,
                        popularity: artistData["popularity"] as? Int ?? -1
                    )
                    artists.append(artist)
                }
                
            } else {
                XCTFail("JSON data could not be parsed")
            }
        } catch {
            XCTFail("Error reading JSON data: \(error.localizedDescription)")
        }
    }
    
    // Test for Valid Song IDs
    func testSongIDsAreValid() {
        let expectation = XCTestExpectation(description: "ValidSongIDs")
        
        recommendedSongJSONParsing { songs in
            for song in songs {
                XCTAssertFalse(song.songID.isEmpty, "Song ID should not be empty")
                // Add regex matching if there's a specific ID format
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }


    // Test for Valid Picture URLs
    func testPictureURLsAreValid() {
        let expectation = XCTestExpectation(description: "ValidPictureURLs")
        
        recommendedSongJSONParsing { songs in
            for song in songs {
                XCTAssertNotNil(URL(string: song.pictureURL), "Picture URL should be a valid URL")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    // Test for Valid Song Lengths
    func testSongLengthsAreValid() {
        let expectation = XCTestExpectation(description: "ValidSongLengths")
        
        recommendedSongJSONParsing { songs in
            for song in songs {
                XCTAssert(song.songLength > 0, "Song length should be a positive integer")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    // Test for Valid Song Names
    func testSongNamesAreValid() {
        let expectation = XCTestExpectation(description: "ValidSongNames")
        
        recommendedSongJSONParsing { songs in
            for song in songs {
                XCTAssertFalse(song.songName.isEmpty, "Song name should not be empty")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    
    func testRecommendedSongs() {
        let expectation = XCTestExpectation(description: "Fetch and parse recommended songs")

        recommendedSongJSONParsing { songs in
            XCTAssertNotEqual(songs.count, 0, "The recommended songs list should not be empty")
            if !songs.isEmpty {
                XCTAssertEqual(songs[0].songID, "2ZK2PfpK0iri6UduhsblBM")
                XCTAssertEqual(songs[0].songLength, 262000)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }


    
    func recommendedSongJSONParsing(completion: @escaping ([RecommendedSong2]) -> Void) {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "recommendationsGenre", withExtension: "json") else {
            XCTFail("Missing file: recommendationsGenre.json")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let recommendedSongs = try JSONDecoder().decode([RecommendedSong2].self, from: jsonData)
            completion(recommendedSongs)
        } catch {
            XCTFail("Decoding error: \(error)")
        }
    }

    func test_newSongsParsing() {
        XCTAssertEqual(newSongs.count, 0, "New songs list should be initially empty")
        newSongsParsing()
        XCTAssertNotEqual(newSongs.count, 0, "New songs list should not be empty after parsing")
       
    }

    func newSongsParsing() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "newSongs", withExtension: "json") else {
            XCTFail("Missing file: newSongs.json")
            return
        }

        do {
            let jsonData = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                for songData in json {
                    if let artistName = songData["artist_name"] as? [String],
                       let rate = songData["rate"] as? Int,
                       let releaseDate = songData["release_date"] as? Int,
                       let songId = songData["song_id"] as? String,
                       let songName = songData["song_name"] as? String {
                        
                        let song = newSongModel(artist_name: artistName, rate: rate, release_date: releaseDate, song_id: songId, song_name: songName)
                        newSongs.append(song)
                    }
                }
            }
        } catch {
            XCTFail("Error parsing JSON: \(error.localizedDescription)")
        }
    }
    
    // Test for Song Name Validity
    func testSongNamesAreNotEmpty() {
        let expectation = XCTestExpectation(description: "SongNamesNotEmpty")
        newSongsParsing()
        for song in newSongs {
            XCTAssertFalse(song.song_name.isEmpty, "Song names should not be empty.")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }

    // Test for Artist Array Validity
    func testArtistArraysAreNotEmpty() {
        let expectation = XCTestExpectation(description: "ArtistArraysNotEmpty")
        newSongsParsing()
        for song in newSongs {
            XCTAssertFalse(song.artist_name.isEmpty, "Artist names array should not be empty.")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }

    // Test for Rate Validity
    func testRatesAreWithinExpectedRange() {
        let expectation = XCTestExpectation(description: "RatesWithinRange")
        newSongsParsing()
        for song in newSongs {
            XCTAssertTrue((0...5).contains(song.rate), "Song rates should be within the range 0 to 5.")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }

    // Test for Release Date Validity
    func testReleaseDatesAreWithinReasonableRange() {
        let expectation = XCTestExpectation(description: "ReleaseDatesWithinRange")
        newSongsParsing()
        let currentYear = Calendar.current.component(.year, from: Date())
        for song in newSongs {
            XCTAssertTrue((currentYear-30...currentYear).contains(song.release_date), "Release dates should be within the last 30 years.")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }

    // Test for Song ID Format
    func testSongIDsMatchExpectedFormat() {
        let expectation = XCTestExpectation(description: "SongIDsFormat")
        newSongsParsing()
        let idRegex = "[0-9a-zA-Z]{22}" // Example format, adjust the regex as needed
        let idPredicate = NSPredicate(format:"SELF MATCHES %@", idRegex)
        for song in newSongs {
            XCTAssertTrue(idPredicate.evaluate(with: song.song_id), "Song IDs should match the expected format.")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }

    func testMostRatedSongsJSONFileExists() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "mostRatedSongs", withExtension: "json")
        XCTAssertNotNil(url, "The mostRatedSongs.json file should exist in the test bundle.")
    }
    
    // This function tests if the fetchMostRatedSongs function successfully parses the JSON file.
    func testFetchMostRatedSongsParsesCorrectly() {
        let expectation = self.expectation(description: "fetchMostRatedSongs")
        var songsResponse: [Song6]?
        
        fetchMostRatedSongs { songs in
            songsResponse = songs
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(songsResponse, "The fetchMostRatedSongs function should have parsed the songs.")
        XCTAssertTrue(!songsResponse!.isEmpty, "The parsed songs array should not be empty.")
    }
    
    // This function tests if the fetched songs have valid data.
    func testFetchedSongsHaveValidData() {
        let expectation = self.expectation(description: "ValidData")
        var songsResponse: [Song6]?
        
        fetchMostRatedSongs { songs in
            songsResponse = songs
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        if let songs = songsResponse {
            for song in songs {
                XCTAssertFalse(song.album_name.isEmpty, "Album name should not be empty")
                XCTAssertFalse(song.song_name.isEmpty, "Song name should not be empty")
                XCTAssertFalse(song.artists.isEmpty, "Artists array should not be empty")
                XCTAssert(song.duration > 0, "Song duration should be greater than 0")
                XCTAssert(song.rating >= 0, "Song rating should be non-negative")
            }
        } else {
            XCTFail("Songs were not fetched correctly")
        }
    }
    
    func fetchMostRatedSongs(completion: @escaping ([Song6]) -> Void) {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "mostRatedSongs", withExtension: "json") else {
            XCTFail("Missing file: mostRatedSongs.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedResponse = try JSONDecoder().decode(MostRatedSongsResponse.self, from: data)
            completion(decodedResponse.mostRatedSongs) // Now this should work as expected
        } catch {
            XCTFail("Error occurred during parsing: \(error.localizedDescription)")
        }
    }
    
    func testNoDuplicatePlaylists() {
        playlistJSONParsing()
        let uniqueIDs = Set(playlists.map { $0.playlistID })
        XCTAssertEqual(uniqueIDs.count, playlists.count, "There should be no duplicate playlists")
    }

    func testArtistPopularityRange() {
        artistJSONParsing()
        for artist in artists {
            XCTAssertTrue((0...100).contains(artist.popularity), "Artist popularity should be within 0 to 100")
        }
    }

    func testUniqueSongIDs() {
        let expectation = XCTestExpectation(description: "UniqueSongIDs")
        recommendedSongJSONParsing { songs in
            let uniqueIDs = Set(songs.map { $0.songID })
            XCTAssertEqual(uniqueIDs.count, songs.count, "All songs should have unique IDs")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testNonEmptyArtistNames() {
        let expectation = XCTestExpectation(description: "NonEmptyArtistNames")
        recommendedSongJSONParsing { songs in
            for song in songs {
                XCTAssertFalse(song.artistName.isEmpty, "Artist names should not be empty")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testValidReleaseDates() {
        let expectation = XCTestExpectation(description: "ValidReleaseDates")
        newSongsParsing()
        for song in newSongs {
            let year = song.release_date
            XCTAssertTrue(year >= 1900 && year <= Calendar.current.component(.year, from: Date()), "Release dates should be within a valid range")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSongRateValidity() {
        let expectation = XCTestExpectation(description: "SongRateValidity")
        newSongsParsing()
        for song in newSongs {
            XCTAssertTrue((0...5).contains(song.rate), "Song rates should be within the range 0 to 5")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }

    func testConsistentSongRatings() {
        let expectation1 = XCTestExpectation(description: "FirstFetch")
        let expectation2 = XCTestExpectation(description: "SecondFetch")
        var firstFetchRatings: [Int] = []
        var secondFetchRatings: [Int] = []

        fetchMostRatedSongs { songs in
            firstFetchRatings = songs.map { $0.rating }
            expectation1.fulfill()
        }
        fetchMostRatedSongs { songs in
            secondFetchRatings = songs.map { $0.rating }
            expectation2.fulfill()
        }

        wait(for: [expectation1, expectation2], timeout: 10.0)
        XCTAssertEqual(firstFetchRatings, secondFetchRatings, "Song ratings should be consistent across fetches")
    }

    func testAlbumNameIntegrity() {
        let expectation = XCTestExpectation(description: "AlbumNameIntegrity")
        fetchMostRatedSongs { songs in
            for song in songs {
                XCTAssertFalse(song.album_name.isEmpty, "Album names should not be empty")
                // Add regex or format checks if necessary
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNonEmptyPlaylistIDs() {
        playlistJSONParsing()
        for playlist in playlists {
            XCTAssertFalse(playlist.playlistID.isEmpty, "Playlist ID should not be empty")
        }
    }
    
    func testNonNegativeFollowerCounts() {
        artistJSONParsing()
        for artist in artists {
            XCTAssert(artist.followers >= 0, "Followers count should be non-negative")
        }
    }
  
    func testNonEmptyArtistNamesInRecommendations() {
        recommendedSongJSONParsing { songs in
            XCTAssertTrue(songs.allSatisfy { !$0.artistName.isEmpty }, "Artist names should not be empty")
        }
    }
    
    func testCorrectRateRange() {
        newSongsParsing()
        for song in newSongs {
            XCTAssertTrue((0...10).contains(song.rate), "Song rate should be within 0 to 10")
        }
    }
    func testConsistentReleaseDates() {
        newSongsParsing()
        let currentYear = Calendar.current.component(.year, from: Date())
        for song in newSongs {
            XCTAssert(song.release_date <= currentYear, "Release date should not be in the future")
        }
    }
    func testDiversityInArtistNames() {
        fetchMostRatedSongs { songs in
            let uniqueArtists = Set(songs.flatMap { $0.artists })
            XCTAssert(uniqueArtists.count > 1, "There should be a diversity of artist names")
        }
    }

    
    func testValidArtistIDs() {
        artistJSONParsing()
        for artist in artists {
            XCTAssertTrue(artist.artistID.matchesRegex("^[\\w\\d]+$"), "Artist ID should be valid")
        }
    }

    func testSongTimestampValidity() {
        fetchMostRatedSongs { songs in
            XCTAssertTrue(songs.allSatisfy { $0.timestamp.isValidDate(format: "E, dd MMM yyyy HH:mm:ss z") }, "Timestamps should be valid")
        }
    }
    func testNonEmptyPlaylistNames() {
        playlistJSONParsing()
        for playlist in playlists {
            XCTAssertFalse(playlist.name.trimmingCharacters(in: .whitespaces).isEmpty, "Playlist names should not be empty or whitespace")
        }
    }
    func testNonZeroSongLengths() {
        recommendedSongJSONParsing { songs in
            XCTAssertTrue(songs.allSatisfy { $0.songLength > 0 }, "Song lengths should be greater than zero")
        }
    }
    func testNoDuplicateSongIDs() {
        recommendedSongJSONParsing { songs in
            let ids = Set(songs.map { $0.songID })
            XCTAssertEqual(ids.count, songs.count, "Song IDs should be unique")
        }
    }
    func testConsistentSongRating() {
        newSongsParsing()
        for song in newSongs {
            XCTAssert((0...5).contains(song.rate), "Song rating should be within the range 0 to 5")
        }
    }
    func testValidSongNameLength() {
        newSongsParsing()
        for song in newSongs {
            XCTAssert(song.song_name.count <= 100, "Song name should not exceed 100 characters")
        }
    }
    func testCorrectTimestampFormat() {
        fetchMostRatedSongs { songs in
            XCTAssertTrue(songs.allSatisfy { $0.timestamp.isValidDate(format: "E, dd MMM yyyy HH:mm:ss z") }, "Timestamps should have correct format")
        }
    }

}

extension String {
    func matchesRegex(_ regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }

    func isValidURL() -> Bool {
        return URL(string: self) != nil
    }

    func isValidDate(format: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self) != nil
    }
}
