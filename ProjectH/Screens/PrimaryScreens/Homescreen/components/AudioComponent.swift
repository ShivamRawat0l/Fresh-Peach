//
//  AudioComponent.swift
//  ProjectH
//
//  Created by Shivam Rawat on 31/05/23.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews
struct AudioComponent: View {
    var hootObject : HootsStructure;
    let AudioUrl = {(name: String) in  URL(string: "https://cloud.appwrite.io/v1/storage/buckets/6472f08cd1b379135620/files/\(name)/download?project=64702d2314367a7efc63&mode=admin")}
    
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .red, width: 3, spacing: 3))
    )
    
    
    var body: some View {
        
        VStack {
            Text(hootObject.title);
            // Audio
            
            Text(String(hootObject.likes.count))
            
            
            if let safeAudioURL = AudioUrl(hootObject.name) {
                Button {
                    Task {
                        await AudioPlayer.playAudio(name: hootObject.name)
                    }
                } label: {
                    Text("PLAY")
                }
                WaveformLiveCanvas(samples: hootObject.waveform,configuration: liveConfiguration,
                                   renderer: LinearWaveformRenderer(),
                                   shouldDrawSilencePadding: true)
                .frame(height: 50)
            }
        }.task {
            // Load the audio from url
        }
    }
}

struct AudioComponent_Previews: PreviewProvider {
    static var previews: some View {
        var obj = HootsStructure(title: "Titl", id: "sampleID", name: "Name", userId: "userId", isComment: false, likes: [], dislikes: [], commentParent: "same" , comments : [],waveform: [])
        AudioComponent(hootObject: obj )
    }
}
