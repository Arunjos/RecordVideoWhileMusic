//
//  ViewController.swift
//  RecordVideoWhileMusic
//
//  Created by Arun Jose on 03/08/18.
//  Copyright © 2018 Arun Jose. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCaptureFileOutputRecordingDelegate {
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    @IBOutlet var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.cameraView = self.view
        // This code will disable automatically setting audio session.
        captureSession.automaticallyConfiguresApplicationAudioSession = false;
        setupAndStartRecordForTenSeconds()
    }
    
    func setupAndStartRecordForTenSeconds() -> () {
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)
        for videoDevice in videoDevices {
            if videoDevice.position == AVCaptureDevice.Position.back{
                do{
                    //add audio input
                    let audioDevice = AVCaptureDevice.default(for: .audio)!
                    let audioInput = try! AVCaptureDeviceInput(device: audioDevice)
                    //add video input
                    let videoInput = try AVCaptureDeviceInput(device: videoDevice )
                    if captureSession.canAddInput(audioInput){
                        captureSession.addInput(audioInput)
                    }
                    if captureSession.canAddInput(videoInput){
                        captureSession.addInput(videoInput)
                        //set output session
                        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                        
                        if captureSession.canAddOutput(sessionOutput){
                            
                            captureSession.addOutput(sessionOutput)
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                            cameraView.layer.addSublayer(previewLayer)
                            
                            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            previewLayer.bounds = cameraView.frame
                        }
                        
                        captureSession.addOutput(movieOutput)
                        //capture starts
                        captureSession.startRunning()
                        //providing save file path
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let fileUrl = paths[0].appendingPathComponent("output.mov")
                        try? FileManager.default.removeItem(at: fileUrl)
                        movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
                        //logic for recording 10sec and stop recording
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
                            print("stopping")
                            //stop recording
                            self.movieOutput.stopRecording()
                        }
                    }
                }
                catch{
                    print("Error")
                }
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("FINISHED \(String(describing: error))")
        // save video to camera roll
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        }
    }

}

