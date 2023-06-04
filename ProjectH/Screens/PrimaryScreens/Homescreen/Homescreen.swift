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
    @State var currentAudioPlaying = false ;
    @State var timer = Timer.publish(every: 0.01, on: .current, in: .common)
    @State var playTimer  = Timer.publish(every: 10, on: .main, in: .common) ;
    @State var title = "";
    
    @State var postingAudio = false;
    var audioManager = AudioManager()
    @State var audioPlayer : AVAudioPlayer?;
    @State var progress : Float = 0 ;
    var body: some View {
        VStack{
            ProfileHeader()
            
            Spacer()
            
            if(postingAudio)  {
                HStack {
                    Button {
                        if(currentAudioPlaying){
                            self.audioPlayer?.stop()
                            self.playTimer.connect().cancel()
                            currentAudioPlaying = false ;
                        }else {
                            self.audioPlayer = AudioPlayerUtil.playAudioFromURL(url: AudioManager.fetchAllRecording())
                            currentAudioPlaying = true;
                            self.playTimer = Timer.publish(every: 0.1, on: .main, in: .common)
                            _ = self.playTimer.connect()
                        }
                    }label: {
                        if( currentAudioPlaying == true ) {
                            Image(systemName: "stop.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 30).foregroundColor(Color("Danger"))
                        } else {
                            Image(systemName: "play.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 30)
                        }
                    }
                    AudioPlayer(waveformView: waveformView, progress: $progress)
                        .frame(height: 50)
                        .onReceive(playTimer){ _ in
                            if let safeAudioPlayer = self.audioPlayer {
                                self.progress = Float(safeAudioPlayer.currentTime) / Float(safeAudioPlayer.duration);
                                print(progress,"progress")
                                print(safeAudioPlayer.isPlaying)
                                if( !safeAudioPlayer.isPlaying ){
                                    self.progress = 0.0;
                                    currentAudioPlaying = false ;
                                    self.playTimer.connect().cancel()
                                }
                            }
                        }
                }.padding()
                TextField(text: $title){
                    Text("Start typing to post")
                }.font(Font
                    .system(size: 30,weight: .heavy))
                .padding(.all)
                .background(.clear)
                
                HStack {
                    Spacer()
                    Button {
                        Task {
                            let currentTimeStamp = Date.now.timeIntervalSince1970.description.components(separatedBy: ".")[0]
                            let audioId = "\(googleAuthService.userId)T\(currentTimeStamp)"
                            await appwrite.createAudioFile(audioId: audioId, name: googleAuthService.userName, title: title, userId: googleAuthService.userId, waveform: waveformView, profilePic: googleAuthService.profilePic)
                            postingAudio = false ;
                            title = "";
                            self.hootsArray = await AppwriteSerivce.shared.getRecentHoots();
                        }
                    } label: {
                        Image(systemName: "checkmark.seal.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 50).foregroundColor(Color("Success"))
                    }.disabled(title == "" && postingAudio)
                    Button {
                        postingAudio = false ;
                        title = "";
                    } label: {
                        Image(systemName: "minus.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 40).foregroundColor(Color("Error"))
                    }
                }.padding()
            }
            
            List {
                ForEach(0..<hootsArray.count, id:\.self){  index in
                    NavigationLink{
                        Detailscreen(hootValue: hootsArray[index])
                    } label: {
                        AudioComponent(hootObject: hootsArray[index])
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }.listStyle(.plain)
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
            print(hootsArray)
        }
    }
}

struct Homescreen_Previews: PreviewProvider {
    static var previews: some View {
        Homescreen().environmentObject(GoogleAuthService())
    }
}
