//
//  PongWarsGameModel.swift
//  Pong Wars
//
//  Created by Ming on 24/5/2025. Inspired by vnglst.
//

import SwiftUI

// Game model that manages the game state
class PongWarsGameModel: ObservableObject {
    // Colors from the original
    @Published var dayColor = "#D9E8E3"
    @Published var dayBallColor = "#114C5A"
    @Published var nightColor = "#172B36"
    @Published var nightBallColor = "#D9E8E3"
    
    // Game constants
    var squareSize: Int
    let minSpeed: Double = 5
    let maxSpeed: Double = 10
    let canvasWidth = 600
    let canvasHeight = 600
    
    var numSquaresX: Int
    var numSquaresY: Int
    
    @Published var dayScore = 0
    @Published var nightScore = 0
    @Published var squares: [[String]]
    @Published var balls: [Ball] = [] // Initialize with empty array first
    
    struct Ball {
        var x: Double
        var y: Double
        var dx: Double
        var dy: Double
        var reverseColor: String
        var ballColor: String
    }
    
    init() {
        numSquaresX = 10 // Default grid size
        numSquaresY = 10
        squareSize = canvasWidth / numSquaresX
        
        // Initialize squares
        squares = Array(repeating: Array(repeating: "", count: numSquaresY), count: numSquaresX)
        initializeSquares()
        initializeBalls()
    }
    
    private func initializeSquares() {
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                squares[i][j] = i < numSquaresX / 2 ? dayColor : nightColor
            }
        }
    }
    
    private func initializeBalls() {
        balls = [
            Ball(
                x: Double(canvasWidth) / 4,
                y: Double(canvasHeight) / 2,
                dx: 8,
                dy: -8,
                reverseColor: dayColor,
                ballColor: dayBallColor
            ),
            Ball(
                x: Double(canvasWidth) * 3 / 4,
                y: Double(canvasHeight) / 2,
                dx: -8,
                dy: 8,
                reverseColor: nightColor,
                ballColor: nightBallColor
            )
        ]
    }
    
    func resetWithGridSize(_ size: Int) {
        numSquaresX = size
        numSquaresY = size
        squareSize = canvasWidth / numSquaresX
        
        // Reinitialize squares with new size
        squares = Array(repeating: Array(repeating: "", count: numSquaresY), count: numSquaresX)
        initializeSquares()
        initializeBalls()
    }
    
    func update() {
        updateScores()
        
        // Update each ball
        for i in 0..<balls.count {
            checkSquareCollision(for: &balls[i])
            checkBoundaryCollision(for: &balls[i])
            
            // Move ball
            balls[i].x += balls[i].dx
            balls[i].y += balls[i].dy
            
            // Add randomness
            addRandomness(to: &balls[i])
        }
    }
    
    private func updateScores() {
        dayScore = 0
        nightScore = 0
        
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                if squares[i][j] == dayColor {
                    dayScore += 1
                } else if squares[i][j] == nightColor {
                    nightScore += 1
                }
            }
        }
    }
    
    private func checkSquareCollision(for ball: inout Ball) {
        // Check multiple points around the ball's circumference
        for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 4) {
            let checkX = ball.x + cos(angle) * Double(squareSize / 2)
            let checkY = ball.y + sin(angle) * Double(squareSize / 2)
            
            let i = Int(checkX) / squareSize
            let j = Int(checkY) / squareSize
            
            if i >= 0 && i < numSquaresX && j >= 0 && j < numSquaresY {
                if squares[i][j] != ball.reverseColor {
                    // Square hit! Update square color
                    squares[i][j] = ball.reverseColor
                    
                    // Determine bounce direction based on the angle
                    if abs(cos(angle)) > abs(sin(angle)) {
                        ball.dx = -ball.dx
                    } else {
                        ball.dy = -ball.dy
                    }
                }
            }
        }
    }
    
    private func checkBoundaryCollision(for ball: inout Ball) {
        let radius = Double(squareSize) / 2
        if ball.x + ball.dx > Double(canvasWidth) - radius || ball.x + ball.dx < radius {
            ball.dx = -ball.dx
        }
        if ball.y + ball.dy > Double(canvasHeight) - radius || ball.y + ball.dy < radius {
            ball.dy = -ball.dy
        }
    }
    
    private func addRandomness(to ball: inout Ball) {
        ball.dx += Double.random(in: -0.01...0.01)
        ball.dy += Double.random(in: -0.01...0.01)
        
        // Limit the speed of the ball
        ball.dx = min(max(ball.dx, -maxSpeed), maxSpeed)
        ball.dy = min(max(ball.dy, -maxSpeed), maxSpeed)
        
        // Make sure the ball always maintains a minimum speed
        if abs(ball.dx) < minSpeed {
            ball.dx = ball.dx > 0 ? minSpeed : -minSpeed
        }
        if abs(ball.dy) < minSpeed {
            ball.dy = ball.dy > 0 ? minSpeed : -minSpeed
        }
    }
    
    func updateDayColor(_ newColor: String) {
        // Update all squares with the old day color
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                if squares[i][j] == dayColor {
                    squares[i][j] = newColor
                }
            }
        }
        
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].reverseColor == dayColor {
                balls[i].reverseColor = newColor
            }
        }
        
        dayColor = newColor
    }
    
    func updateDayBallColor(_ newColor: String) {
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].ballColor == dayBallColor {
                balls[i].ballColor = newColor
            }
        }
        
        dayBallColor = newColor
    }
    
    func updateNightColor(_ newColor: String) {
        // Update all squares with the old night color
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                if squares[i][j] == nightColor {
                    squares[i][j] = newColor
                }
            }
        }
        
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].reverseColor == nightColor {
                balls[i].reverseColor = newColor
            }
        }
        
        nightColor = newColor
    }
    
    func updateNightBallColor(_ newColor: String) {
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].ballColor == nightBallColor {
                balls[i].ballColor = newColor
            }
        }
        
        nightBallColor = newColor
    }
}

