
import SwiftUI

struct FeedbackView: View {
    @State private var feedbackText: String = ""
    
    var body: some View {
        VStack {
            Text("Feedback")
                .font(.largeTitle)
                .padding()
            
            TextEditor(text: $feedbackText)
                .padding()
                .border(Color.gray, width: 1)
            
            Button(action: {
                // Handle feedback submission
                print("Feedback submitted: \(feedbackText)")
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
