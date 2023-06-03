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
    var timer = Timer.publish(every: 0.2, on: .main, in: .common);
    @State var progress : Float = 0;
    
    var body: some View {
        VStack {
            Text(hootObject.title);
            Text(String(hootObject.likes.count))
            if let safeAudioURL = AudioUrl(hootObject.name) {
                Button {
                    Task {
                        self.audioPlayer =  await AudioPlayerUtil.playAudio(name: hootObject.name)
                        _ =  self.timer.connect()
                    }
                } label: {
                    Text("PLAY")
                }
                AudioPlayer(waveformView: hootObject.waveform, progress: $progress).frame(height: 50)
                    .onReceive(timer){ _ in
                        if let safeAudioPlayer = self.audioPlayer {
                            self.progress = Float(safeAudioPlayer.currentTime) / Float(safeAudioPlayer.duration);
                            print("HERE \(self.progress)")

                        }
                    }
            }
        }
    }
}

struct AudioComponent_Previews: PreviewProvider {
    static var previews: some View {
        var obj = HootsStructure(title: "Titl", id: "sampleID", name: "Name", userId: "userId", isComment: false, likes: [], dislikes: [], commentParent: "same" , comments : [],waveform: [])
        AudioComponent(hootObject: obj )
    }
}
