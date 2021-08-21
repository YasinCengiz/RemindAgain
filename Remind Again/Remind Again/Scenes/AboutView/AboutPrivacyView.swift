//
//  AboutPrivacyView.swift
//  AboutPrivacyView
//
//  Created by Yasin Cengiz on 18.08.2021.
//

import SwiftUI

struct AboutPrivacyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    Text("\n**Privacy Policy** \nThis policy applies to all information collected or submitted on Remind Again’s website and our apps for iPhone and any other devices and platforms. By using our site or apps, you consent to our privacy policy. \n")
                    
                    Text("**Information we collect** \nWe store information about your links that you have saved to sync this information between your devices. We also collect anonymous statistics about how you interact with the app if you chose to share it in device settings. We use the information we collect to operate and improve our apps and customer support. We do not share personal information with outside parties. In fact, none of the data we collect contains any personal information. \n")
                    
                    Text("**iCloud** \nRemind Again stores all of your data in Apple’s iCloud service, such as links you have saved, done status, and viewing options, to enable sync features between all devices signed into your Apple ID. \n")
                    
                    Text("**Analytics** \nRemind Again app collects aggregate, anonymous statistics, such as the percentage of users who use particular features, to improve the app. \n")
                    
                    Text("**Accessing, changing, or deleting data** \nYou may access, change, or delete your data from the Remind Again iOS app. Any update on the data will be synced to all devices signed into your Apple ID via Apple's iCloud service. \n")
                }
            }
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

struct AboutPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        AboutPrivacyView()
    }
}
