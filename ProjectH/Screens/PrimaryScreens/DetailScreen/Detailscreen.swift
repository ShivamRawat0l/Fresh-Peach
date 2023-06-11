//
//  Detailscreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI
import Toast

struct Detailscreen: View {
    
    var appwrite = AppwriteSerivce.shared;
    var audioManager = AudioManager();
    
    @State var comments = [HootsStructure]();
    @State var postingAudio = false;
    @State var waveformView = [Float]();
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    
    @Binding var hootValue : HootsStructure;
    @State var timeCounter: Double = 0.0;
    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea()
            VStack{
                AudioComponent(hootObject: $hootValue)
                    .padding(.vertical,20)
                    .padding(.horizontal,30)
                Divider()
                if(timeCounter == 0.0 ){
                    Text("Comments!").font(.custom("Poppins-ExtraBold", size: 20))
                }
                else {
                    VStack{
                        Text("Recording")
                            .foregroundColor(Color.red)
                            .font(.custom("Poppins-ExtraBold", size: 20))
                        Text(String(format:"%.1fs",timeCounter))
                            .foregroundColor(Color.red)
                            .font(.custom("Poppins-ExtraBold", size: 20))
                    }
                }
                if(postingAudio)  {
                    PostingComment(waveformView: $waveformView, postingAudio: $postingAudio, comments: $comments, parentID: hootValue.id,commentIDs: hootValue.comments)
                }
                
                List {
                    ForEach(0..<comments.count , id: \.self) { index in
                        ZStack {
                            NavigationLink{
                                Detailscreen(hootValue: $comments[index])
                            } label: {
                                EmptyView()
                            }
                            CommentComponent(hootObject: $comments[index])
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
                    audioManager.stopRecording()
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
                                .frame(height: 40)
                                .foregroundColor(Color("Background"))
                            
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
                    timeCounter = timeCounter + 0.01;
                    waveformView.append(audioManager.getAmplitude())
                }
                .frame(height: 50)
                
            }.task {
                comments = await appwrite.getCommentsFor(id: hootValue.id)
            }
        }
    }
}

struct Detailscreen_Previews: PreviewProvider {
    static var previews: some View {
        let obj = HootsStructure(title: "Titl", id: "sampleID", name: "Name", userId: "userId", isComment: false, likes: [], dislikes: [], commentParent: "same" , comments : [],waveform: [],profilePic: "", duration: 0.0)
        Detailscreen(hootValue: .constant(obj))
    }
}
