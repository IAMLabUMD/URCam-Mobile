//
//  AudioController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/23/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController{
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    
    func playResourceSound(name: String, delegate: AVAudioPlayerDelegate?){
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        playAudio(url: url, fileType: AVFileType.mp3.rawValue, delegate: delegate)
    }
    
    func playFileSound(name: String, delegate: AVAudioPlayerDelegate?) {
        let audioPath = Log.userDirectory.appendingPathComponent(name)
        playAudio(url: audioPath, fileType: AVFileType.wav.rawValue, delegate: delegate)
    }
    
    func playAudio(url: URL, fileType: String, delegate: AVAudioPlayerDelegate?) {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: fileType)
            if delegate != nil {
                audioPlayer.delegate = delegate
            }
            audioPlayer.play()
            audioPlayer.setVolume(0.5, fadeDuration: 0.1)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    func isAudioPlaying() -> Bool {
        if audioPlayer != nil {
            return audioPlayer.isPlaying
        }
        return false
    }
    
    
    ///////////////// recording
    
    
    func startRecording(fileName: String, delegate: AVAudioRecorderDelegate?) {
        let filePath = Log.userDirectory.appendingPathComponent(fileName)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
        if delegate != nil {
            audioRecorder.delegate = delegate
        }
        //audioRecorder.isMeteringEnabled = true
        
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording() {
        audioRecorder.stop()
    }
}

