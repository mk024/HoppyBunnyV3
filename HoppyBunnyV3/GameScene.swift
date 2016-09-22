//
//  GameScene.swift
//  HoppyBunny
//
//  Created by Michael K on 8/23/16.
//  Copyright (c) 2016 Waxy Watermelon. All rights reserved.
//

import SpriteKit


enum GameSceneState {
    case active, gameOver
}

var highScore = HighScore()

class GameScene: SKScene, SKPhysicsContactDelegate {

    /* TODO: implement smaller goal sizes as score increases */
    /* TODO: make high score permanent */
    
    /* Adjust gravity in GameScene.sks, scrollSpeed variable, "if spawnTimer" in update obstacles, "applyImpulse" in touchesBegan(), etc. to tune game play */
    
    var hero: SKSpriteNode!
    
    var scrollLayer: SKNode!
    
    var cloudScrollLayer: SKNode!
    
    var crystalScrollLayer: SKNode!
    
    var sinceTouch : CFTimeInterval = 0
    
    var spawnTimer: CFTimeInterval = 0
    
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    let scrollSpeed: CGFloat = 300
    
    let cloudScrollSpeed: CGFloat = 30
    
    let crystalScrollSpeed: CGFloat = 100
    
    var obstacleLayer: SKNode!
    
    var buttonRestart: MSButtonNode!
    
    var gameState: GameSceneState = .active
    
    var scoreLabel: SKLabelNode!
    
    var points = 0
    
    var highScoreLabel: SKLabelNode!
    
    var highScoreLabelNumber: SKLabelNode!
    

    
    override func didMove(to view: SKView) {
        /* Set up your scene here */
        
        /* Recursive node search for 'hero' (child of referenced node) */
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        /* Set reference to cloud scroll layer node */
        cloudScrollLayer = self.childNode(withName: "cloudScrollLayer")
        
        /* Set reference to crystal scroll layer node */
        crystalScrollLayer = self.childNode(withName: "crystalScrollLayer")
        
        /* Set reference to obstacle layer node */
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set UI connections */
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        
        /* Set reference to score label node */
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            
            /* Grab Reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load game scene */
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            
        }
        
        /* Hide restart button */
        buttonRestart.state = .hidden
        
        /* Reset score label */
        scoreLabel.text = String(points)
        
        /* Set reference to high score label node */
        highScoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        
        /* Set reference to high score label number node */
        highScoreLabelNumber = self.childNode(withName: "highScoreLabelNumber") as! SKLabelNode
        
        /* Hide high score label */
        highScoreLabel.isHidden = true
        
        /* Hide high score label number */
        
        highScoreLabelNumber.isHidden = true
        
        /* Set high score label */
        highScoreLabelNumber.text = String(describing: highScore)

 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        /* Disable touch if game state is not active */
        if gameState != .active { return }
        
        /* Reset velocity, helps improve response against cumulative falling velocity */
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        /* Apply vertical impulse */
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
        
        /* Apply subtle rotation */
        hero.physicsBody?.applyAngularImpulse(1)
        
        /* Reset touch timer */
        sinceTouch = 0
        
        
        
        /* Play SFX */
        let flapSFX = SKAction.playSoundFileNamed("sfx_flap", waitForCompletion: false)
        self.run(flapSFX)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        /* Skip game update if no longer active */
        if gameState != .active { return }
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        /* Apply falling rotation */
        if sinceTouch > 0.1 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        /* Clamp rotation */
        hero.zRotation.clamp(CGFloat(-20).degreesToRadians(),CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(-2, 2)
        
        /* Update last touch timer */
        sinceTouch+=fixedDelta
        
        /* Update spawn timer */
        spawnTimer+=fixedDelta
        
        /* Process world scrolling */
        scrollWorld()
        
        /* Process cloud world scrolling */
        cloudScrollWorld()
        
        /* Process crystal world scrolling */
        crystalScrollWorld()
        
        /* Process obstacles */
        updateObstacles()
    }
 
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint( x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node positon back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
    }
    
    /* Copy of scroll world */
    
