//
//  AudioPlayer.swift
//  ProjectH
//
//  Created by Shivam Rawat on 31/05/23.
//

import Foundation
import AVFoundation


class AudioPlayerUtil {
    static var audioPlayer : AVAudioPlayer?;
    
    static func playAudio(name: String) async -> AVAudioPlayer? {
        do {
            var audioByteBuffer = await AppwriteSerivce.shared.getAudioFromStorage(audioID: name)
            if let safeAudioURL = audioByteBuffer {
                self.audioPlayer = try AVAudioPlayer(data: Data(buffer: safeAudioURL), fileTypeHint:"m4a")
                if let safeAudioPlayer = self.audioPlayer {
                    safeAudioPlayer.play()
                    return safeAudioPlayer ;
                }
            }
        } catch {
            print("Fresh-Peach playAudio",error.localizedDescription)
        }
        return nil;
    }
    
    static func playAudioFromURL( url : URL) -> AVAudioPlayer?{
        do {
            self.audioPlayer  = try AVAudioPlayer(contentsOf: url, fileTypeHint: "m4a")
            if let safeAudioPlayer = self.audioPlayer {
                safeAudioPlayer.play()
                return safeAudioPlayer;
            }
        }
        catch {
            print("Fresh-Peach playAudioFromURL", error.localizedDescription)
        }
        return nil;
    }
    
    static func stopAudio(){
        if let safeAudioPlayer = self.audioPlayer  {
            safeAudioPlayer.stop()
            self.audioPlayer = nil; 
        }
    }
    
}
