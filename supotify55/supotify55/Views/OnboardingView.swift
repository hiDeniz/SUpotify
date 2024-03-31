//
//  OnboardingView.swift
//  supotify55
//
//  Created by Ayça Ataer on 22.01.2024.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        TabView {
            OnboardingPageView(
                headline: "Do you want to listen to music everywhere?",
                imageName: "music.note", // Replace with your actual image name or system image
                description: "Never miss a beat! Take your music with you wherever you go."
            )
            
            OnboardingPageView(
                headline: "Do you want instant access to where the concerts are?",
                imageName: "map", // Replace with your actual image name or system image
                description: "Find live concerts and events around you in a snap!"
            )
            
            OnboardingPageView(
                headline: "Would you like to receive song suggestions in addition to these?",
                imageName: "music.quarternote.3", // Replace with your actual image name or system image
                description: "Get personalized song recommendations based on your taste."
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct OnboardingPageView: View {
    let headline: String
    let imageName: String
    let description: String

    var body: some View {
        VStack(spacing: 20) {
            Text(headline)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image(systemName: imageName) // Replace with Image("your_image_name") for custom images
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            Text(description)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                print("Log in tapped")
                navigator.SignupToLogin()
            }) {
                Text("Log in now!!")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}


#Preview {
    OnboardingView()
}
