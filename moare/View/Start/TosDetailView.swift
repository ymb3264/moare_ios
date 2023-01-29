//
//  TosDetailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/11.
//

import SwiftUI

struct TosDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var locationTosDetailPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                WebView(url: URL(string: StringResources.tosUrl)!)
                
                Button {
                    locationTosDetailPresented = true
                } label: {
                    Text(StringResources.locationTos)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .underline()
                        .padding(.top, 4)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(StringResources.tos)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("moare"))
                    }
                }
            }
            .fullScreenCover(
                isPresented: $locationTosDetailPresented,
                onDismiss: {},
                content: {
                    LocationTosDetailView()
                }
            )
            
        }
    }
}

struct LocationTosDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: StringResources.locationTosUrl)!)
                .navigationTitle(StringResources.locationTos)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color("moare"))
                        }
                    }
                }
        }
    }
}
