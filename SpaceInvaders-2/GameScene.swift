//
//  GameScene.swift
//  SpaceInvaders-2
//
//  Created by David Malicke on 8/15/21.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    
    var contentCreated = false
    
    var tapQueue = [Int]()
    
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        processUserTaps(forUpdate: currentTime)
        
        processUserMotion(forUpdate: currentTime)
        // this is where you can make things move
        moveInvaders(forUpdate: currentTime)
    }
    
    
        func createContent() {
    
//          let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
//
//          invader.position = CGPoint(x: 0, y: 0)
//
//          self.addChild(invader)
    
          // black space color
            physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
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
    
    
    func makeInvader(ofType invaderType: InvaderType) -> SKNode {
        // 1 This code needs to be changed so that each invader can be controlled seperatly, or at least so that each row of invaders can be controlled independatly of the group.
        var invaderColor: SKColor
        
        switch(invaderType) {
        case .a:
            invaderColor = SKColor.red
        case .b:
            invaderColor = SKColor.green
        case .c:
            invaderColor = SKColor.blue
        }
        
        // 2
        let invader = SKSpriteNode(color: invaderColor, size: InvaderType.size)
        invader.name = InvaderType.name
        
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
        let ship = SKSpriteNode(color: SKColor.green, size: kShipSize)
        ship.name = kShipName
        
        
        // 1
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)

        // 2
        ship.physicsBody!.isDynamic = true

        // 3
        ship.physicsBody!.affectedByGravity = false

        // 4
        ship.physicsBody!.mass = 0.02
        
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
        healthLabel.text = String(format: "Health: %.1f%%", 100.0)
        
        // 6
        //check the other tutorials to see how those labels were added and positioned.
        healthLabel.position = CGPoint(x:20, y: 225)
        
        addChild(healthLabel)
    }
    
    func makeBullet(of bulletType: BulletType) -> SKNode {
      var bullet: SKNode
      
      switch bulletType {
      case .shipFired:
        bullet = SKSpriteNode(color: SKColor.green, size: kBulletSize)
        bullet.name = kShipFiredBulletName
      case .invaderFired:
        bullet = SKSpriteNode(color: SKColor.magenta, size: kBulletSize)
        bullet.name = kInvaderFiredBulletName
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
}
