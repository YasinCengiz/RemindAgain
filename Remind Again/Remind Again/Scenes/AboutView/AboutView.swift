//
//  AboutView.swift
//  AboutView
//
//  Created by Yasin Cengiz on 15.08.2021.
//

import SwiftUI
import MessageUI
import StoreKit

struct MailView: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var isShowing: Bool
        
        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            isShowing = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["remindagain@icloud.com"])
        vc.setSubject("Feedback for Remind Again")
        vc.setMessageBody("""
        Please do not delete the lines below.
        Remind Again \(BuildEnvironment.current.version) (\(BuildEnvironment.current.build))
        \(BuildEnvironment.current.systemVersion)
        """, isHTML: false)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        
    }
}

struct AboutView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var showingPolicyScreen = false
    @State var isShowingMailView = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 25))
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .background(Color.init(uiColor: .systemTeal))
                            .cornerRadius(6)
                        Text("You can support further development by donating.")
                            .font(.footnote)
                    }
                    .listRowSeparator(.hidden)
                    .padding([.top, .bottom], 10)
                    Button {
                        // 1 dollar
                    } label: {
                        HStack {
                            Text("1$")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(6)
                            Text("Parking Fee")
                            Spacer()
                        }
                    }
                    Button {
                        // 3 dollar
                    } label: {
                        HStack {
                            Text("3$")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(6)
                            Text("Coffee's on me")
                            Spacer()
                        }
                    }
                    Button {
                        // 5 dollar
                    } label: {
                        HStack {
                            Text("5$")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(6)
                            Text("Have a Lunch")
                            Spacer()
                        }
                    }
                }
                .foregroundColor(Color(uiColor: .label))
                Section{
                    HStack {
                        Image(systemName: "envelope.fill")
                            .frame(width: 29, height: 29)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(6)
                        VStack(alignment: .leading) {
                            Button {
                                self.isShowingMailView.toggle()
                            } label: {
                                Text("Contact")
                            }
                            if MFMailComposeViewController.canSendMail() == false {
                                Text("You cannot send email before setting up an account in Mail app.")
                                    .font(.footnote)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .foregroundColor(Color(uiColor: .label))
                        .disabled(MFMailComposeViewController.canSendMail() == false)
                        .sheet(isPresented: $isShowingMailView) {
                            MailView(isShowing: self.$isShowingMailView)
                        }
                    }
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .frame(width: 29, height: 29)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(6)
                        Button {
                            showingPolicyScreen.toggle()
                        } label: {
                            Text("Privacy Policy")
                        }
                        .foregroundColor(Color(uiColor: .label))
                        .sheet(isPresented: $showingPolicyScreen) {
                            AboutPrivacyView()
                        }
                    }
                    HStack {
                        Image(systemName: "star.fill")
                            .frame(width: 29, height: 29)
                            .foregroundColor(.white)
                            .background(Color.init(uiColor: .systemYellow))
                            .cornerRadius(6)
                        Button {
                            // Rate the app
                            if let scene = UIApplication.shared.connectedScenes
                                    .first(where: { $0.activationState == .foregroundActive })
                                    as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        } label: {
                            Text("Rate the App")
                                .foregroundColor(Color(uiColor: .label))
                        }
                    }
                }
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
