//
//  Start.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct StartViewTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                TextField("\(placeholder)", text: $text)
                
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                    }
                } else {
                    EmptyView()
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            
            Divider()
        }
        .padding(.horizontal)
    }
}

struct StartViewButton: View {
    var enabled = false
    @Binding var loading: Bool
    
    var body: some View {
        Circle()
            .stroke(enabled ? Color("moare") : .secondary)
            .frame(width: 75, height: 75)
            .overlay {
                if loading {
                    ProgressView()
                        .tint(Color("moare"))
                }
            }
    }
}

struct PwdTextField: View {
    var placeholder: String
    @Binding var text: String
    @State var showPwd = false
    
    var body: some View {
        VStack {
            HStack {
                if showPwd {
                    TextField("\(placeholder)", text: $text)
                } else {
                    SecureField("\(placeholder)", text: $text)
                }
                
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                    }
                } else {
                    EmptyView()
                }
                
                Button(action: {
                    self.showPwd.toggle()
                }) {
                    Image(systemName: "eye")
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 40)
            .padding(.leading)
            
            Divider()
        }
        .padding(.horizontal)
    }
}

struct UsernameTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var loading: Bool
    
    var body: some View {
        VStack {
            HStack {
                TextField("\(placeholder)", text: $text)
                
                if loading {
                    ProgressView()
                        .padding(.trailing, 4)
                }
                
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                    }
                } else {
                    EmptyView()
                }
            }
            .frame(height: 40)
            .padding(.leading)
            
            
            Divider()
        }
        .padding(.horizontal)
    }
}
