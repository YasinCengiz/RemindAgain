//
//  SortDetailView.swift
//  SortDetailView
//
//  Created by Yasin Cengiz on 17.08.2021.
//

import SwiftUI

enum SortOption {
    case aToZ
    case zToA
    case firstCreated
    case lastCreated
}

struct SortDetailView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var sortOption: SortOption
    @State private var inverse = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        sortOption = inverse ? .zToA : .aToZ
                    } label: {
                        HStack {
                            if sortOption == .aToZ || sortOption == .zToA {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "checkmark.circle")
                            }
                            Text("Alphabeticaly")
                        }
                    }
                    .buttonStyle(.plain)
                    Button {
                        sortOption = inverse ? .lastCreated : .firstCreated
                    } label: {
                        HStack {
                            if sortOption == .firstCreated || sortOption == .lastCreated {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "checkmark.circle")
                            }
                            Text("Created Date")
                        }
                    }
                    .buttonStyle(.plain)
                }
                Section {
                    Toggle("Inverse", isOn: $inverse)
                        .onChange(of: inverse) { inverse in
                            switch sortOption {
                            case .aToZ:
                                if inverse {
                                    sortOption = .zToA
                                }
                            case .zToA:
                                if inverse == false {
                                    sortOption = .aToZ
                                }
                            case .firstCreated:
                                if inverse {
                                    sortOption = .lastCreated
                                }
                            case .lastCreated:
                                if inverse == false {
                                    sortOption = .firstCreated
                                }
                            }
                        }
                }
            }
            .navigationBarTitle("Sort")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                            .bold()
                    }
                }
            }
        }
    }
}

struct SortDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SortDetailView(sortOption: Binding<SortOption>(get: { .lastCreated }, set: { _ in }))
    }
}
