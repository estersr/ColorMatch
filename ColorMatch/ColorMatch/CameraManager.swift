//
//  CameraManager.swift
//  ColorMatch
//
//  Created by Esther Ramos on 17/10/25.
//

import AVFoundation
import UIKit
import SwiftUI
import Combine 

class CameraManager: NSObject, ObservableObject {
    @Published var capturedColor: Color?
    @Published var capturedUIColor: UIColor?
    @Published var isCameraActive = false
    @Published var error: CameraError?
    
    let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var captureDevice: AVCaptureDevice?
    
    enum CameraError: Error {
        case noCameraAvailable
        case permissionDenied
        case setupFailed
    }
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.error = .permissionDenied
                    }
                }
            }
        default:
            error = .permissionDenied
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            error = .noCameraAvailable
            return
        }
        
        captureDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
        } catch {
            self.error = .setupFailed
        }
    }
    
    func startCamera() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.isCameraActive = true
            }
        }
    }
    
    func stopCamera() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        isCameraActive = false
    }
    
    func captureColor(from point: CGPoint? = nil) {
        // This would capture from the live feed
        // For simplicity, we'll use the current buffer
        // In a real app, you'd capture from specific coordinates
        guard let buffer = lastBuffer else { return }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else { return }
        
        let bufferPointer = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        // Sample from center of frame
        let x = point?.x ?? CGFloat(width) / 2
        let y = point?.y ?? CGFloat(height) / 2
        let bufferX = Int(x)
        let bufferY = Int(y)
        
        let pixelIndex = bufferY * bytesPerRow + bufferX * 4
        
        guard pixelIndex + 2 < height * bytesPerRow else { return }
        
        let b = CGFloat(bufferPointer[pixelIndex]) / 255.0
        let g = CGFloat(bufferPointer[pixelIndex + 1]) / 255.0
        let r = CGFloat(bufferPointer[pixelIndex + 2]) / 255.0
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        DispatchQueue.main.async {
            self.capturedUIColor = color
            self.capturedColor = Color(color)
        }
    }
    
    private var lastBuffer: CVPixelBuffer?
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lastBuffer = pixelBuffer
    }
}
