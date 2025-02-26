import SwiftUI

struct MenuButtonView: View {
    @Binding var isMenuOpen: Bool

    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(1.0))
                    .cornerRadius(5)
            }
            .padding(.leading)
            Spacer()
        }
    }
}
