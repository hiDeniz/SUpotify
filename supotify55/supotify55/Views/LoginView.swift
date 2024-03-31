//
//  ContentView.swift
//  SUpotify_Mobile
//
//  Created by Halil İbrahim Deniz on 31.10.2023.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                let startColor = Color(red: 13/255, green: 35/255, blue: 22/255)
                let endColor = Color(red: 30/255, green: 16/255, blue: 37/255)

                LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)

                Rectangle()
                    .fill(Color(hex: "#363636").opacity(0.9))
                    .frame(width: 370, height: 750)
                    .cornerRadius(15)

                VStack(spacing: 20) {
                    Text("Login")
                        .font(Font.custom("Avantgarde Gothic", size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                        .padding(.top, 100)
                        .padding(.bottom, 70)
                    
                    
                    Text("Please enter your email and password!")
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .font(.headline)
                        .foregroundColor(.gray)

                    TextField("Email", text: $email)
                        .padding()
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .padding(.horizontal)
                        .autocapitalization(.none) // prevent auto-capitalization

                    SecureField("Password", text: $password)
                        .padding()
                        .font(Font.custom("Avantgarde Gothic", size: 18))
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .padding(.horizontal)

                    Divider()
                        .background(Color.white)
                        .padding(.horizontal)
                        .padding(.vertical, 15)

                    Button(action: {
                        apicaller.loginPostRequest(email: email, password: password) { success in
                            if success {
                                print("Login successful")
                                myUser.email = email
                                myUser.password = password
                                apicaller.getUserdata(email: email) { result in
                                    switch result {
                                    case .success(let userData):
                                        print("User data is received: \(userData)")
                                        if let username = userData["username"] as? String
                                        {
                                            myUser.username = username
                                            print("username is received")

                                        }
                                        else
                                        {
                                            print("error in username")
                                        }
                                        if let profilePicture = userData["profilePicture"] as? String
                                        {
                                            myUser.profilePicture = profilePicture
                                            print("profilePicture is received")

                                        }
                                        else
                                        {
                                            myUser.profilePicture = "" // Eğer profilePicture boşsa, boş string olarak ata
                                            print("error in profilePicture")
                                        }
                                        if let lastListenedSong = userData["lastListenedSong"] as? String
                                        {
                                            myUser.lastListenedSong = lastListenedSong
                                            print("lastListenedSong is received")

                                        }
                                        else
                                        {
                                            myUser.lastListenedSong = "" // Eğer profilePicture boşsa, boş string olarak ata
                                            print("error in lastListenedSong")
                                        }
                                        if let friends = userData["friends"] as? [String]
                                        {
                                            myUser.friends = friends
                                            print("friends is received")

                                        }
                                        else
                                        {
                                            print("error in friends")
                                        }
                                        if let friendsCount = userData["friendsCount"] as? Int
                                        {
                                            myUser.friendsCount = friendsCount
                                            print("friendsCount is received")

                                        }
                                        else
                                        {
                                            print("error in friendsCount")
                                        }
                                    case .failure(let error):
                                        print("Error fetching user data: \(error.localizedDescription)")
                                    }
                                }
                                isLoggedIn.toggle()
                            } else {
                                
                                print("Login failed")
                            }
                        }
                    }) {
                        Text("Login")
                            .padding()
                            .font(Font.custom("Avantgarde Gothic", size: 18))
                            .frame(width: 330)
                            .foregroundColor(Color(hex: "#363636"))
                            .background(Color(hex: "#c1cdc1"))
                            .cornerRadius(8)
                    }
                    
                    Spacer()

                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                            .font(Font.custom("Avantgarde Gothic", size: 18))
                        Button(action: {
                            navigator.LoginToSignup()
                        }) {
                            Text("Sign Up")
                                .foregroundColor(.green)
                                .font(Font.custom("Avantgarde Gothic", size: 18))
                        }

                    }
                }
                .padding()
                NavigationLink(destination: MainPageView(), isActive: $isLoggedIn) {
                    EmptyView() // EmptyView is used as a placeholder for the navigation link
                }
                .hidden() // Hide the NavigationLink visually
            }
        }
    }
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            LoginView()
//        }
//    }
//}


