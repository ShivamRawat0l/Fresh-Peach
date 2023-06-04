//
//  AudioComponent.swift
//  ProjectH
//
//  Created by Shivam Rawat on 31/05/23.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews
import AVFoundation;

struct AudioComponent: View {
    var hootObject : HootsStructure;
    let AudioUrl = {(name: String) in  URL(string: "https://cloud.appwrite.io/v1/storage/buckets/6472f08cd1b379135620/files/\(name)/download?project=64702d2314367a7efc63&mode=admin")}
    
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .red, width: 3, spacing: 3))
    )
    @State var audioPlayer : AVAudioPlayer? ;
    @State var timer = Timer.publish(every: 0.2, on: .main, in: .common);
    @State var progress : Float = 0;
    @State var currentAudioPlaying = false ;
    
    var body: some View {
        VStack {
            HStack {
                if let profilePic = URL(string: hootObject.profilePic) {
                    AsyncImage(url: profilePic,scale:1){ status in
                        status.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.purple.opacity(0.1)
                    }
                    .frame(width:30,height: 30)
                    .cornerRadius(40)
                }
                Text(hootObject.name)
                Spacer()
            }
            Text(hootObject.title);
            HStack{
                Button {
                    Task {
                        if (currentAudioPlaying == false ){
                            self.currentAudioPlaying = true;
                            self.audioPlayer =  await AudioPlayerUtil.playAudio(name: hootObject.id)
                            self.timer = Timer.publish(every: 0.2, on: .main, in: .common)
                            _ =  self.timer.connect()
                        }else {
                            self.currentAudioPlaying = false;
                            self.audioPlayer?.stop()
                            self.timer.connect().cancel();
                        }
                    }
                } label: {
                        if( currentAudioPlaying == true ) {
                            Image(systemName: "stop.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 30).foregroundColor(Color("Danger"))
                        } else {
                            Image(systemName: "play.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 30)
                        }
                }
                .buttonStyle(BorderlessButtonStyle())
                
                AudioPlayer(waveformView: hootObject.waveform, progress: $progress).frame(height: 50)
                    .onReceive(timer){ _ in
                        if let safeAudioPlayer = self.audioPlayer {
                            self.progress = Float(safeAudioPlayer.currentTime) / Float(safeAudioPlayer.duration);
                            if( !safeAudioPlayer.isPlaying ) {
                                self.timer.connect().cancel()
                                self.progress = 0.0;
                                self.currentAudioPlaying = false;
                            }
                        }
                    }
            }
            HStack{
                Image(systemName:  "hand.thumbsup.fill")
                Text(String(hootObject.likes.count))
                Image(systemName: "hand.thumbsdown.fill")
                Text(String(hootObject.dislikes.count))
                Image(systemName: "message.circle.fill")
                Text(String(hootObject.comments.count))
            }
        }
    }
}

struct AudioComponent_Previews: PreviewProvider {
    static var previews: some View {
        let obj = HootsStructure(title: "Titl", id: "sampleID", name: "Name", userId: "userId", isComment: false, likes: [], dislikes: [], commentParent: "same" , comments : [],waveform: [],profilePic: "")
        AudioComponent(hootObject: obj )
    }
}
