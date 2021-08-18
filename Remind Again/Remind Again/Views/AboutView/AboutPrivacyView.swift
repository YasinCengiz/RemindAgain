//
//  AboutPrivacyView.swift
//  AboutPrivacyView
//
//  Created by Yasin Cengiz on 18.08.2021.
//

import SwiftUI

let policyTitle = "Privacy Policy"
let policyInfo = """
This policy applies to all information collected or submitted on Remind Again’s website and our apps for iPhone and any other devices and platforms. By using our site or apps, you consent to our privacy policy.
"""
let collectedInfoTitle = "Information we collect"
let collectedInfo = """
We store information about your links that you have saved to sync this information between your devices. We also collect anonymous statistics about how you interact with the app if you chose to share it in device settings. We use the information we collect to operate and improve our apps and customer support. We do not share personal information with outside parties. In fact, none of the data we collect contains any personal information.
"""
let iCloudTitle = "iCloud"
let iCloudInfo = """
Remind Again stores all of your data in Apple’s iCloud service, such as links you have saved, done status, and viewing options, to enable sync features between all devices signed into your Apple ID.
"""
let analyticsTitle = "Analytics"
let analyticsInfo = """
Remind Again app collects aggregate, anonymous statistics, such as the percentage of users who use particular features, to improve the app.
"""
let acdDataTitle = "Accessing, changing, or deleting data"
let acdDataInfo = """
You may access, change, or delete your data from the Remind Again iOS app. Any update on the data will be synced to all devices signed into your Apple ID via Apple's iCloud service.
"""
//let contactTitle = "Contacting Us"
//let contactInfo = """
//If you have questions regarding this privacy policy, you may email remindagainapp@icloud.com.
//"""

struct AboutPrivacyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    Text(policyTitle)
                        .bold()
                    Text(policyInfo)
                        .padding()
                    Text(collectedInfoTitle)
                        .bold()
                        .padding()
                    Text(collectedInfo)
                        .padding()
                    Text(iCloudTitle)
                        .bold()
                        .padding()
                    Text(iCloudInfo)
                        .padding()
                    Text(analyticsTitle)
                        .bold()
                        .padding()
                    Text(analyticsInfo)
                        .padding()
                    Text(acdDataTitle)
                        .bold()
                        .padding()
                    Text(acdDataInfo)
                        .padding()
                }
                .foregroundColor(Color(uiColor: .label))
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
