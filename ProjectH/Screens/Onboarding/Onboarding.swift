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
    // Local Variable
    let totalScreens = 3.0;
    
    // Animations
    @State private var showMessage = false;
    @State private var progress = 0.03;
    @State private var currentProgress = 0;
    
    // Environment Object
    @EnvironmentObject  var googleAuthService: GoogleAuthService;
    
    var titles = ["Welcome to FREE SPEECH","Find Your Audio Community.","Where Voices Unite.","Explore the World of Audio."]
    var descriptions = [" Share your voice, engage in meaningful conversations, and explore a diverse range of audio content that resonates with your interests and passions.", "You can express your creativity, connect with fellow enthusiasts, and dive into a multitude of audio experiences that span from immersive stories to soulful music.","Connect with voices that inspire you, engage in lively discussions.Experience the magic of audio connections like never before. ","BETA ACCESS "]
    
    var body: some View {
        VStack {
            Text(titles[currentProgress])
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .font(.custom("Poppins-Black", size: 35))
                .padding(.top,20)
                .padding(.horizontal,40)
            if showMessage {
                Image("onboarding" + String(currentProgress))
                    .resizable()
                    .frame(width: 260,height: 260)
                    .transition(.move(edge: .bottom))
            }
            Text(descriptions[currentProgress])
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .font(.custom("Poppins-Bold", size: 20))
                .padding(.horizontal,40)
            Spacer()
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
                                        Image("google")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25)
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "arrow.forward")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25)
                                            .foregroundColor(.white)
                                    }}
                            }    
                    }
            }
            .onAppear{
                withAnimation {
                    showMessage = true;
                }
            }
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

