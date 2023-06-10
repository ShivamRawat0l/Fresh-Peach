//
//  Detailscreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI

struct Detailscreen: View {
    @Binding var hootValue : HootsStructure;
    var appwrite = AppwriteSerivce.shared;
    @State var comments = [HootsStructure]();
    @State var postingAudio = false;
    var audioManager = AudioManager();
    @State var waveformView = [Float]();
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea()
            VStack{
                AudioComponent(hootObject: $hootValue).padding(.all)
                Divider()
                if(postingAudio)  {
                    PostingComment(waveformView: $waveformView, postingAudio: $postingAudio, comments: $comments, parentID: hootValue.id,commentIDs: hootValue.comments)
                }
                List {
                    ForEach(0..<comments.count , id: \.self) { index in
                        NavigationLink{
                            Detailscreen(hootValue: $comments[index])
                        } label: {
                            CommentComponent(hootObject: $comments[index])
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
                        .fill(Color("Secondary"))
                        .overlay(alignment: .center){
                            Image(systemName: "mic.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit).frame(height: 40)
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
                    waveformView.append(audioManager.getAmplitude())
                }
                .offset(x:0,y:-40)
                .frame(height: 40)
                
            }.task {
                comments = await appwrite.getCommentsFor(id: hootValue.id)
            }
        }
    }
}

struct Detailscreen_Previews: PreviewProvider {
    static var previews: some View {
        let obj = HootsStructure(title: "Titl", id: "sampleID", name: "Name", userId: "userId", isComment: false, likes: [], dislikes: [], commentParent: "same" , comments : [],waveform: [],profilePic: "")
        Detailscreen(hootValue: .constant(obj))
    }
}
