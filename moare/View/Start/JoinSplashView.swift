//
//  JoinSplashView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct JoinSplashView: View {
    @EnvironmentObject var joinVM: JoinViewModel
    
    @State var animating = false
    @State var logoVisible = false
    @State var circleVisible = true
    
    var body: some View {
        ZStack {
            if logoVisible {
                Image("moare_logo")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .offset(x: 0, y: -5)
                    .zIndex(1)
            }
            
            
            if circleVisible {
                Circle()
                    .stroke(Color("moare"), lineWidth: 8)
                    .frame(width: 84, height: 84)
                    .offset(x: 0, y: animating ? -60 : 0)
                    .animation(.easeOut(duration: 2), value: animating)
                    .zIndex(2)
                
                Circle()
                    .stroke(Color("moare"), lineWidth: 8)
                    .frame(width: 84, height: 84)
                    .offset(x: animating ? 58 : 0, y: animating ? -18 : 0)
                    .animation(.easeOut(duration: 2), value: animating)
                    .zIndex(2)
                
                Circle()
                    .stroke(Color("moare"), lineWidth: 8)
                    .frame(width: 84, height: 84)
                    .offset(x: animating ? -58 : 0, y: animating ? -18 : 0)
                    .animation(.easeOut(duration: 2), value: animating)
                    .zIndex(2)
                
                Circle()
                    .stroke(Color("moare"), lineWidth: 8)
                    .frame(width: 84, height: 84)
                    .offset(x: animating ? 36 : 0, y: animating ? 50 : 0)
                    .animation(.easeOut(duration: 2), value: animating)
                    .zIndex(2)
                
                Circle()
                    .stroke(Color("moare"), lineWidth: 8)
                    .frame(width: 84, height: 84)
                    .offset(x: animating ? -36 : 0, y: animating ? 50 : 0)
                    .animation(.easeOut(duration: 2), value: animating)
                    .zIndex(2)
            }
        }
        .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        .ignoresSafeArea()
        .onAppear() {
            delay(seconds: 1) {
                animating = true
            }
            delay(seconds: 3) {
                logoVisible = true
            }
            delay(seconds: 3) {
                withAnimation(.easeInOut(duration: 2)) {
                    circleVisible.toggle()
                }
            }
            delay(seconds: 5) {
                if joinVM.joinSuccess {
                    AppState.shared.showMain = true
                }
            }
        }
        .alert(isPresented: $joinVM.networkErrorAlert) {
            Alert(
                title: Text(StringResources.joinFailAlertTitle),
                message: Text(StringResources.joinFailAlertMessage),
                dismissButton: .cancel(Text(StringResources.confirm), action: {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    self.delay(seconds: 0.5) {
                        exit(0)
                    }
                })
            )
        }
    }
    
    private func delay(seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
