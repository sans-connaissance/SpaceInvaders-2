//
//  GameScene.swift
//  SpaceInvaders-2
//
//  Created by David Malicke on 8/15/21.
//

import SpriteKit
import GameplayKit
import CoreMotion

//collision detection
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    //the bottom height variable is cool. i think this can be used to do a lot of interesting things in my game.
    let kMinInvaderBottomHeight: Float = -240.0
    var gameEnding: Bool = false
    
    var contentCreated = false
    
    // im not sure this is necessary
    var contactQueue = [SKPhysicsContact]()
    
    var tapQueue = [Int]()
    
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    
    let motionManager = CMMotionManager()
    
    // 1
    var invaderMovementDirection: InvaderMovementDirection = .right
    // 2
    var timeOfLastMove: CFTimeInterval = 0.0
    // 3
    let timePerMove: CFTimeInterval = 1.0
    
    
    enum InvaderMovementDirection {
        case right
        case left
        case downThenRight
        case downThenLeft
        case none
    }
    
    enum InvaderType {
        case a
        case b
        case c
        
        static var size: CGSize {
            return CGSize(width: 24, height: 16)
        }
        
        static var name: String {
            return "invader"
        }
    }
    
    enum BulletType {
      case shipFired
      case invaderFired
    }
    
    
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    override func didMove(to view: SKView) {
        
        // add accelerometer monitor to scene.
        motionManager.startAccelerometerUpdates()
        
                if !self.contentCreated {
                  self.createContent()
                  self.contentCreated = true
                }
        
        setupInvaders()
        setupShip()
        setupHud()
        
        //collision detection
        physicsWorld.contactDelegate = self
        
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
          if touch.tapCount == 1 {
            tapQueue.append(1)
          }
        }
    }
    
    //collision detection
    func didBegin(_ contact: SKPhysicsContact) {
      contactQueue.append(contact)
    }
    
    //collision detection
    //This is interesting!
    func handle(_ contact: SKPhysicsContact) {
      // Ensure you haven't already handled this contact and removed its nodes
      if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
        return
      }
      
      let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
      
      if nodeNames.contains(kShipName) && nodeNames.contains(kInvaderFiredBulletName) {
        // Invader bullet hit a ship
        run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
        
        // 1
        adjustShipHealth(by: -0.334)
        
        if shipHealth <= 0.0 {
          // 2
          contact.bodyA.node!.removeFromParent()
          contact.bodyB.node!.removeFromParent()
        } else {
          // 3
          if let ship = childNode(withName: kShipName) {
            ship.alpha = CGFloat(shipHealth)
            
            if contact.bodyA.node == ship {
              contact.bodyB.node!.removeFromParent()
              
            } else {
              contact.bodyA.node!.removeFromParent()
            }
          }
        }
        
      } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(kShipFiredBulletName) {
        // Ship bullet hit an invader
        run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
        contact.bodyA.node!.removeFromParent()
        contact.bodyB.node!.removeFromParent()
        
        // 4
        adjustScore(by: 100)
      }
    }
    
    func isGameOver() -> Bool {
      // 1
      let invader = childNode(withName: InvaderType.name)
      
      // 2
      var invaderTooLow = false
      
      enumerateChildNodes(withName: InvaderType.name) { node, stop in
        
        if (Float(node.frame.minY) <= self.kMinInvaderBottomHeight)   {
          invaderTooLow = true
          stop.pointee = true
        }
      }
      
      // 3
      let ship = childNode(withName: kShipName)
      
      // 4
      return invader == nil || invaderTooLow || ship == nil
    }

    func endGame() {
      // 1
      if !gameEnding {
        
        gameEnding = true
        
        // 2
        motionManager.stopAccelerometerUpdates()
        
        // 3
        let gameOverScene: GameOverScene = GameOverScene(size: size)
        
        view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
      }
    }
    
    // collision detection
    func processContacts(forUpdate currentTime: CFTimeInterval) {
      for contact in contactQueue {
        handle(contact)
        
        if let index = contactQueue.firstIndex(of: contact) {
          contactQueue.remove(at: index)
        }
      }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if isGameOver() {
          endGame()
        }
        
        processContacts(forUpdate: currentTime)
        processUserTaps(forUpdate: currentTime)
        
        processUserMotion(forUpdate: currentTime)
        // this is where you can make things move
        moveInvaders(forUpdate: currentTime)
        fireInvaderBullets(forUpdate: currentTime)
    }
    
    
        func createContent() {
    
//          let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
//
//          invader.position = CGPoint(x: 0, y: 0)
//
//          self.addChild(invader)
    
          // black space color
            physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
            
            //collision detection
            physicsBody!.categoryBitMask = kSceneEdgeCategory
            
          self.backgroundColor = SKColor.black
        }
    
    // how many different types of moving options can I create?
    // can I create some kind of engine / or set of functions that call
    //  each other in order to drive unique movements at a higher order of the code?
    // what does my movement engine look like?
    func moveInvaders(forUpdate currentTime: CFTimeInterval) {
        // 1
        if currentTime - timeOfLastMove < timePerMove {
            return
        }
        
        // 2
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .none:
                break
            }
            
            // 3
            
        }
        self.timeOfLastMove = currentTime
        self.determineInvaderMovementDirection()
        
    }
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
      // 1
      if let ship = childNode(withName: kShipName) as? SKSpriteNode {
        // 2
        if let data = motionManager.accelerometerData {
          // 3
          if fabs(data.acceleration.x) > 0.2 {
            // 4 How do you move the ship?
            print("Acceleration: \(data.acceleration.x)")
            ship.physicsBody!.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
          }
        }
      }
    }
    
    func determineInvaderMovementDirection() {
        // 1
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        // 2
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            
            switch self.invaderMovementDirection {
            case .right:
                //3
                if node.frame.maxX >= 200 {
                    proposedMovementDirection = .downThenLeft
                    
                    stop.pointee = true
                }
            case .left:
                //4
                if node.frame.minX <= -200 {
                    proposedMovementDirection = .downThenRight
                    
                    stop.pointee = true
                }
                
            case .downThenLeft:
                proposedMovementDirection = .left
                
                stop.pointee = true
                
            case .downThenRight:
                proposedMovementDirection = .right
                
                stop.pointee = true
                
            default:
                break
            }
            
        }
        
        //7
        if proposedMovementDirection != invaderMovementDirection {
            invaderMovementDirection = proposedMovementDirection
        }
    }
    
    
    func loadInvaderTextures(ofType invaderType: InvaderType) -> [SKTexture] {
      
      var prefix: String
      
      switch(invaderType) {
      case .a:
        prefix = "InvaderA"
      case .b:
        prefix = "InvaderB"
      case .c:
        prefix = "InvaderC"
      }
      
      // 1
      return [SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
              SKTexture(imageNamed: String(format: "%@_01.png", prefix))]
    }

    func makeInvader(ofType invaderType: InvaderType) -> SKNode {
      let invaderTextures = loadInvaderTextures(ofType: invaderType)
      
      // 2
      let invader = SKSpriteNode(texture: invaderTextures[0])
      invader.name = InvaderType.name
      
      // 3
      invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
      
      // invaders' bitmasks setup
      invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
      invader.physicsBody!.isDynamic = false
      invader.physicsBody!.categoryBitMask = kInvaderCategory
      invader.physicsBody!.contactTestBitMask = 0x0
      invader.physicsBody!.collisionBitMask = 0x0
      
      return invader
    }
    
    func setupInvaders() {
        // 1
        let baseOrigin = CGPoint(x: -72, y: -24)
        
        for row in 0..<kInvaderRowCount {
            // 2
            var invaderType: InvaderType
            
            if row % 3 == 0 {
                invaderType = .a
            } else if row % 3 == 1 {
                invaderType = .b
            } else {
                invaderType = .c
            }
            
            // 3
            let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y
            
            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
            
            // 4
            for _ in 1..<kInvaderColCount {
                // 5
                let invader = makeInvader(ofType: invaderType)
                invader.position = invaderPosition
                
                addChild(invader)
                
                invaderPosition = CGPoint(
                    x: invaderPosition.x + InvaderType.size.width + kInvaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }
    
    func setupShip() {
        // 1
        let ship = makeShip()
        
        // 2
        ship.position = CGPoint(x: -25, y: -250)
        addChild(ship)
    }
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(imageNamed: "Ship.png")
        ship.name = kShipName
        
        
        // 1
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)

        // 2
        ship.physicsBody!.isDynamic = true

        // 3
        ship.physicsBody!.affectedByGravity = false

        // 4
        ship.physicsBody!.mass = 0.02
        
        // contact detection
        // 1
        ship.physicsBody!.categoryBitMask = kShipCategory
        // 2
        ship.physicsBody!.contactTestBitMask = 0x0
        // 3
        ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
        
        return ship
    }
    
    func setupHud() {
        // 1
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        // 2
        scoreLabel.fontColor = SKColor.green
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        // 3
        //check the other tutorials to see how those labels were added and positioned.
        scoreLabel.position = CGPoint(x:20, y: 250)
        addChild(scoreLabel)
        
        // 4
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        // 5
        healthLabel.fontColor = SKColor.red
        healthLabel.text = String(format: "Health: %.1f%%", shipHealth * 100.0)
        
        
        // 6
        //check the other tutorials to see how those labels were added and positioned.
        healthLabel.position = CGPoint(x:20, y: 225)
        
        addChild(healthLabel)
    }
    
    func adjustScore(by points: Int) {
      score += points
      
      if let score = childNode(withName: kScoreHudName) as? SKLabelNode {
        score.text = String(format: "Score: %04u", self.score)
      }
    }

    func adjustShipHealth(by healthAdjustment: Float) {
      // 1
      shipHealth = max(shipHealth + healthAdjustment, 0)
      
      if let health = childNode(withName: kHealthHudName) as? SKLabelNode {
        health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
      }
    }
    
    func makeBullet(of bulletType: BulletType) -> SKNode {
      var bullet: SKNode
      
      switch bulletType {
      case .shipFired:
        bullet = SKSpriteNode(color: SKColor.green, size: kBulletSize)
        bullet.name = kShipFiredBulletName
        
        //Collesion detection
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody!.isDynamic = true
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
        bullet.physicsBody!.contactTestBitMask = kInvaderCategory
        bullet.physicsBody!.collisionBitMask = 0x0
        
      case .invaderFired:
        bullet = SKSpriteNode(color: SKColor.magenta, size: kBulletSize)
        bullet.name = kInvaderFiredBulletName
        
        //Collision detection
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody!.isDynamic = true
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
        bullet.physicsBody!.contactTestBitMask = kShipCategory
        bullet.physicsBody!.collisionBitMask = 0x0
        break
      }
      
      return bullet
    }
    
    func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
      // 1
      let bulletAction = SKAction.sequence([
        SKAction.move(to: destination, duration: duration),
        SKAction.wait(forDuration: 3.0 / 60.0),
        SKAction.removeFromParent()
        ])
      
      // 2
      let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
      
      // 3
      bullet.run(SKAction.group([bulletAction, soundAction]))
      
      // 4
      addChild(bullet)
    }

    func fireShipBullets() {
      let existingBullet = childNode(withName: kShipFiredBulletName)
      
      // 1
      if existingBullet == nil {
        if let ship = childNode(withName: kShipName) {
            let bullet = makeBullet(of: .shipFired)
          // 2
          bullet.position = CGPoint(
            x: ship.position.x,
            y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
          )
          // 3
          let bulletDestination = CGPoint(
            x: ship.position.x,
            y: frame.size.height + bullet.frame.size.height / 2
          )
          // 4
          fireBullet(
            bullet: bullet,
            toDestination: bulletDestination,
            withDuration: 1.0,
            andSoundFileName: "ShipBullet.wav"
          )
        }
      }
    }
    // can this be changed so that it's a boolean and any time the user taps it turns to true and a bullet is fired.
    // also check in the other book to see how HackingWithSwift manages firing bullets.
    func processUserTaps(forUpdate currentTime: CFTimeInterval) {
      // 1
      for tapCount in tapQueue {
        if tapCount == 1 {
          // 2
          fireShipBullets()
        }
        // 3
        tapQueue.remove(at: 0)
      }
    }
    
    func fireInvaderBullets(forUpdate currentTime: CFTimeInterval) {
      let existingBullet = childNode(withName: kInvaderFiredBulletName)
      
      // 1
      if existingBullet == nil {
        var allInvaders = [SKNode]()
        
        // 2
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
          allInvaders.append(node)
        }
        
        if allInvaders.count > 0 {
          // 3
          let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
          
          let invader = allInvaders[allInvadersIndex]
          
          // 4
          let bullet = makeBullet(of: .invaderFired)
          bullet.position = CGPoint(
            x: invader.position.x,
            y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
          )
          
          // 5
          let bulletDestination = CGPoint(x: invader.position.x, y: -300)
          
          // 6
          fireBullet(
            bullet: bullet,
            toDestination: bulletDestination,
            withDuration: 2.0,
            andSoundFileName: "InvaderBullet.wav"
          )
        }
      }
    }
}
