//
//  ContentView.swift
//  ColorMatch
//
//  Created by Esther Ramos on  17/10/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var cameraManager: CameraManager
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var matchedColors: [PantoneColor] = []
    @State private var selectedColor: UIColor?
    @State private var showColorPicker = false
    @State private var isCapturing = false
    @State private var showHistory = false
    @State private var colorHistory: [UIColor] = []
    @State private var flashOpacity: Double = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Camera Preview / Color Display
                    cameraPreviewView
                        .frame(height: 400)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Capture Controls
                    VStack(spacing: 25) {
                        captureButton
                        
                        if let selectedColor = selectedColor {
                            currentColorInfo(color: selectedColor)
                        } else {
                            InstructionView()
                        }
                    }
                    .padding(.top, 30)
                    
                    if !matchedColors.isEmpty {
                        colorMatchesView
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("ColorMatch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showHistory.toggle() }) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showColorPicker.toggle() }) {
                        Image(systemName: "eyedropper")
                    }
                }
            }
            .sheet(isPresented: $showColorPicker) {
                manualColorPicker
            }
            .sheet(isPresented: $showHistory) {
                colorHistoryView
            }
            .onAppear {
                cameraManager.startCamera()
            }
            .onDisappear {
                cameraManager.stopCamera()
            }
        }
    }
    
    private var cameraPreviewView: some View {
        ZStack {
            if cameraManager.isCameraActive {
                CameraPreview(cameraManager: cameraManager)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(flashOpacity))
                            .ignoresSafeArea()
                            .animation(.easeOut(duration: 0.2), value: flashOpacity)
                    )
                    .overlay(
                        // Crosshair for precise selection
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 60, height: 60)
                            .shadow(color: .black, radius: 2)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                // Call captureColor with the point
                                captureColor(at: value.location)
                            }
                    )
            } else {
                Color.black
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Camera access required")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 10)
                        }
                    )
            }
            
            if let capturedColor = cameraManager.capturedColor {
                Rectangle()
                    .fill(capturedColor)
                    .ignoresSafeArea()
            }
        }
    }
    
    private var captureButton: some View {
        Button(action: {
            // Call captureColor without a point (center)
            captureColor(at: nil)
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .shadow(color: .black.opacity(0.3), radius: 8)
                
                Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                if isCapturing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
        }
        .disabled(isCapturing)
    }
    
    private struct InstructionView: View {
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Tap anywhere to capture color")
                    .font(.headline)
                
                Text("Or use the capture button")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
        }
    }
    
    private func currentColorInfo(color: UIColor) -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 30) {
                // Color Preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(color))
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Color Values
                VStack(alignment: .leading, spacing: 6) {
                    Text("RGB: \(color.rgbComponents.r), \(color.rgbComponents.g), \(color.rgbComponents.b)")
                        .font(.system(.body, design: .monospaced))
                    
                    if let hex = Color(color).toHex() {
                        Text("HEX: \(hex)")
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
    }
    
    private var colorMatchesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Pantone Matches")
                .font(.headline)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(matchedColors) { pantone in
                        pantoneCard(color: pantone)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func pantoneCard(color: PantoneColor) -> some View {
        VStack(spacing: 10) {
            // Color Swatch
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.color)
                    .frame(width: 100, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 100, height: 120)
            }
            
            // Color Info
            VStack(spacing: 4) {
                Text(color.pantoneCode)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                
                Text(color.name)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 100)
                
                if let year = color.year {
                    Text("\(year)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var manualColorPicker: some View {
        NavigationView {
            VStack {
                ColorPicker("Select a color", selection: Binding(
                    get: { Color(cameraManager.capturedUIColor ?? .white) },
                    set: { newColor in
                        let uiColor = UIColor(newColor)
                        selectedColor = uiColor
                        findMatches(for: uiColor)
                    }
                ))
                .labelsHidden()
                .frame(height: 200)
                .padding()
                
                if let selectedColor = selectedColor {
                    currentColorInfo(color: selectedColor)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Manual Color Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showColorPicker = false
                    }
                }
            }
        }
    }
    
    private var colorHistoryView: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 15)], spacing: 15) {
                    ForEach(colorHistory.indices, id: \.self) { index in
                        Button(action: {
                            selectedColor = colorHistory[index]
                            findMatches(for: colorHistory[index])
                            showHistory = false
                        }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(colorHistory[index]))
                                    .frame(height: 80)
                                
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Color History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showHistory = false
                    }
                }
            }
        }
    }
    
    private func captureColor(at point: CGPoint? = nil) {
        isCapturing = true
        
        // Flash effect
        withAnimation {
            flashOpacity = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            flashOpacity = 0
        }
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cameraManager.captureColor(from: point)
            
            if let color = cameraManager.capturedUIColor {
                selectedColor = color
                findMatches(for: color)
                
                // Add to history (limit to 20)
                colorHistory.insert(color, at: 0)
                if colorHistory.count > 20 {
                    colorHistory.removeLast()
                }
            }
            isCapturing = false
        }
    }
    
    private func findMatches(for color: UIColor) {
        matchedColors = PantoneData.getTopMatches(for: color, count: 5)
    }
}

// Camera Preview View
struct CameraPreview: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}

// Extension for random color generation (for testing)
extension UIColor {
    static func random() -> UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
