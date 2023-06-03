//
//  Homescreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI
import AVFoundation

struct Homescreen: View {
    
    // @Foriegn Classes
    @EnvironmentObject var googleAuthService : GoogleAuthService ;
    var appwrite = AppwriteSerivce.shared;
    
    @StateObject var hootsArray = Hoots()
    // @States
    @State var waveformView = [Float]()
    @State var currentAudioPlaying = false ;
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var title = "";
    
    @State var postingAudio = true;
    var audioManager = AudioManager()
    
    @State var progress : Float = 0 ;
    var body: some View {
        VStack{
            // MARK: HEADER
            HStack {
                NavigationLink {
                    Profile()
                }
                label : {
                    AsyncImage(url: URL(string:googleAuthService.profilePic),scale: 1) { status in
                        status
                            .resizable()
                            .scaledToFill()
                    }
                placeholder: {
                    Color.purple.opacity(0.1)
                }
                .frame(width:60,height: 60)
                .cornerRadius(80)
                }
                
                Spacer()
                
            }.onAppear {
                timer
                    .upstream
                    .connect()
                    .cancel()
            }
            .padding()
            
            Spacer()
            
            if( postingAudio  )  {
                HStack {
                    Button {
                        var currentAudioPlayer = AudioPlayerUtil.playAudioFromURL(url: AudioManager.fetchAllRecording())
                        currentAudioPlaying = false;
                    }label: {
                        if( currentAudioPlaying == true ) {
                            Image(systemName: "stop.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 30).foregroundColor(Color("Danger"))
                        } else {
                            Image(systemName: "play.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 30)
                        }
                    }
                    AudioPlayer(waveformView: waveformView, progress: $progress)
                        .frame(height: 50)
                }.padding()
                TextField(text: $title){
                    Text("Start typing to post")
                }.font(Font.system(size: 30,weight: .heavy))
                .padding(.all)
                .background(.clear)
            
                HStack {
                    Spacer()
                    Button {
                        Task {
                            let currentTimeStamp = Date.now.timeIntervalSince1970.description.components(separatedBy: ".")[0]
                            let audioId = "\(googleAuthService.userId)T\(currentTimeStamp)"
                            await appwrite.createAudioFile(audioId:audioId, title: title, userId: googleAuthService.userId, isComment: false, parentId: nil, waveform: waveformView)
                            postingAudio = false ;
                            title = "";
                            await hootsArray.getPosts()
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
                ForEach(0..<hootsArray.hootsData.count, id:\.self){  index in
                    AudioComponent(hootObject: hootsArray.hootsData[index])
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
           }.listStyle(.plain)
            .padding(.bottom,40)
            
            Button {
                postingAudio = true;
                audioManager.stopRecording()
                timer.upstream.connect().cancel()
            } label: {
                
                Circle().fill(.red)
                    .overlay(alignment: .center){
                        Image(systemName: "mic.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit).frame(height: 40)
                    }.frame(height: 70)
                
                
            }.simultaneousGesture(
                LongPressGesture(minimumDuration:0.5).onEnded({ _ in
                    audioManager.recordAudio()
                    waveformView = [];
                    
                    timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
                })
            )
            .onReceive(timer){time in
                waveformView.append(audioManager.getAmplitude())
            }
            .offset(x:0,y:-40)
            .frame(height: 40)
        }.task{
            await hootsArray.getPosts();
        }
    }
}

struct Homescreen_Previews: PreviewProvider {
    static var previews: some View {
        Homescreen().environmentObject(GoogleAuthService())
    }
}
