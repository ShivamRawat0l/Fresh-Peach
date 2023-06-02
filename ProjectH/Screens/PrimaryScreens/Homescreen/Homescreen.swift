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
    
    @StateObject var hootsArray = Hoots()
    // @States
    @State var waveformView = [Float]()
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: UIColor(Color("Secondary")), width: 2, spacing: 2))
    )
    @State var liveConfiguration2: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: UIColor(Color("Primary")), width: 2, spacing: 2))
    )
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var title = "";
    
    @State var postingAudio = true;
    var audioManager = AudioManager()
    
    
    init() {
           UITextView.appearance().backgroundColor = .clear
       }
    
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
             
                Rectangle().background(.red).frame(width: 100).mask{
                        WaveformLiveCanvas(samples: waveformView,configuration: liveConfiguration2,
                                           renderer: LinearWaveformRenderer(),
                                           shouldDrawSilencePadding: true)
                }
                    .frame(height: 50)
                    .onReceive(timer){time in
                        waveformView.append(audioManager.getAmplitude())
                    }
                
            }.onAppear {
                timer
                    .upstream
                    .connect()
                    .cancel()
            }
            .padding()
            
            Spacer()
            
            // MARK: Listing
            
            
            if( postingAudio  )  {
                HStack{
                    Button {
                        AudioPlayer.playAudioFromURL(url: AudioManager.fetchAllRecording())
                    }label: {
                        Text("play")
                    }
                    WaveformLiveCanvas(samples: waveformView,configuration: liveConfiguration,
                                       renderer: LinearWaveformRenderer(),
                                       shouldDrawSilencePadding: true).progressViewStyle(.automatic)
                    .frame(height: 50)
                }
                
                ZStack(alignment: .topLeading){
                  
                    TextField(text: $title){
                            Text("Start typing to post")
                    }
                    .padding(.all)
                    .background(.clear)
                    
                }
                
                HStack {
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
                        Text("Post")
                }.disabled(title == "" && postingAudio)
                    Button {
            
                            postingAudio = false ;
                            title = "";
                    } label: {
                        Text("Cancel")
                }
                }
                
            }
            
            
            
            List {
                
                ForEach(0..<hootsArray.hootsData.count, id:\.self){  index in
                        AudioComponent(hootObject: hootsArray.hootsData[index])
                    
                        .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
            .background(.clear)
            .listRowBackground(Color.clear)
            .padding(.bottom,20)
                Button {
                    postingAudio = true;
                    audioManager.stopRecording()
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
            }.task{
                await hootsArray.getPosts()
            }
        
    }
}

struct Homescreen_Previews: PreviewProvider {
    static var previews: some View {
        Homescreen().environmentObject(GoogleAuthService())
    }
}
