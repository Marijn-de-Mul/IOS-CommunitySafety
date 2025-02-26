import SwiftUI

struct SideMenuView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isMenuOpen: Bool

    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                        Text("Login/Register")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    Divider()
                        .background(Color.white)
                    Button(action: {
                        // Action for Feedback
                    }) {
                        Text("Feedback")
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .disabled(true)
                    Divider()
                        .background(Color.white)
                    Button(action: {
                        // Action for Settings
                    }) {
                        Text("Settings")
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .disabled(true)
                    Divider()
                        .background(Color.white)
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.6)
                .background(Color.black)
                .offset(x: isMenuOpen ? 0 : -geometry.size.width * 0.6)
                .shadow(radius: 5)
                Spacer()
            }
            .background(Color.black.opacity(0.3).onTapGesture {
                withAnimation {
                    isMenuOpen.toggle()
                }
            })
        }
        .edgesIgnoringSafeArea(.all)
    }
}
