import SwiftUI
import MessageUI
import Foundation

struct SendEmailController: View {
    
    var zipFileURL: URL?  // This will hold the file URL passed from the export function

    class MailComposeViewController: UIViewController, MFMailComposeViewControllerDelegate {
        
        static let shared = MailComposeViewController()
        
        var zipFileURL: URL?

        func sendEmail() {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("Scans from \(NSDate())")
                mail.setToRecipients(["rhlwoundcare@gmail.com"])

                // Check if the file URL exists and attach it
                if let zipFileURL = zipFileURL, let fileData = try? Data(contentsOf: zipFileURL) {
                    mail.addAttachmentData(fileData, mimeType: "application/zip", fileName: "Mesh-\(NSDate()).zip")
                }

                UIApplication.shared.windows.last?.rootViewController?.present(mail, animated: true, completion: nil)
            } else {
                // Alert if mail cannot be sent
                print("Cannot send email")
            }
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }

    var body: some View {
        Text("Confirm data to send below")
            
        Button(action: {
            loadEmail()
        }, label: {
            Text("Send Email")
        })
    }
    
    func loadEmail() {
        MailComposeViewController.shared.zipFileURL = zipFileURL
        MailComposeViewController.shared.sendEmail()
    }
}

struct SendEmailController_Previews: PreviewProvider {
    static var previews: some View {
        SendEmailController(zipFileURL: URL(string: "https://example.com")!)
    }
}
