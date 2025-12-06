//
//  ContentView.swift
//  Pong Wars
//
//  Created by Ming on 24/5/2025. Inspired by vnglst.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = PongWarsGameModel()
    @State private var timer: Timer?
    @State private var gridSize: Int = 10                   // Default grid size (10x10)
    @State private var isFullScreen: Bool = false           // Track fullscreen state
    @State private var gameSpeed: Double = 1.0              // Default speed multiplier
    @State private var dayColor = Color(hex: "#114C5A")
    @State private var nightColor = Color(hex: "#D9E8E3")
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                ZStack {
                    // Game canvas
                    GameCanvas(gameModel: gameModel)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(4)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isFullScreen.toggle()
                            }
                        }
                }
                
                if !isFullScreen {
                    // Score display
                    HStack {
                        ColorPicker("", selection: $dayColor)
                            .labelsHidden()
                            .onChange(of: dayColor) {_,  newValue in
                                updateDayBallColor(newValue)
                            }
                        
                        Text("Day **\(gameModel.dayScore)** vs Night **\(gameModel.nightScore)**")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color(hex: "#172b36"))
                        
                        ColorPicker("", selection: $nightColor)
                            .labelsHidden()
                            .onChange(of: nightColor) {_,  newValue in
                                updateNightBallColor(newValue)
                            }
                    }.padding(.top, 30)
                    
                    Spacer()
                    
                    // Controls section
                    VStack(spacing: 20) {
                        // Grid size control
                        VStack {
                            Text("Grid Size: \(gridSize)×\(gridSize)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Color(hex: "#172b36"))
                            
                            Slider(value: Binding(
                                get: { Double(gridSize) },
                                set: { newValue in
                                    gridSize = Int(newValue)
                                    gameModel.resetWithGridSize(gridSize)
                                }
                            ), in: 10...40)
                            .accentColor(Color(hex: "#114C5A"))
                            .padding(.horizontal)
                        }
                        
                        // Speed control
                        VStack {
                            Text("Game Speed: \(String(format: "%.1fx", gameSpeed))")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Color(hex: "#172b36"))
                            
                            Slider(value: $gameSpeed, in: 0.5...100.0)
                                .accentColor(Color(hex: "#114C5A"))
                                .padding(.horizontal)
                                .onChange(of: gameSpeed) {_,  newValue in
                                    updateGameSpeed()
                                }
                        }
                    }
                    
                    Spacer()
                    
                    // Attribution
                    VStack(spacing: 5) {
                        Text("Made by MING | SwiftUI Version")
                            .font(.system(size: 10, design: .monospaced))
                        Text("Available on github")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(Color(hex: "#172b36"))
                    .padding(.vertical, 20)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [dayColor, nightColor]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Fullscreen overlay
            if isFullScreen {
                // Floating score display in fullscreen mode
                VStack {
                    HStack {
                        Text("🌞 Day \(gameModel.dayScore) vs Night \(gameModel.nightScore) 🌝")
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isFullScreen = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(8)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            startGameTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / (60.0 * gameSpeed), repeats: true) { _ in
            gameModel.update()
        }
    }
    
    private func updateGameSpeed() {
        // Stop current timer
        timer?.invalidate()
        // Start a new timer with the updated speed
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / (60.0 * gameSpeed), repeats: true) { _ in
            gameModel.update()
        }
    }

    // Color update functions
    private func updateDayColor(_ color: Color) {
        let hexString = color.toHex() ?? "#D9E8E3"
        gameModel.updateDayColor(hexString)
    }
    
    private func updateDayBallColor(_ color: Color) {
        let hexString = color.toHex() ?? "#114C5A"
        gameModel.updateDayBallColor(hexString)
    }
    
    private func updateNightColor(_ color: Color) {
        let hexString = color.toHex() ?? "#172B36"
        gameModel.updateNightColor(hexString)
    }
    
    private func updateNightBallColor(_ color: Color) {
        let hexString = color.toHex() ?? "#D9E8E3"
        gameModel.updateNightBallColor(hexString)
    }
}

#Preview {
    ContentView()
}

