//
//  Homescreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI
import AVFoundation

struct Homescreen: View {
    @EnvironmentObject var googleAuthService : GoogleAuthService ;
    
    // @Foriegn Classes
    var appwrite = AppwriteSerivce.shared;
    
    @State var hootsArray = [HootsStructure]();
    // @States
    @State var waveformView = [Float]()
    @State var timer = Timer.publish(every: 0.01, on: .current, in: .common)
    
    @State var postingAudio = false;
    var audioManager = AudioManager()
    var body: some View {
        VStack{
            ProfileHeader()
            
            Spacer()
            
            if(postingAudio)  {
                PostingAudio(waveformView: $waveformView, postingAudio: $postingAudio, hootsArray: $hootsArray)
            }
            
            List {
                ForEach(0..<hootsArray.count, id:\.self){  index in
                    NavigationLink{
                        Detailscreen(hootValue: $hootsArray[index])
                    } label: {
                        AudioComponent(hootObject: $hootsArray[index])
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .padding(.bottom,40)
            Button {
                postingAudio = true;
                audioManager.stopRecording()
                self.timer.connect().cancel()
            } label: {
                Circle()
                    .fill(.red)
                    .overlay(alignment: .center){
                        Image(systemName: "mic.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit).frame(height: 40)
                    }.frame(height: 70)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration:0.5).onEnded({ _ in
                    audioManager.recordAudio()
                    waveformView = [];
                    self.timer = Timer.publish(every: 0.01, on: .current, in: .common)
                    _ = self.timer.connect()
                })
            )
            .onReceive(timer){time in
                waveformView.append(audioManager.getAmplitude())
            }
            .offset(x:0,y:-40)
            .frame(height: 40)
        }.task{
            hootsArray = await AppwriteSerivce.shared.getRecentHoots();
        }
    }
}

struct Homescreen_Previews: PreviewProvider {
    static var previews: some View {
        Homescreen().environmentObject(GoogleAuthService())
    }
}
