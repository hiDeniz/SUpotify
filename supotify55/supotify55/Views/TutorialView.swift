import SwiftUI

struct TutorialView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Sign Up Tutorial
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    VStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Enter Username, Email, and Password")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding()

                    VStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Verify Your Password")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding()

                    VStack {
                        Image(systemName: "arrow.right.square.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("You'll Be Redirected to Spotify Login")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding()

                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Registration Complete")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding(.bottom)

                    // Log In Tutorial
                    Text("Log In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    VStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Enter Your Email")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding()

                    VStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Enter Your Password")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding()

                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("If Correct, You Are Logged In")
                            .foregroundColor(.white)
                            .font(.headline)
                    }.padding(.bottom)
                }
            }
        }
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
