//
//  PostingAudio.swift
//  ProjectH
//
//  Created by Shivam Rawat on 04/06/23.
//

import SwiftUI
import AVFoundation

struct PostingAudio: View {
    @EnvironmentObject var googleAuthService : GoogleAuthService ;
    @State var currentAudioPlaying : Bool = false ;
    @State var playTimer  = Timer.publish(every: 10, on: .main, in: .common) ;
    @Binding var waveformView : [Float]
    @State var progress : Float = 0 ;
    @State var audioPlayer : AVAudioPlayer?;
    @State var title = "";
    @Binding var postingAudio : Bool;
    @Binding var hootsArray : [HootsStructure]; 
    var appwrite = AppwriteSerivce.shared;
    
    var body: some View {
        HStack {
            Button {
                if(currentAudioPlaying){
                    self.audioPlayer?.stop()
                    self.playTimer.connect().cancel()
                    currentAudioPlaying = false ;
                }else {
                    self.audioPlayer = AudioPlayerUtil.playAudioFromURL(url: AudioManager.fetchAllRecording())
                    currentAudioPlaying = true;
                    self.playTimer = Timer.publish(every: 0.05, on: .main, in: .common)
                    _ = self.playTimer.connect()
                }
            }label: {
                if( currentAudioPlaying == true ) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(Color("Danger"))
                } else {
                    Image(systemName: "play.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
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
        }
        .padding()
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
                if(title != "" ) {
                    Image(systemName: "checkmark.seal.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 50).foregroundColor(Color("Success"))
                }
            }.disabled(title == "" && postingAudio)
            Button {
                postingAudio = false ;
                title = "";
            } label: {
                Image(systemName: "minus.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 40).foregroundColor(Color("Error"))
            }
        }.padding()
    }
}

struct PostingAudio_Previews: PreviewProvider {
    static var previews: some View {
        PostingAudio(waveformView: .constant([]), postingAudio: .constant(false),hootsArray: .constant([]))
    }
}
