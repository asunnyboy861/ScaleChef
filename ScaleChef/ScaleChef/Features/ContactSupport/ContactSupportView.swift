import SwiftUI
import MessageUI

struct ContactSupportView: View {
    @State private var showMailComposer = false
    @State private var showMailAlert = false

    var body: some View {
        VStack(spacing: SCSpace.xl) {
            Image(systemName: "envelope")
                .font(.system(size: 48))
                .foregroundStyle(Color.scPrimary)

            Text("We'd love to hear from you!")
                .font(SCFont.title2)
                .foregroundStyle(Color.scTextPrimary)

            Text("Questions, feedback, or recipe suggestions — drop us a line.")
                .font(SCFont.body)
                .foregroundStyle(Color.scTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                if MFMailComposeViewController.canSendMail() {
                    showMailComposer = true
                } else {
                    showMailAlert = true
                }
            }) {
                Text("Email Us")
                    .font(SCFont.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(SCSpace.md)
                    .background(Color.scPrimary)
                    .cornerRadius(12)
            }

            Button(action: {
                if let url = URL(string: "mailto:iocompile67692@gmail.com") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Mail App")
                    .font(SCFont.headline)
                    .foregroundStyle(Color.scSecondary)
            }

            Spacer()
        }
        .padding(SCSpace.lg)
        .background(Color.scBackground)
        .navigationTitle("Contact Support")
        .sheet(isPresented: $showMailComposer) {
            MailComposerView()
        }
        .alert("Mail Not Available", isPresented: $showMailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please set up Mail on your device or email us at iocompile67692@gmail.com")
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients(["iocompile67692@gmail.com"])
        composer.setSubject("ScaleChef Support")
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
