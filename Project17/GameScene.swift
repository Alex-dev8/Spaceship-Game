//
//  GameScene.swift
//  Project17
//
//  Created by Alex Cannizzo on 18/09/2021.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var numberOfSeconds: Double = 1.0
    var numberOfEnemies = 0 {
        didSet {
            if numberOfEnemies == 3 && numberOfSeconds >= 0.5 {
                numberOfSeconds -= 0.1
                numberOfEnemies = 0
                gameTimer?.invalidate()
                updateTimer(seconds: numberOfSeconds)
            } else {
                gameTimer?.invalidate()
                updateTimer(seconds: 0.5)
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: numberOfSeconds, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        numberOfEnemies += 1
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        gameTimer?.invalidate()
        
        let ac = UIAlertController(title: "Game Over", message: "Your score was: \(scoreLabel.text!)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.playAgain()
        }))
        self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
        
    }
    
    func updateTimer(seconds: Double) {
        gameTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    func playAgain() {
        score = 0
        isGameOver = false
        updateTimer(seconds: 1)
        numberOfSeconds = 1
        numberOfEnemies = 0
        player.position = CGPoint(x: 100, y: 384)
        addChild(player)
        createEnemy()
    }
    
}
