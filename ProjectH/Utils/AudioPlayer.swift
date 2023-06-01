//
//  AudioPlayer.swift
//  ProjectH
//
//  Created by Shivam Rawat on 31/05/23.
//

import Foundation
import AVFoundation


class AudioPlayer {
    static var audioPlayer : AVAudioPlayer?;
    
    static func playAudio(name: String) async {
        do {
            var audioByteBuffer = await AppwriteSerivce.shared.getAudioFromStorage(audioID: name)
            if let safeAudioURL = audioByteBuffer {
                self.audioPlayer = try AVAudioPlayer(data: Data(buffer: safeAudioURL), fileTypeHint:"m4a")
                if let safeAudioPlayer = self.audioPlayer {
                    safeAudioPlayer.play()
                }
            }
        } catch {
            print("Fresh-Peach playAudio",error.localizedDescription)
        }
    }
    
    static func playAudioFromURL( url : URL){
        do {
            self.audioPlayer  = try AVAudioPlayer(contentsOf: url, fileTypeHint: "m4a")
            if let safeAudioPlayer = self.audioPlayer {
                safeAudioPlayer.play()
            }
        }
        catch {
            print("Fresh-Peach playAudioFromURL", error.localizedDescription)
        }
    }
    
    static func stopAudio(){
        if let safeAudioPlayer = self.audioPlayer  {
            safeAudioPlayer.stop()
            self.audioPlayer = nil; 
        }
    }
    
}
