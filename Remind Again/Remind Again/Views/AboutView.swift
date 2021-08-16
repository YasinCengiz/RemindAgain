//
//  AboutView.swift
//  AboutView
//
//  Created by Yasin Cengiz on 15.08.2021.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "gift.circle")
                            .font(.system(size: 35))
                            .foregroundColor(.green)
                        Text("You can support further development by donating.")
                            .font(.system(size: 14))
                    }
                    VStack {
                        HStack {
                            Button {
                                // 1 dollar
                            } label: {
                                Text("1$")
                            }
                            
                            Spacer()
                            Button {
                                // 3 dollar
                            } label: {
                                Text("3$")
                            }
                            Spacer()
                            Button {
                                // 5 dollar
                            } label: {
                                Text("5$")
                            }
                            Spacer()
                            Button {
                                // 7 dollar
                            } label: {
                                Text("7$")
                            }
                            Spacer()
                            Button {
                                // 10 dollar
                            } label: {
                                Text("10$")
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                Section{
                    VStack {
                        Button {
                            //Feedback
                        } label: {
                            HStack {
                                Image(systemName: "text.bubble")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                Text("Feedback")
                            }
                        }
                        Button {
                            //
                        } label: {
                            HStack {
                                Image(systemName: "hand.raised.square")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                Text("Feedback")
                            }
                        }
                    }
                    
                }
            }
            .navigationTitle("About")
        }
    }
}


struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
