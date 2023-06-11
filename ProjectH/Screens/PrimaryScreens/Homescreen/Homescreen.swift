//
//  Homescreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI
import AVFoundation
import Introspect
import Toast

struct Homescreen: View {
    @EnvironmentObject var googleAuthService : GoogleAuthService ;
    
    // @Foriegn Classes
    var appwrite = AppwriteSerivce.shared;
    
    @State var hootsArray = [HootsStructure]();
    // @States
    @State var waveformView = [Float]()
    @State var timer = Timer.publish(every: 0.01, on: .current, in: .common)
    
    @State var isRecording = false ;
    @State var postingAudio = false;
    @State var timeCounter = 0.0;
    
    var audioManager = AudioManager()
    var body: some View {
        VStack{
            ProfileHeader(timeCounter: $timeCounter )
            Spacer()
            
            if(postingAudio)  {
                PostingAudio(waveformView: $waveformView, postingAudio: $postingAudio, hootsArray: $hootsArray)
            }
            
            List{
                ForEach(0..<hootsArray.count, id:\.self){  index in
                    ZStack{
                        
                        NavigationLink{
                            Detailscreen(hootValue: $hootsArray[index])
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                        AudioComponent(hootObject: $hootsArray[index])
                            .padding(.all,20)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                            .shadow(radius: 5)
                        
                        
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            
            Button {
                print(timeCounter)
                audioManager.stopRecording()
                self.isRecording = false;
                self.timer.connect().cancel()
                if(timeCounter < 2){
                    let toast = Toast.text("Hold the mic to start recording")
                    toast.show()
                }
                else if(timeCounter < 10) {
                    let toast = Toast.text("Minimum length of audio should be 10 sec")
                    toast.show()

                } else {
                    postingAudio = true;
                    
                }
                timeCounter = 0;
            } label: {
                Circle()
                    .fill(Color("Secondary"))
                    .overlay(alignment: .center){
                        Image(systemName: "mic.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color("Background"))
                            .frame(height: 40)
                    }.frame(height: 70)
                  
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration:0.5).onEnded({ _ in
                    audioManager.recordAudio()
                    waveformView = [];
                    self.isRecording = true;
                    self.timer = Timer.publish(every: 0.01, on: .current, in: .common)
                    _ = self.timer.connect()
                })
            )
            .onReceive(timer){time in
                timeCounter = timeCounter + 0.01;
                waveformView.append(audioManager.getAmplitude())
            }
            
            .frame(height: 50)
            
        }
        .task{
            hootsArray = await AppwriteSerivce.shared.getRecentHoots();
        }
    }
}

struct Homescreen_Previews: PreviewProvider {
    static var previews: some View {
        Homescreen().environmentObject(GoogleAuthService())
    }
}
