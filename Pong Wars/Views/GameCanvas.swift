//
//  GameCanvas.swift
//  Pong Wars
//
//  Created by Ming on 24/5/2025. Inspired by vnglst.
//

import SwiftUI

// Game Canvas that renders the game state
struct GameCanvas: View {
    @ObservedObject var gameModel: PongWarsGameModel
    
    var body: some View {
        Canvas { context, size in
            // Draw squares
            for i in 0..<gameModel.numSquaresX {
                for j in 0..<gameModel.numSquaresY {
                    let squareSize = size.width / CGFloat(gameModel.numSquaresX)
                    let rect = CGRect(
                        x: CGFloat(i) * squareSize,
                        y: CGFloat(j) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    
                    let color = gameModel.squares[i][j] == gameModel.dayColor ? 
                        Color(hex: gameModel.dayColor) : Color(hex: gameModel.nightColor)
                    
                    context.fill(Path(rect), with: .color(color))
                }
            }
            
            // Draw balls
            for ball in gameModel.balls {
                let squareSize = size.width / CGFloat(gameModel.numSquaresX)
                let radius = squareSize / 2
                
                let ballX = CGFloat(ball.x) / CGFloat(gameModel.canvasWidth) * size.width
                let ballY = CGFloat(ball.y) / CGFloat(gameModel.canvasHeight) * size.height
                
                let circlePath = Path(ellipseIn: CGRect(
                    x: ballX - radius,
                    y: ballY - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                
                context.fill(circlePath, with: .color(Color(hex: ball.ballColor)))
            }
        }
        .background(Color.white.opacity(0.01)) // Tiny bit of background to make canvas tappable
    }
}

