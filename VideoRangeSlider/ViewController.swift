//
//  ViewController.swift
//  VideoRangeSlider
//
//  Created by Dave on 4/26/21.
//
 
import UIKit
import AVFoundation
import AVKit 

class ViewController: UIViewController, VideoRangeSliderDelegate {
    
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var startTime = 0.0;
    var endTime = 0.0;
    var progressTime = 0.0;
    var shouldUpdateProgressIndicator = true
    var isSeeking = false
    var timeObserver: AnyObject!
    let path  = Bundle.main.path(forResource: "video", ofType: "MP4")!
    
    @IBOutlet weak var videoViewConteiner: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var rangeSliderView: VideoRangeSlider!
     
    
    @IBAction func playVideoTapped(_ sender: Any) {
        avPlayer.play()
        shouldUpdateProgressIndicator = true
        playButton.isEnabled = false
        pauseButton.isEnabled = true
    }
    
    
    @IBAction func pauseVideoTapped(_ sender: Any) {
        avPlayer.pause()
        playButton.isEnabled = true
        pauseButton.isEnabled = false
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        
        videoViewConteiner.layer.insertSublayer(avPlayerLayer, at: 0)
        videoViewConteiner.layer.masksToBounds = true
        
        rangeSliderView.setVideoURL(videoURL: URL(fileURLWithPath: path))
        rangeSliderView.delegate = self
        
        self.endTime = CMTimeGetSeconds((avPlayer.currentItem?.duration)!)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, preferredTimescale: 100)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) {
            (elapsedTime: CMTime) -> Void in
            self.observeTime(elapsedTime: elapsedTime) } as AnyObject?

       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = videoViewConteiner.bounds
    }
    
    func didChangeValue(videoRangeSlider: VideoRangeSlider, startTime: Float64, endTime: Float64) {
        self.endTime = endTime
        if startTime != self.startTime{
            self.startTime = startTime
            
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, preferredTimescale: timescale!)
            
            if !self.isSeeking {
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: CMTime.zero,
                              toleranceAfter: CMTime.zero) {_ in
                    self.isSeeking = false
                }
            }
        }
    }
    
    func indicatorDidChangePosition(videoRangeSlider: VideoRangeSlider, position: Float64) {
        self.shouldUpdateProgressIndicator = false
        
        avPlayer.pause()
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        
        if self.progressTime != position {
            self.progressTime = position
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.progressTime, preferredTimescale: timescale!)
            if !self.isSeeking {
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) {_ in
                    self.isSeeking = false
                }
            }
        }
    }
    private func observeTime(elapsedTime: CMTime) {
        let elapsedTime = CMTimeGetSeconds(elapsedTime)
        if (avPlayer.currentTime().seconds > self.endTime) {
            avPlayer.pause()
            playButton.isEnabled = true
            pauseButton.isEnabled = false
        }
        if self.shouldUpdateProgressIndicator {
            rangeSliderView.updateProgressIndicator(seconds: elapsedTime)
        }
    }
}


