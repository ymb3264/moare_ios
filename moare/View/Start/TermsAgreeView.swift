//
//  TermsAgreeView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct TermsAgreeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var joinVM: JoinViewModel
    
    @State var defaultLoading = false
    
    @State var tosAgreed = false
    @State var privacyPolicyAgreed = false
    
    @State var tosDetailPresented = false
    @State var privacyPolicyDetailPresented = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.termsAgreeTitle)
                .font(.title2)
            
            Text(StringResources.termsAgreeMessage)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            VStack {
                HStack {
                    Text(StringResources.allTermsAgreeButton)
                        .font(.subheadline)
                        .padding(.bottom, 2)
                    
                    Spacer()
                    
                    Button {
                        joinVM.account.allTermsAgreed.toggle()
                        tosAgreed = joinVM.account.allTermsAgreed
                        privacyPolicyAgreed = joinVM.account.allTermsAgreed
                    } label: {
                        Circle()
                            .stroke(joinVM.account.allTermsAgreed ? Color("moare") : .secondary)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if joinVM.account.allTermsAgreed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color("moare"))
                                }
                            }
                            .padding(.leading, 20)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(StringResources.tosAgreeButton)
                            .font(.subheadline)
                            .padding(.bottom, 2)
                        
                        Button {
                            tosDetailPresented = true
                        } label: {
                            Text(StringResources.termsDetailButton)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        tosAgreed.toggle()
                        joinVM.account.allTermsAgreed = tosAgreed && privacyPolicyAgreed
                    } label: {
                        Circle()
                            .stroke(tosAgreed ? Color("moare") : .secondary)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if tosAgreed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color("moare"))
                                }
                            }
                            .padding(.leading, 20)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(StringResources.privacyPolicyAgreeButton)
                            .font(.subheadline)
                            .padding(.bottom, 2)
                        
                        Button {
                            privacyPolicyDetailPresented = true
                        } label: {
                            Text(StringResources.termsDetailButton)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        privacyPolicyAgreed.toggle()
                        joinVM.account.allTermsAgreed = tosAgreed && privacyPolicyAgreed
                    } label: {
                        Circle()
                            .stroke(privacyPolicyAgreed ? Color("moare") : .secondary)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if privacyPolicyAgreed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color("moare"))
                                }
                            }
                            .padding(.leading, 20)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: 260)
            
            NavigationLink(
                destination: { LoginInfoSaveView() }
            ) {
                StartViewButton(enabled: joinVM.account.allTermsAgreed, loading: $defaultLoading)
            }
            .disabled(!joinVM.account.allTermsAgreed)

            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .ignoresSafeArea()
        .fullScreenCover(
            isPresented: $tosDetailPresented,
            onDismiss: {},
            content: {
                TosDetailView()
            }
        )
        .fullScreenCover(
            isPresented: $privacyPolicyDetailPresented,
            onDismiss: {},
            content: {
                PrivacyPolicyDetailView()
            }
        )
    }
}