    func cloudScrollWorld() {
        /* Scroll World */
        cloudScrollLayer.position.x -= cloudScrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for clouds in cloudScrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let cloudPosition = cloudScrollLayer.convert(clouds.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if cloudPosition.x <= -clouds.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newCloudPosition = CGPoint( x: (self.size.width / 2) + clouds.size.width, y: cloudPosition.y)
                
                /* Convert new node positon back to scroll layer space */
                clouds.position = self.convert(newCloudPosition, to: cloudScrollLayer)
            }
        }
    }
    
    /* Copy of cloud scroll world */
    
    func crystalScrollWorld() {
        /* Scroll World */
        crystalScrollLayer.position.x -= crystalScrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for crystals in crystalScrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let crystalPosition = crystalScrollLayer.convert(crystals.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if crystalPosition.x <= -crystals.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newCrystalPosition = CGPoint( x: (self.size.width / 2) + crystals.size.width, y: crystalPosition.y)
                
                /* Convert new node positon back to scroll layer space */
                crystals.position = self.convert(newCrystalPosition, to: crystalScrollLayer)
            }
        }
    }
    
    func updateObstacles() {
        /* Update obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Check iOS availability for SKReferenceNode */

        
            /* Loop through obstacle layer nodes */
            for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
                /* Get obstacle node position, convert node position to see scene space */
                let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
                /* Check if obstacle has left scene */
                if obstaclePosition.x <= 0 {
                
                    /* Remove obstacle node from obstacle layer */
                    obstacle.removeFromParent()
                }
            }
        
        
        /* Time to add a new obstacle? */
        
        if points < 3 {
            if spawnTimer >= 1.5 {
            
                /* Create a new obstacle reference object using our obstacle resource */
                let resourcePath = Bundle.main.path(forResource: "Obstacle", ofType: "sks")
                let newObstacle =  SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))
                obstacleLayer.addChild(newObstacle)
            
                /* Generate new obstacle, start just outside screen and with a random y value */
                let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
            
                /* Convert new node position to obstacle layer space */
                newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
                
                /* Reset spawn timer */
                spawnTimer = 0
            }
        }

        if points >= 3 && points < 7 {
            if spawnTimer >= 1.0 {
                
                /* Create a new obstacle reference object using our obstacle resource */
                let resourcePath = Bundle.main.path(forResource: "Obstacle", ofType: "sks")
                let newObstacle =  SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))
                obstacleLayer.addChild(newObstacle)
                
                /* Generate new obstacle, start just outside screen and with a random y value */
                let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
                
                /* Convert new node position to obstacle layer space */
                newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
                
                /* Reset spawn timer */
                spawnTimer = 0
            }
        }
        
        if points >= 7 && points < 10 {
            if spawnTimer >= 0.75 {
                
                /* Create a new obstacle reference object using our obstacle resource */
                let resourcePath = Bundle.main.path(forResource: "Obstacle", ofType: "sks")
                let newObstacle =  SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))
                obstacleLayer.addChild(newObstacle)
                
                /* Generate new obstacle, start just outside screen and with a random y value */
                let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
                
                /* Convert new node position to obstacle layer space */
                newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
                
                /* Reset spawn timer */
                spawnTimer = 0
            }
        }
        
        if points >= 11 && points < 20 {
            if spawnTimer >= 0.5 {
                
                /* Create a new obstacle reference object using our obstacle resource */
                let resourcePath = Bundle.main.path(forResource: "Obstacle", ofType: "sks")
                let newObstacle =  SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))
                obstacleLayer.addChild(newObstacle)
                
                /* Generate new obstacle, start just outside screen and with a random y value */
                let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
                
                /* Convert new node position to obstacle layer space */
                newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
                
                /* Reset spawn timer */
                spawnTimer = 0
            }
        }
        
        if points >= 21 {
            if spawnTimer >= 0.4 {
                
                /* Create a new obstacle reference object using our obstacle resource */
                let resourcePath = Bundle.main.path(forResource: "Obstacle", ofType: "sks")
                let newObstacle =  SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))
                obstacleLayer.addChild(newObstacle)
                
                /* Generate new obstacle, start just outside screen and with a random y value */
                let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
                
                /* Convert new node position to obstacle layer space */
                newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
                
                /* Reset spawn timer */
                spawnTimer = 0
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Ensure only called when game running */
        if gameState != .active { return }
        
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Did our hero pass through the 'goal'? */
        if nodeA.name == "goal" || nodeB.name == "goal" {
            
            /* Increment points */
            points += 1
            
            /* Update score label */
            scoreLabel.text = String(points)
            
            /* Play SFX */
            let goalSFX = SKAction.playSoundFileNamed("sfx_goal", waitForCompletion: false)
            self.run(goalSFX)
            
            /* Update high score */
            if points >= highScore.highScoreCount {
                highScore.highScoreCount = points
            }
            
            highScoreLabelNumber.text = String(highScore.highScoreCount)
            
            /* We can return now */
            return
        }
        
        /* Hero touches anything, game over */
        
        /* Change game state to game over */
        gameState = .gameOver
        
        /* Stop any new angular velocity being applied */
        hero.physicsBody?.allowsRotation = false
        
        /* Reset angular velocity */
        hero.physicsBody?.angularVelocity = 0
        
        /* Stop hero flapping animation */
        hero.removeAllActions()
        
        /* Create hero death action */
        let heroDeath = SKAction.run({
            
            /* Put hero face down in the dirt */
            self.hero.zRotation = CGFloat(-90).degreesToRadians()
            /* Stop hero from colliding with anything else */
            self.hero.physicsBody?.collisionBitMask = 0
        })
        
        /* Run action */
        hero.run(heroDeath)
        
        /* Show restart button */
        buttonRestart.state = .active
        
        /* Load the shake scene resource */
        let shakeScene:SKAction = SKAction.init(named: "Shake")!
        
        /* Loop through all nodes */
        for node in self.children {
            
            /* Apply effect each ground node */
            node.run(shakeScene)
        }
        

        
        /* Show high score */
        highScoreLabel.isHidden = false
        highScoreLabelNumber.isHidden = false
    }
}

 
 
 
 
 
 
 
 
 
 
 
 
 
 
