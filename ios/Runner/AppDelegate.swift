import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var audioPlayer: AVAudioPlayer?
  private var isLooping = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let soundChannel = FlutterMethodChannel(name: "com.example.flutter_order_manager/sound",
                                            binaryMessenger: controller.binaryMessenger)
    
    soundChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      if call.method == "playOrderCreatedSound" {
        self.playOrderCreatedSound()
        result(nil)
      } else if call.method == "stopSound" {
        self.stopSound()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func playOrderCreatedSound() {
    guard let soundURL = Bundle.main.url(forResource: "order_created", withExtension: "mp3") else {
      print("Sound file not found")
      return
    }
    
    do {
      // Stop any existing audio
      stopSound()
      
      // Create and configure new audio player
      audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
      audioPlayer?.numberOfLoops = -1 // Loop indefinitely
      audioPlayer?.play()
      isLooping = true
    } catch {
      print("Could not play sound: \(error)")
    }
  }
  
  private func stopSound() {
    if isLooping {
      audioPlayer?.stop()
      audioPlayer = nil
      isLooping = false
    }
  }
}

