//
//  GameScene.swift
//  TappyBird
//
//  Created by Joshua Parker on 24/01/16.
//  Copyright (c) 2016 Joshua Parker. All rights reserved.
//
//  The amazing Flappy Bird clone
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // setup objects
    var bg = SKSpriteNode()
    var player = SKSpriteNode()
    var gameOver = false
    var gameOverLabel = SKLabelNode()
    var gameStarted = false
    var score = Int()
    var scoreLabel = SKLabelNode()
    var movingObjects = SKSpriteNode()
    var notificationLabels = SKSpriteNode()
    
    // enum for collision types
    enum ColliderType: UInt32 {
        case Player = 1
        case Object = 2
        case Score = 4
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        self.addChild(notificationLabels)
        makeBG()
        
        // score label
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 999
        self.addChild(scoreLabel)
        
        // setup ground
        let ground = SKNode()
        ground.position = CGPointMake(0,0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.affectedByGravity = false
        self.addChild(ground)
        
        // setup player
        let birdUpTexture = SKTexture(imageNamed: "flappy1.png")
        let birdDownTexture = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdUpTexture,birdDownTexture],  timePerFrame: 0.1)
        let flappyBird = SKAction.repeatActionForever(animation)
        player = SKSpriteNode(texture: birdUpTexture)
        player.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        player.runAction(flappyBird)
        player.physicsBody = SKPhysicsBody(circleOfRadius: birdUpTexture.size().height/2)
        player.physicsBody!.dynamic = true
        player.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        player.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue | ColliderType.Score.rawValue
        player.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        player.physicsBody!.affectedByGravity = false
        player.zPosition = 2
        player.physicsBody!.allowsRotation = false
        self.addChild(player)
        
        self.speed = 0
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipes"), userInfo: nil, repeats: true)
    }
    
    // Creates the moving background for the game
    func makeBG(){
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let animatebg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let animatebgCont = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let animatebgForever = SKAction.repeatActionForever(SKAction.sequence([animatebg, animatebgCont]))
        
        for var i: CGFloat = 0; i<3; i++ {
            bg.runAction(animatebgForever)
            
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            bg.zPosition = -1
            movingObjects.addChild(bg)
        }
    }
    
    // creates and destroys the pipes
    func createPipes(){
        let pipeGap = player.size.height * 4
        
        let moveAmount = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffSet = CGFloat(moveAmount) - self.frame.size.height/4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let pipeFromTopTexture = SKTexture(imageNamed: "pipe1.png")
        let pipeFromTop = SKSpriteNode(texture: pipeFromTopTexture)
        pipeFromTop.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeFromTopTexture.size().height/2 + pipeGap/2 + pipeOffSet)
        pipeFromTop.runAction(moveAndRemovePipes)
        
        pipeFromTop.physicsBody = SKPhysicsBody(rectangleOfSize: pipeFromTop.size)
        pipeFromTop.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipeFromTop.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeFromTop.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipeFromTop.physicsBody!.dynamic = false
        pipeFromTop.physicsBody?.affectedByGravity = false
        pipeFromTop.zPosition = 1
        movingObjects.addChild(pipeFromTop)
        
        let pipeFromBottomTexture = SKTexture(imageNamed: "pipe2.png")
        let pipeFromBottom = SKSpriteNode(texture: pipeFromBottomTexture)
        pipeFromBottom.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeFromBottomTexture.size().height/2 - pipeGap/2 + pipeOffSet)
        pipeFromBottom.runAction(moveAndRemovePipes)
        
        pipeFromBottom.physicsBody = SKPhysicsBody(rectangleOfSize: pipeFromTop.size)
        pipeFromBottom.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipeFromBottom.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeFromBottom.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipeFromBottom.physicsBody!.dynamic = false
        pipeFromBottom.physicsBody?.affectedByGravity = false
        pipeFromBottom.zPosition = 1
        movingObjects.addChild(pipeFromBottom)
        
        let throughPipe = SKNode()
        throughPipe.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffSet)
        throughPipe.runAction(moveAndRemovePipes)
        throughPipe.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeFromTop.size.width / 4, pipeGap))
        throughPipe.physicsBody?.dynamic = false
        
        throughPipe.physicsBody!.categoryBitMask = ColliderType.Score.rawValue
        throughPipe.physicsBody!.contactTestBitMask = ColliderType.Player.rawValue
        throughPipe.physicsBody!.collisionBitMask = ColliderType.Score.rawValue
        
        movingObjects.addChild(throughPipe)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //check if player was in between pipes or not -- if not game over
        if contact.bodyA.categoryBitMask == ColliderType.Score.rawValue || contact.bodyB.categoryBitMask == ColliderType.Score.rawValue {
            score++
            scoreLabel.text = String(score)
        } else {
            gameOver = true
            player.physicsBody!.affectedByGravity = false
            self.speed = 0
            self.paused = true
            // wait for user to restart
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over! Tap to play again."
            gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            gameOverLabel.zPosition = 999
            notificationLabels.addChild(gameOverLabel)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        // while gameOver is false the game is playable
        if gameOver == false {
            if gameStarted == false {
                gameStarted = true
                player.physicsBody!.affectedByGravity = true
                self.speed = 1
            }
            
            player.physicsBody!.velocity = CGVectorMake(0,0)
            player.physicsBody?.applyImpulse(CGVectorMake(0,50))
        }else{
            score = 0
            scoreLabel.text = "0"
            player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            player.physicsBody!.velocity = CGVectorMake(0, 0)
            movingObjects.removeAllChildren()
            notificationLabels.removeAllChildren()
            makeBG()
            self.speed = 1
            gameOver = false
            gameStarted = false
            self.paused = false
        }
    }
}
