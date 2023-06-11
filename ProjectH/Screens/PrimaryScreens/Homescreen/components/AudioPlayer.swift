//
//  AudioPlayer.swift
//  ProjectH
//
//  Created by Shivam Rawat on 02/06/23.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews



struct AudioPlayer: View {
    
    var waveformView  : [Float];
    
    @Binding var progress: Float ;
    var circleWaveform = false;
    var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: UIColor(Color("Primary")), width: 2,spacing: 2))
    )
    
    
    var liveConfiguration2: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: UIColor(Color("Secondary").opacity(0.4)), width: 2, spacing: 2))
    )
    
    var body: some View {
        VStack (alignment: .leading){
            
            WaveformLiveCanvas(samples: waveformView,configuration: liveConfiguration ,
                               renderer: !self.circleWaveform ? LinearWaveformRenderer() : CircularWaveformRenderer(kind: .circle),
                               shouldDrawSilencePadding: true).frame(alignment: .leading)
                .overlay(alignment: .leading){
                    
                    GeometryReader { geometry in
                        Rectangle().fill(Color("Ascent")).frame(width: CGFloat(progress) * geometry.size.width)
                    }.mask{
                        WaveformLiveCanvas(samples:  waveformView,configuration: liveConfiguration ,
                                           renderer:  !self.circleWaveform ?   LinearWaveformRenderer(): CircularWaveformRenderer(kind: .circle),
                                           shouldDrawSilencePadding: true).frame(minWidth: 0,maxWidth: .infinity)
                    }
                }
        }
    }
}

struct AudioPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayer(waveformView: [],progress:.constant(10.0) )
    }
}
