//
//  SportSelectView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct SportSelectView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var sportSelectVM: SportSelectViewModel
    var addSport: (_ selectedSport: [String], _ userHashtag: [String]) -> () = {_,_  in }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    SearchBar(text: $sportSelectVM.query, placeholder: StringResources.search, isFocused: false)
                        .onChange(of: sportSelectVM.query) { query in
                            sportSelectVM.searchSport(query: query)
                        }
                    
                    Button(action: {
                        addSport(sportSelectVM.selectedSport, sportSelectVM.userHashtag)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(StringResources.complete)
                            .font(.body)
                    }
                    .padding(.trailing)
                }
                
                if sportSelectVM.loading {
                    ProgressView()
                }
                
                if !sportSelectVM.selectedSport.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 4) {
                            ForEach(sportSelectVM.selectedSport.indices, id: \.self) { i in
                                Text("\(sportSelectVM.selectedSport[i])")
                                    .font(.body)
                                    .padding(.leading, 10)
                                    .foregroundColor(Color("moare"))
                                
                                Button(action: {
                                    sportSelectVM.deleteSelectedSport(index: i)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.top, -8)
                }
                
                ScrollView {
                    if sportSelectVM.networkError {
                        Text(StringResources.failedToGetSportList)
                            .font(.body)
                    } else {
                        SportHashtagListView(
                            sportSelectVM: sportSelectVM,
                            action1: { key in
                                sportSelectVM.selectSport(key: key)
                            }
                        ) { key in
                            sportSelectVM.newSelectSport(key: key)
                        }
                    }
                }
            }
            .navigationTitle(StringResources.sportSelectNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(StringResources.cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } // navigationview
        .accentColor(Color("moare"))
    }
}
