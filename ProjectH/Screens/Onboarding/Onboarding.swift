//
//  ContentView.swift
//  ProjectH
//
//  Created by Shivam Rawat on 26/05/23.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn
struct OnboardingView: View  {
    let totalScreens = 3.0;
    // Animations
    @State private var showMessage = false;
    @State private var progress = 0.03;
    @State private var currentProgress = 0;
    
    // Navigations
    @State private var navigateToProfile = false ;
    
    @AppStorage("onboarding") var isOnboarding : Bool = true;
    @AppStorage("accessToken") var accessToken = "";
    @AppStorage("email") var email = "";
    @AppStorage("profilePicture") var profilePic = "";

    
    @EnvironmentObject  var googleAuthService: GoogleAuthService;
    
    var body: some View {
        
        VStack {
          //  NavigationLink(destination: Profile(), isActive: $navigateToProfile ){ EmptyView()}
            if showMessage {
                Image("onboarding1")
                    .resizable()
                    .frame(width: 300,height: 300)
                    .transition(.move(edge: .bottom))
            }
            Spacer()
            Text("Fresh Peach").font(.system(size: 30))
            Button {
                
                if currentProgress == Int(totalScreens){
                    googleAuthService.signin()
                }else {
                    withAnimation (.easeOut(duration: 0.2)) {
                        progress = (Double(currentProgress)+1.0) / totalScreens;
                        currentProgress = currentProgress + 1;
                    }
                }
            } label: {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 80)
                    .overlay {
                        Circle()
                            .trim(from:0    ,to:progress)
                            .stroke(.red,lineWidth: 5)
                            .frame(width: 70)
                            .rotationEffect(.degrees(-90))
                            .overlay {
                                Group {
                                    if currentProgress == Int(totalScreens) {
                                        Image("google").resizable().aspectRatio(contentMode: .fit).frame(width: 25).foregroundColor(.white)
                                    } else { Image(systemName: "arrow.forward").resizable().aspectRatio(contentMode: .fit).frame(width: 25).foregroundColor(.white)
                                        
                                    }}
                            }    
                    }
            }
            .onAppear{
                withAnimation {
                    showMessage = true;
                }
            }
            .padding()
            .onDisappear{
                currentProgress = 0 ;
                progress = 0.03;
                showMessage = false;
            }
            
            
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
