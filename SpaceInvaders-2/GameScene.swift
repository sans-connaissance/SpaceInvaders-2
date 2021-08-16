//
//  GameScene.swift
//  SpaceInvaders-2
//
//  Created by David Malicke on 8/15/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var contentCreated = false
    
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
    
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    override func didMove(to view: SKView) {
        
//        if !self.contentCreated {
//          self.createContent()
//          self.contentCreated = true
//        }
        
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
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveInvaders(forUpdate: currentTime)
    }
    
    
//    func createContent() {
//
//      let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
//
//      invader.position = CGPoint(x: 0, y: 0)
//
//      self.addChild(invader)
//
//      // black space color
//      self.backgroundColor = SKColor.black
//    }
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
        self.timeOfLastMove = currentTime
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
    
}
