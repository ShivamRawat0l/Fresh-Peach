//
//  Homescreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI
import AVFoundation
import DSWaveformImage
import DSWaveformImageViews

struct Homescreen: View {
    
    // @Foriegn Classes
    @EnvironmentObject var googleAuthService : GoogleAuthService ;
    var appwrite = AppwriteSerivce.shared;
    
    // @States
    @State var waveformView = [Float]()
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .red, width: 3, spacing: 3))
    )
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var title = "";
    
    var audioManager = AudioManager()
    var body: some View {
        VStack{
            // MARK: HEADER
            HStack {
                AsyncImage(url: URL(string:googleAuthService.profilePic),scale: 1) { status in
                    status
                        .resizable()
                        .scaledToFill()
                }placeholder: {
                    Color.purple.opacity(0.1)
                }
                .frame(width:60,height: 60)
                .cornerRadius(80)
                
                Spacer()
                
                WaveformLiveCanvas(samples: waveformView,configuration: liveConfiguration,
                                   renderer: LinearWaveformRenderer(),
                                   shouldDrawSilencePadding: true)
                .frame(height: 50)
                .onReceive(timer){time in
                    waveformView.append(audioManager.getAmplitude())
                }
            }.onAppear {
                timer.upstream.connect().cancel()
            }.padding()
            
            Spacer()
            
            // MARK: Listing
            List {
                TextEditor(text: $title).frame(height: 300)
                Button {
                } label: {
                    Text("Post")
                }.disabled(title == "")
                ForEach(1...10, id:\.self){  audios in
                    Color.red.overlay {
                        Text(String(audios)).padding(20)
                    }.listRowSeparator(.hidden)
                }
            }.listStyle(PlainListStyle())
            
            Spacer()
            
            Button {
                var currentTimeStamp = Date.now.timeIntervalSince1970.description.components(separatedBy: ".")[0]
                let audioId = "\(googleAuthService.userId)T\(currentTimeStamp)"
                audioManager.stopRecording()
                appwrite.createAudioFile(audioId:audioId, title: title, userId: googleAuthService.userId, isComment: false, parentId: nil)
                timer.upstream.connect().cancel()
            } label: {
                Image("mic")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
            }.simultaneousGesture(
                LongPressGesture(minimumDuration:0.5).onEnded({ _ in
                    audioManager.recordAudio()
                    timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
                })
            )
            .offset(x:0,y:-20)
            .frame(height: 30)
        }
    }
}

struct Homescreen_Previews: PreviewProvider {
    static var previews: some View {
        Homescreen().environmentObject(GoogleAuthService())
    }
}
