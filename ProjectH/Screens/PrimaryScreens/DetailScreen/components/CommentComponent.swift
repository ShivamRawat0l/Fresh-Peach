//
//  CommentComponent.swift
//  ProjectH
//
//  Created by Shivam Rawat on 04/06/23.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews
import AVFoundation

struct CommentComponent: View {
    @Binding var hootObject : HootsStructure;
    let AudioUrl = {(name: String) in  URL(string: "https://cloud.appwrite.io/v1/storage/buckets/6472f08cd1b379135620/files/\(name)/download?project=64702d2314367a7efc63&mode=admin")}
    
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .red, width: 3, spacing: 3))
    )
    @State var audioPlayer : AVAudioPlayer? ;
    @State var timer = Timer.publish(every: 0.05, on: .main, in: .common);
    @State var progress : Float = 0;
    @State var currentAudioPlaying = false ;
    @EnvironmentObject var googleAuthService : GoogleAuthService;
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
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
                    .foregroundColor(Color("Secondary"))
                    .multilineTextAlignment(.trailing)
                    .font(.custom("Poppins-Regular", size: 14))
            }
            Text(hootObject.title)
                .foregroundColor(Color("Secondary"))
                .multilineTextAlignment(.leading)
                .font(.custom("Poppins-Bold", size: 17))
            HStack{
                Button {
                    Task {
                        if (currentAudioPlaying == false ){
                            self.currentAudioPlaying = true;
                            self.audioPlayer =  await AudioPlayerUtil.playAudio(name: hootObject.id)
                            self.timer = Timer.publish(every: 0.05, on: .main, in: .common)
                            _ =  self.timer.connect()
                        }else {
                            self.currentAudioPlaying = false;
                            self.audioPlayer?.stop()
                            self.timer.connect().cancel();
                        }
                    }
                } label: {
                    if( currentAudioPlaying == true ) {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .foregroundColor(Color("Danger"))
                    } else {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .foregroundColor(Color("Secondary"))
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
                Button {
                    Task {
                        if( hootObject.likes.contains(googleAuthService.userId)) {
                            hootObject.likes.removeAll(where: { id in
                                id == googleAuthService.userId
                            })
                        }else {
                            hootObject.likes.append(googleAuthService.userId)
                            if( hootObject.dislikes.contains(googleAuthService.userId)) {
                                hootObject.dislikes.removeAll { id in
                                    id == googleAuthService.userId
                                }
                            }
                        }
                        hootObject = hootObject;
                        await AppwriteSerivce.shared.addReactionToPost(parentID: hootObject.id, likes: hootObject.likes, dislikes: hootObject.dislikes)
                    }
                } label: {
                    if( hootObject.likes.contains(googleAuthService.userId) ){
                        Image(systemName:  "hand.thumbsup.fill")
                            .foregroundColor(Color("Secondary"))
                    }else {
                        Image(systemName:  "hand.thumbsup")
                            .foregroundColor(Color("Secondary"))
                    }
                    Text(String(hootObject.likes.count))
                        .foregroundColor(Color("Secondary"))
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button {
                    Task{
                        if( hootObject.dislikes.contains(googleAuthService.userId)) {
                            hootObject.dislikes.removeAll { id in
                                id == googleAuthService.userId
                            }
                        }else {
                            hootObject.dislikes.append(googleAuthService.userId)
                            if( hootObject.likes.contains(googleAuthService.userId)) {
                                hootObject.likes.removeAll { id in
                                    id == googleAuthService.userId                            }
                            }
                        }
                        hootObject = hootObject
                        await AppwriteSerivce.shared.addReactionToPost(parentID: hootObject.id, likes: hootObject.likes, dislikes: hootObject.dislikes)
                    }
                } label: {
                    if ( hootObject.dislikes.contains(googleAuthService.userId)) {
                        Image(systemName: "hand.thumbsdown.fill")
                            .foregroundColor(Color("Secondary"))
                    }else {
                        Image(systemName: "hand.thumbsdown")
                            .foregroundColor(Color("Secondary"))
                    }
                    Text(String(hootObject.dislikes.count))
                        .foregroundColor(Color("Secondary"))
                }
                .buttonStyle(BorderlessButtonStyle())
                Image(systemName: "message.circle.fill")
                    .foregroundColor(Color("Secondary"))
                Text(String(hootObject.comments.count))
                    .foregroundColor(Color("Secondary"))
            }
        }
    }
}

struct CommentComponent_Previews: PreviewProvider {
    static var previews: some View {
        let obj = HootsStructure(title: "Titl", id: "sampleID", name: "Name", userId: "userId", isComment: false, likes: [], dislikes: [], commentParent: "same" , comments : [],waveform: [],profilePic: "")
        CommentComponent(hootObject:.constant(obj)).environmentObject(GoogleAuthService())
    }
}
