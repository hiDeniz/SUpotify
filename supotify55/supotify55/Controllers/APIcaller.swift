//
//  APIcaller.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 16.11.2023.
//

import Foundation
import SwiftUI
import UIKit

let apicaller = APICaller.apicaller

struct APICaller {
    static let apicaller : APICaller = APICaller()
    
    
    func loginPostRequest(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let jsonObject: [String: Any] = [
            "email": email,
            "password": password
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            let url = URL(string: "http://127.0.0.1:8008/login")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    // Handle the case where there's an error with the request
                    print("Error: \(error)")
                    completion(false) // Report login failure
                    return
                }
                
                // Check if there's a response
                guard let httpResponse = response as? HTTPURLResponse else {
                    // Handle the case where there's no valid HTTP response
                    print("Invalid or no HTTP response")
                    completion(false) // Report login failure
                    return
                }
                
                // Print the status code
                print(" xyz Status code: \(httpResponse.statusCode)")
                
                if let data = data {
                    // Process the response data
                    do {
                        let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        if let jsonDictionary = responseJSON as? [String: Any],
                           let message = jsonDictionary["message"] as? Bool {
                            switch message {
                            case true:
                                // Successful login
                                print("Successful login")
                                completion(true)
                            case false:
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Unsuccessful Login", message: "Please check your email and password", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                                }
                                print("Wrong password")
                                completion(false)
                            }
                        }
                    } catch {
                        // Handle JSON parsing error
                        print("Error parsing JSON: \(error)")
                        completion(false) // Report login failure due to JSON parsing error
                    }
                }
            }
            // Resume the task to execute the request
            task.resume()
        } catch {
            print("Error: \(error)")
            completion(false) // Report login failure due to error
        }
    }
    
    func signupPostRequest(username: String, password: String, email: String, completion: @escaping (Bool) -> Void) {
        let jsonObject: [String: Any] = [
            "user_id": username,
            "password": password,
            "email": email
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            let url = URL(string: "http://127.0.0.1:8008/sign_up")! // URL for SignUp
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(false) // Report signup failure
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid or no HTTP response")
                    completion(false) // Report signup failure
                    return
                }
                
                print("Status code: \(httpResponse.statusCode)")
                
                // Assuming success is indicated by a specific HTTP status code, like 200 for example
                let successCodes = 200..<300
                if successCodes.contains(httpResponse.statusCode) {
                    completion(true) // Report signup success
                } else {
                    completion(false) // Report signup failure
                }
            }
            task.resume()
        } catch {
            print("Error: \(error)")
            completion(false) // Report signup failure
        }
    }

    func getPlaylistInfo(playlistID: String, completion: @escaping ([String: Any]?) -> Void) {
        let urlString = "http://127.0.0.1:8008/get_playlist_info/\(myUser.username)/\(playlistID)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid or no HTTP response")
                completion(nil)
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            // Check if the response status is successful (status codes in 200-299 range)
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Unsuccessful response: \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let playlistInfo = responseJSON as? [String: Any] {
                        // Successfully parsed JSON
                        completion(playlistInfo)
                    } else {
                        print("JSON does not match expected format")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    // Print or log the response data to investigate further if needed
                    if let responseDataString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseDataString)")
                    }
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    func getUserdata(email: String, completion: @escaping (Result<NSDictionary, Error>) -> Void) {
        let baseUrl = "http://127.0.0.1:8008/user_data/"
        let url = URL(string: baseUrl + email)!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "", code: -2, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    func getAlbumInfo(albumID: String, completion: @escaping ([String: Any]?) -> Void) {
        let urlString = "http://127.0.0.1:8008/get_playlist_info/\(albumID)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid or no HTTP response")
                completion(nil)
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Unsuccessful response: \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let albumInfo = responseJSON as? [String: Any] {
                        completion(albumInfo)
                    } else {
                        print("JSON does not match expected format")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    if let responseDataString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseDataString)")
                    }
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    func saveSongToBackend(songData: [String: Any], showMessage: Binding<Bool>, successMessage: Binding<Bool>) {
        // Define the URL of your backend endpoint
        guard let url = URL(string: "http://127.0.0.1:8008/save_song_with_form") else {
            print("Invalid URL")
            showMessage.wrappedValue = true // Notify failure due to invalid URL
            successMessage.wrappedValue = false
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the Content-Type header to application/json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set the JSON data to be sent
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: songData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON data: \(error)")
            showMessage.wrappedValue = true // Notify failure due to JSON data creation error
            successMessage.wrappedValue = false
            return
        }

        // Create a URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error)")
                showMessage.wrappedValue = true // Notify failure due to URLSession error
                successMessage.wrappedValue = false
                return
            }
            
            // Check if the response contains data
            if let data = data {
                // Handle the response data if needed
                print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                
                // Assuming the response contains a boolean value
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = responseJSON["message"] as? Bool {
                    // Notify success or failure based on the boolean value received
                    showMessage.wrappedValue = true
                    successMessage.wrappedValue = success
                } else {
                    showMessage.wrappedValue = true // Notify failure if unable to parse response
                    successMessage.wrappedValue = false
                }
            }
        }
        task.resume()
    }
    func postSongRating(for songID: String, with rating: Int) {
        guard let url = URL(string: "http://127.0.0.1:8008/change_rating_song") else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "song_id": songID,
            "user_id": myUser.username,
            "rating": rating
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                // Parse response if needed
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("post song rating response:")
                    print(json)
                    // Handle response JSON here
                }
            }
        }
        
        task.resume()
    }
    func fetchSongDetails(with songID: String) {
        // Ensure the songID is properly encoded for URL usage
        guard let encodedSongID = songID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            print("Invalid songID for URL")
            return
        }
        
        // Construct the URL using URLComponents
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "127.0.0.1"
        urlComponents.port = 8008
        urlComponents.path = "/save_song/\(encodedSongID)"
        
        guard let url = urlComponents.url else {
            print("Invalid URL components")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                // Parse response if needed
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json)
                }
            }
        }
        
        task.resume()
    }
    func exportJson() {
        guard let url = URL(string: "http://127.0.0.1:8008/\(myUser.username)/all_rated_songs") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            guard let jsonData = data else {
                print("No data received")
                return
            }

            do {
                // Get the documents directory
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("Documents directory not found")
                    return
                }

                // Create a file URL with a specified file name in the documents directory
                let fileURL = documentsDirectory.appendingPathComponent("exportedData.json")

                // Write JSON data to the file path
                try jsonData.write(to: fileURL)
                print("JSON file saved at: \(fileURL.path)")

                // Implement functionality to share the file
                DispatchQueue.main.async {
                    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    
                    // This is necessary for iPad: to set the source of the activity view controller
                    if let popoverController = activityViewController.popoverPresentationController {
                        popoverController.sourceView = UIApplication.shared.windows.first
                        popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }

                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                }
            } catch {
                print("Error saving JSON file: \(error)")
            }
        }
        task.resume()
    }

    func getUserPlaylists(completion: @escaping ([Playlist]) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8008/get_user_playlists") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    var playlists = [Playlist]()

                    if let jsonArray = json {
                        for playlistData in jsonArray {
                            let playlist = Playlist()
                            playlist.name = playlistData["name"] as? String ?? "default"
                            playlist.playlistID = playlistData["playlistID"] as? String ?? "default"
                            if let picString = playlistData["playlistPic"] as? String, let picURL = URL(string: picString) {
                                playlist.playlistPic = picURL
                            }
                            playlist.songNumber = playlistData["songNumber"] as? Int ?? -1
                            playlists.append(playlist)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(playlists)
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private let session = URLSession.shared

    func searchUsers(searchTerm: String, completion: @escaping (Result<[User], Error>) -> Void) {
            request(endpoint: "search_user/\(searchTerm)", completion: completion)
        }

        func searchItems(userId: String, searchTerm: String, completion: @escaping (Result<SearchResult, Error>) -> Void) {
            request(endpoint: "search_item/\(myUser.username)/\(searchTerm)", completion: completion)
        }

    private func request<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let encodedEndpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://127.0.0.1:8008/\(encodedEndpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // First, handle network errors
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Then, check for the HTTP status code
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }

                // Ensure the MIME type is correct
                if let mimeType = response?.mimeType, mimeType != "application/json" {
                    completion(.failure(NSError(domain: "Invalid MIME Type", code: -1, userInfo: nil)))
                    return
                }

                // Now we can safely unwrap the data
                guard let data = data else {
                    completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                    return
                }

                // Attempt to decode the data into the expected type
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    // For debugging purposes, print the error and the raw data string
                    print("Decoding error: \(error)")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Received data: \(dataString)")
                    }
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func getRecommendations(for genre: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = "http://127.0.0.1:8008/recommendations/\(genre.lowercased())"
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    let statusCode = httpResponse.statusCode
                    completion(.failure(NSError(domain: "HTTP Error", code: statusCode, userInfo: nil)))
                    return
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            task.resume()
        } else {
            let urlError = NSError(domain: "URL Error", code: 0, userInfo: nil)
            completion(.failure(urlError))
        }
    }
}
