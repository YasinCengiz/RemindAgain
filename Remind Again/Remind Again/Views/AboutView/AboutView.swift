//
//  AboutView.swift
//  AboutView
//
//  Created by Yasin Cengiz on 15.08.2021.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var showingPolicyScreen = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "gift")
                            .font(.system(size: 25))
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .background(Color.cyan)
                            .cornerRadius(6)
                        Text("You can support further development by donating.")
                            .font(.footnote)
                    }
                    HStack(spacing: 10) {
                            Button {
                                // 1 dollar
                            } label: {
                                Text("1$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            Button {
                                // 3 dollar
                            } label: {
                                Text("3$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            Button {
                                // 5 dollar
                            } label: {
                                Text("5$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            Button {
                                // 7 dollar
                            } label: {
                                Text("7$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            Button {
                                // 10 dollar
                            } label: {
                                Text("10$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            Button {
                                // 10 dollar
                            } label: {
                                Text("15$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            Button {
                                // 10 dollar
                            } label: {
                                Text("20$")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                        }
                        .padding([.top, .bottom], 8)
                    .listRowSeparator(.hidden)
                }
                Section{
                    //                    Button {
                    //
                    //                    } label: {
                    //                        HStack {
                    //                            Image(systemName: "text.bubble.fill")
                    //                                .frame(width: 29, height: 29)
                    //                                .foregroundColor(.white)
                    //                                .background(Color.indigo)
                    //                                .cornerRadius(6)
                    //                            Text("Feedback")
                    //                        }
                    //                    }
                    Button {
                        //
                    } label: {
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
