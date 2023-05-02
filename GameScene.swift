import SpriteKit

extension SKShapeNode {
    func fadeOut(withDuration duration: TimeInterval) {
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        run(sequence)
    }
    
    func fadeIn(withDuration duration: TimeInterval) {
        let fadeInAction = SKAction.fadeIn(withDuration: duration)
        let sequence = SKAction.sequence([fadeInAction])
        run(sequence)
    }
}

extension SKLabelNode{
    func fadeOut(withDuration duration: TimeInterval) {
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        run(sequence)
    }
    
    func fadeIn(withDuration duration: TimeInterval) {
        let fadeInAction = SKAction.fadeIn(withDuration: duration)
        let sequence = SKAction.sequence([fadeInAction])
        run(sequence)
    }
}

extension SKSpriteNode{
    func fadeOut(withDuration duration: TimeInterval) {
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        run(sequence)
    }
    
    func fadeIn(withDuration duration: TimeInterval) {
        let fadeInAction = SKAction.fadeIn(withDuration: duration)
        let sequence = SKAction.sequence([fadeInAction])
        run(sequence)
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Screen size
    var minSquare: SKShapeNode!
    var maxSquare: SKShapeNode!
    
    // Main player
    var isSelected = false
    var soul: SKSpriteNode!
    var superiorSoul: SKSpriteNode!
    
    var colorSprite: SKShapeNode!
    var fill: SKShapeNode!
    var scale = 1.0
    var trigger = false
    var button: SKSpriteNode!
    
    var boundary: SKNode?
    var presentationString = 0
    
    var tapSign: SKSpriteNode!
    
    // numTouches
    var numTouches = 0
    var stroke: SKShapeNode!
    
    
    var shapesA = [SKShapeNode]()
    var shapesB = [SKShapeNode]()
    var allSouls = [SKSpriteNode]()

    let gravity = 2.0
    
    var label: SKLabelNode!
    var labelShow = 0
    var instructions: SKLabelNode!
    
    let soulImages = ["soul1", "soul2", "soul3", "soul4", "soul5", "soul6", "soul7", "soul8", "soul9", "soul10"]
    let soulSecImages = ["soul11", "soul12", "soul13", "soul14", "soul15", "soul16", "soul17", "soul18", "soul19", "soul20"]
    var sIndex = 0
    var ssIndex = 0
    
    var blur: SKSpriteNode!
    
    let soundManager = SoundManager()
    var finalMessage = false
    
    enum ZPositions {
        static let otherTexts: CGFloat = 2
        static let background: CGFloat = -1
        static let platform: CGFloat = 1
        static let elements: CGFloat = 3
        static let text: CGFloat = 5
        static let tap: CGFloat = 10
    }
    
    enum PhysicsCategories {
        static let soul: UInt32 = 0x1 << 0 // 2^0
        static let boundary: UInt32  = 0x1 << 1 // 2^1
        static let blues: UInt32 = 0x1 << 2 // 2^2
        static let reds: UInt32 = 0x1 << 3 // 2^3
        static let none: UInt32 = 0x1 << 4
    }
    
    enum Scenes {
        static let logo: Int = 1
        static let instructPlayer: Int = 11
        static let initialPhase: Int = 2
        static let notEnough: Int = 3
        static let changeColor: Int = 4
        static let clickScene: Int = 5
        static let presentationScene: Int = 6
        static let notBlue: Int = 7
        static let notRed: Int = 15
        static let mixColors: Int = 8
        static let finalScene: Int = 9
        static let finalInstructions: Int = 10
        static let desperateScene: Int = 12
        static let narratorTalk: Int = 13
        static let secondClickScene: Int = 14
    }
    
    enum SoulColors {
        static let blue = UIColor(red: 34/255, green: 26/255, blue: 86/255, alpha: 1.0)
        static let red = UIColor(red: 129/255, green: 0, blue: 31/255, alpha: 1.0)
        
    }

    var currentScene = Scenes.logo
    
    
    override func didMove(to view: SKView) {
        
        soundManager.play(sound: .space)
        
        self.backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        configureMinAndMaxSquare()
        configureBoundaries()
        
        landingScene()
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        guard let touch = touches.first else { return }
        
        if nextScene(touch) == false {
            switch currentScene {
            case Scenes.presentationScene:
                changeInstructionPresentation()
                break
            case Scenes.initialPhase:
                handleTouch(touch)
                break
            case Scenes.clickScene:
                tapScene(touch)
                break
            case Scenes.secondClickScene:
                tapScene(touch)
                break
            case Scenes.changeColor:
                changeLabelColorize()
                break
            case Scenes.notBlue:
                changeInstructionBlue()
                break
            case Scenes.notRed:
                changeInstructionRed()
                break
            case Scenes.finalInstructions:
                finalInstructions()
            case Scenes.finalScene:
                handleTouch(touch)
            case Scenes.desperateScene:
                desperateDialog()
            case Scenes.narratorTalk:
                narratorTalk()
            default:
                break
            }
        }
        
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = false
        
        if trigger == true && (currentScene == Scenes.clickScene || currentScene == Scenes.secondClickScene){
            let scaleDown = SKAction.scale(to: fill.xScale/2.0, duration: 3.0)
            fill.run(scaleDown, withKey: "scaleUp")
        }
        
        if (currentScene == Scenes.clickScene || currentScene == Scenes.secondClickScene) && fill.xScale >= 350/20{
            fill.removeAllActions()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        if isSelected {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            let deltaX = location.x - previousLocation.x
            let deltaY = location.y - previousLocation.y
            
            soul.position.x += deltaX
            soul.position.y += deltaY
        }
        
   }
    
    
    func motionBegan(){
        if currentScene == Scenes.mixColors{

            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            superiorSoul.run(fadeOut)
        }
    }
    
    func motionEnded(){
        if currentScene == Scenes.mixColors {
            let wait = SKAction.wait(forDuration: 0.1)
            let remove = SKAction.run { self.superiorSoul.removeAllActions() }
            let s = SKAction.sequence([wait, remove])
            
            superiorSoul.run(s)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Apply random forces to the shapes
        let maxForce: CGFloat = gravity
        
        switch(currentScene){
            
        case Scenes.initialPhase:
            for shape in shapesA {
                let dx = CGFloat.random(in: -maxForce...maxForce)
                let dy = CGFloat.random(in: -maxForce...maxForce)
                let force = CGVector(dx: dx, dy: dy)
                shape.physicsBody?.applyForce(force)
                
            }
            
            for shape in shapesB {
                let dx = CGFloat.random(in: -maxForce...maxForce)
                let dy = CGFloat.random(in: -maxForce...maxForce)
                let force = CGVector(dx: dx, dy: dy)
                shape.physicsBody?.applyForce(force)
            }
            break
        case Scenes.mixColors:
            if superiorSoul.alpha <= 0.05 {
                currentScene = Scenes.finalInstructions
                setInstructions(
                    fontColor: .white,
                    fontName: "Menlo",
                    alpha: 0
                )
                presentationString = 0
                finalInstructions()
            }
            break
        case Scenes.finalScene:
            for soul in allSouls {
                let dx = CGFloat.random(in: -maxForce...maxForce)
                let dy = CGFloat.random(in: -maxForce...maxForce)
                let force = CGVector(dx: dx, dy: dy)
                soul.physicsBody?.applyForce(force)
            }
            
            let total = sIndex + ssIndex
            if (total >= 10) && finalMessage == false {
                finalMessage = true
                finalMessageScene()
                
            }
            break
        default:
            break
        }

        
    }
    
    func finalMessageScene(){
        
        
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.run {
            for child in self.allSouls {
                child.fadeOut(withDuration: 1.0)
            }
            
            self.instructions.fadeOut(withDuration: 1.0)
            self.soul.fadeOut(withDuration: 1.0)
        }
        
        let colorAction = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 1.0)
        
        let colorize = SKAction.run {
            self.run(colorAction)
        }
        let final_message = SKSpriteNode(imageNamed: "final_message")
        final_message.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        final_message.alpha = 0
        final_message.zPosition = 50
        final_message.setScale(0.7)
        let fade_in_message = SKAction.run {
            self.addChild(final_message)
            final_message.fadeIn(withDuration: 1)
        }
        
        let s = SKAction.sequence([fadeOut, wait, colorize, wait, fade_in_message])
        self.run(s)

    }
    
    func changeInstructionPresentation(){
        let wait = SKAction.wait(forDuration: 0.8)
        
        let dialog = ["it was born with two colors", "red and blue"]
        
        if presentationString < dialog.count {
            
            self.view?.isUserInteractionEnabled = false
            let changeText = SKAction.run { self.instructions.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 0.8 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 0.8), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 0.8), increase])
            
            var sIns: SKAction
            if instructions.alpha > 0 {
                sIns = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                sIns = SKAction.sequence([changeText, .fadeIn(withDuration: 0.8), increase])
            }

            instructions.run(sIns){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            playWithSoulScene()
        }
    }
    
    func changeInstructionBlue(){
        
        label.fontName = "Menlo-bold"
        label.fontColor = .white
        
        let wait = SKAction.wait(forDuration: 0.8)
        
        let dialog = ["I AM BLUE!!", "but why am I trembling?", "NO!!!"]
        

        if presentationString < dialog.count {
            
            let changeText = SKAction.run { self.label.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 0.8 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 0.8), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 0.8), increase])
            
            var s: SKAction
            if label.alpha > 0 {
                s = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                s = SKAction.sequence([changeText, .fadeIn(withDuration: 0.8), increase])
            }
            
            centerLabel()
            self.view?.isUserInteractionEnabled = false
            label.run(s){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            
            instructions.text = "tap fast on little soul"
            instructions.fontColor = .black
            instructions.zPosition = 10
            
            label.removeAllActions()
            label.alpha = 0
            // label.fadeOut(withDuration: 1.0)
            
            instructions.removeAllActions()
            instructions.fadeIn(withDuration: 2.0)
            
            //addChild(instructions)
            
            nowRedStroke()
        }
         

    }
    
    func changeInstructionRed(){
        
        label.fontName = "Menlo-bold"
        label.fontColor = .white
        
        let wait = SKAction.wait(forDuration: 0.8)
        
        let dialog = ["I AM RED!!", "but why am I trembling again?", "PLEASE, NO!!!"]
        

        if presentationString < dialog.count {
            
            let changeText = SKAction.run { self.label.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 0.8 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 0.8), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 0.8), increase])
            
            var s: SKAction
            if label.alpha > 0 {
                s = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                s = SKAction.sequence([changeText, .fadeIn(withDuration: 0.8), increase])
            }
            
            centerLabel()
            self.view?.isUserInteractionEnabled = false
            label.run(s){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            stopStroke()
        }
         

    }
    
    func nowRedStroke(){
        
        currentScene = Scenes.secondClickScene
        let wait = SKAction.wait(forDuration: 0.7)
        let scaleDown = SKAction.scale(to: 0, duration: 0.7)
        let r = SKAction.run {
            self.fill.removeFromParent()
            self.label.text = "maybe red?"
            self.label.alpha = 1
            self.label.fontColor = .black
            
            self.centerLabel()
        }
        let c = SKAction.run {
          
            self.fill = SKShapeNode(circleOfRadius: 150)
            self.fill.setScale(0.2)
            self.fill.fillColor = SoulColors.red
            
            self.stroke.addChild(self.fill)
            self.label.alpha = 0
        }
        
        let s = SKAction.sequence([scaleDown, wait, r, c])
        fill.run(s)
        
    }
    
    func stopStroke(){
        stroke.removeAllActions()
        let scaleDown = SKAction.scale(to: 0, duration: 1.0)
        //stroke.removeFromParent()
        
        soul.removeFromParent()
        

        let colorAction = SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 1.0)
        self.run(colorAction)
        
        let changeScene = SKAction.run {
            self.desperateDialog()
        }
        
        
        let s = SKAction.sequence([scaleDown, changeScene])
        // fill.run(scaleDown)
        
        currentScene = Scenes.desperateScene
        presentationString = 0
        
        fill.run(s)
        
        
    }
    
    // Diálogo de quando a little soul já está sem cor
    func desperateDialog(){

        label.alpha = 0
        label.fontName = "Menlo"
        label.fontColor = .black
        
        let wait = SKAction.wait(forDuration: 0.8)
        let dialog = ["So...", "guess I should be alone", "I'm nothing"]
        

        if presentationString < dialog.count {
            
            let changeText = SKAction.run { self.label.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 1.0 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 1.0), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 1.0), increase])
            
            var s: SKAction
            if label.alpha > 0 {
                s = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                s = SKAction.sequence([changeText, .fadeIn(withDuration: 1.0), increase])
            }
            
            centerLabel()
            self.view?.isUserInteractionEnabled = false
            label.run(s){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            presentationString = 0
            instructions.alpha = 0
            instructions.fontColor = .white
            currentScene = Scenes.narratorTalk
            narratorTalk()
        }
        
    }
    
    func narratorTalk(){
        let wait = SKAction.wait(forDuration: 0.8)
        
        let dialog = ["but little soul", "have you looked at yourself?"]
        
        if presentationString < dialog.count {
            
            self.view?.isUserInteractionEnabled = false
            let changeText = SKAction.run { self.instructions.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 0.8 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 0.8), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 0.8), increase])
            
            var sIns: SKAction
            if instructions.alpha > 0 {
                sIns = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                sIns = SKAction.sequence([changeText, .fadeIn(withDuration: 0.8), increase])
            }

            instructions.run(sIns){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            stroke.removeFromParent()
            mixColors()
        }
    }
    
    // This is your true color little soul
    func finalInstructions(){
        
        let wait = SKAction.wait(forDuration: 0.8)
        
        let dialog = ["see little soul?", "this is your true self"]
        
        if presentationString < dialog.count {
            
            self.view?.isUserInteractionEnabled = false
            let changeText = SKAction.run { self.instructions.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 0.8 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 0.8), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 0.8), increase])
            
            var sIns: SKAction
            if instructions.alpha > 0 {
                sIns = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                sIns = SKAction.sequence([changeText, .fadeIn(withDuration: 0.8), increase])
            }

            instructions.run(sIns){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            let wait = SKAction.wait(forDuration: 1.0)
            currentScene = Scenes.finalScene
            let f = SKAction.run {
                self.finalInteraction()
            }
            let s = SKAction.sequence([.fadeOut(withDuration: 1.0), wait, f])
            
            soul.run(s)
            
        }
        
    }
    
    // Changing balls
    func finalInteraction(){
        
        removeAllChildren()
        
        currentScene = Scenes.finalScene
        
        instructions = SKLabelNode(text: "")
        instructions.text = "drag little soul to its friends"
        
        setInstructions(
            fontColor: .white,
            fontName: "Menlo",
            alpha: 1
        )
        
        addChild(instructions)
        
        soul = SKSpriteNode(imageNamed: "true_soul")
        soul.size.width = 46
        soul.size.height = 46
        soul.position = CGPoint(x: frame.midX - soul.frame.midX, y: frame.midY - soul.frame.midX)
        soul.zPosition = ZPositions.elements
        
        soul.physicsBody = SKPhysicsBody(circleOfRadius: soul.size.width/2.0)

        soul.physicsBody?.affectedByGravity = false
        soul.physicsBody?.isDynamic = true

        soul.physicsBody?.categoryBitMask = PhysicsCategories.soul
        soul.physicsBody?.collisionBitMask = PhysicsCategories.boundary
        soul.physicsBody?.contactTestBitMask = PhysicsCategories.blues | PhysicsCategories.reds
        
        addChild(soul)
        
        var minX = -size.width * 3 / 8.0
        var maxX = -size.width  / 8.0
        
        let maxY = self.size.height / 10.0
        let minY = -maxY
        
        let maxInitialForce: CGFloat = gravity
        
        // generates shapes
        for _ in 0..<10 {
            let blueSoul = SKSpriteNode(imageNamed: "blue")
            
            blueSoul.size.width = 46
            blueSoul.size.height = 46
            
            let x = CGFloat.random(in: minX...maxX)
            let y = CGFloat.random(in: minY...maxY)
                        
            blueSoul.position = CGPoint(x: x, y: y)
            blueSoul.physicsBody = SKPhysicsBody(circleOfRadius: 23)
            
            
            let dx = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let dy = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let initialForce = CGVector(dx: dx, dy: dy)
            blueSoul.physicsBody?.applyForce(initialForce)
            blueSoul.physicsBody?.categoryBitMask = PhysicsCategories.blues
            
            addChild(blueSoul)
            
            allSouls.append(blueSoul)
        }
        
        minX = size.width / 8.0
        maxX = size.width * 3 / 8.0
        
        for _ in 0..<10 {
            let redSoul = SKSpriteNode(imageNamed: "red")
            
            redSoul.size.width = 46
            redSoul.size.height = 46
            
            let x = CGFloat.random(in: minX...maxX)
            let y = CGFloat.random(in: minY...maxY)
            
            redSoul.position = CGPoint(x: x, y: y)
            redSoul.physicsBody = SKPhysicsBody(circleOfRadius: 23)
            
            
            let dx = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let dy = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let initialForce = CGVector(dx: dx, dy: dy)
            redSoul.physicsBody?.applyForce(initialForce)
            redSoul.physicsBody?.categoryBitMask = PhysicsCategories.reds
            
            addChild(redSoul)
            allSouls.append(redSoul)
        }
        
    }
    
    func mixColors(){
        
        removeAllChildren()
        currentScene = Scenes.mixColors
        
        soul = SKSpriteNode(imageNamed: "true_soul")
        soul.size.width = 500
        soul.size.height = 500
        soul.position = CGPoint(x: frame.midX - soul.frame.midX, y: frame.midY - soul.frame.midX)
        soul.zPosition = ZPositions.elements
        soul.fadeIn(withDuration: 1.0)
        
        superiorSoul = SKSpriteNode(imageNamed: "bolin")
        superiorSoul.size.width = 500
        superiorSoul.size.height = 500
        superiorSoul.position = CGPoint(x: frame.midX - soul.frame.midX, y: frame.midY - soul.frame.midX)
        superiorSoul.zPosition = ZPositions.elements + 1
        superiorSoul.fadeIn(withDuration: 1.0)
        
        addChild(soul)
        addChild(superiorSoul)
        
        instructions = SKLabelNode(text: "shake little soul with your device")
        setInstructions(
            fontColor: .white,
            fontName: "Menlo",
            alpha: 1
        )
        addChild(instructions)
        // superiorSoul.fadeOut(withDuration: 6.0)
        // botar 2 childs
        // a soul
        // a cor por trás
    }
    
    func changeLabelColorize(){
        let wait = SKAction.wait(forDuration: 0.8)
    
        let dialog = ["I'm not enough", "I don't fit at all", "maybe just one?"]
        
        if presentationString < dialog.count {
            
            let changeText = SKAction.run { self.label.text = dialog[self.presentationString] }
            let increase = SKAction.run { self.presentationString+=1; self.appearTap(); }
            let fadeOut = SKAction.run { self.tapSign.fadeOut(withDuration: 0.8 )}
            let fadeOutGroup = SKAction.group([.fadeOut(withDuration: 0.8), fadeOut])
            let fadeInGroup = SKAction.group([.fadeIn(withDuration: 0.8), increase])
            
            var s: SKAction
            if label.alpha > 0 {
                s = SKAction.sequence([fadeOutGroup, wait, changeText, fadeInGroup])
            } else {
                s = SKAction.sequence([changeText, .fadeIn(withDuration: 0.8), increase])
            }
            
            centerLabel()
            self.view?.isUserInteractionEnabled = false
            label.run(s){
                self.view?.isUserInteractionEnabled = true
            }
        } else {
            fourthScene()
        }
        
        
    }
    
    func centerLabel(){
        label.numberOfLines = 10
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: frame.midX - label.frame.midX, y: frame.midY -  label.frame.midX)
        label.lineBreakMode = .byCharWrapping
        label.preferredMaxLayoutWidth = 400
        
    }
    
    func buttonPress(_ touch: UITouch){
        
        let location = touch.location(in: self)
        
        if button.contains(location){
            let buttonPressed = SKSpriteNode(imageNamed: "start_pressed")
            //buttonPressed.setScale(0.5)
            buttonPressed.alpha = 0
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            
            let buttonAction = SKAction.run {
                buttonPressed.run(fadeIn)
                self.button.addChild(buttonPressed)
            }
            
            let changeScene = SKAction.run {
                self.instructPlayer()
            }
            let wait = SKAction.wait(forDuration: 1.2)
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let childrenFade = SKAction.run {
                for child in self.children{
                    child.run(fadeOut)
                }
            }
            
            self.view?.isUserInteractionEnabled = false
            let s = SKAction.sequence([buttonAction, wait, childrenFade, wait, changeScene])
            button.run(s){
                self.view?.isUserInteractionEnabled = true
            }
        }
    }
    
    func nextScene(_ touch: UITouch) -> Bool{
        switch currentScene{
        case Scenes.instructPlayer:
            soulPresentation()
            break
        case Scenes.logo:
            buttonPress(touch)
            break
        default:
            return false
        }
        
        return true
    }
    
    func landingScene(){
        
        self.backgroundColor = .black
        let landing = SKSpriteNode(imageNamed: "landing")
        landing.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        landing.setScale(0.3)
        
        button = SKSpriteNode(imageNamed: "start")
        button.position = CGPoint(x: frame.midX + (530*3/5)/2, y: frame.midY - (431*3/5)/2)
        button.setScale(0.3)
        
        addChild(landing)
        addChild(button)
        
    }
    
    func instructPlayer(){
        
        removeAllChildren()
        currentScene = Scenes.instructPlayer
        
        self.backgroundColor = .black
        let landing = SKSpriteNode(imageNamed: "dialog")
        landing.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        landing.setScale(0.4)
        
        addChild(landing)
        
        setTapSign()
        appearTap()
        
    }
    
    func setTapSign(){
        tapSign = SKSpriteNode(imageNamed: "loading")
        tapSign.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - 50)
        tapSign.size.width = 40
        tapSign.size.height = 40
        tapSign.alpha = 0
        tapSign.zPosition = ZPositions.tap
        
        addChild(tapSign)
    }
    
    func appearTap(){
        // let wait = SKAction.wait(forDuration: 0.8)
        let s = SKAction.sequence([.fadeIn(withDuration: 0.2)])
        
        if !children.contains(tapSign){
            setTapSign()
        }
        
        tapSign.run(s)
    }
    
    func setInstructions(fontColor: UIColor, fontName: String, alpha: CGFloat){
        instructions.position = CGPoint(x: frame.midX, y: frame.minY + 100.0)
        instructions.fontColor = fontColor
        instructions.fontName = fontName
        instructions.alpha = alpha
    }
    
    func soulPresentation(){
        
        currentScene = Scenes.presentationScene
        
        removeAllChildren()
        
        instructions = SKLabelNode(text: "this is little soul")
        
        setInstructions(
            fontColor: .white,
            fontName: "Menlo",
            alpha: 0
        )
        
        
        self.view?.isUserInteractionEnabled = false
    
        instructions.run(.fadeIn(withDuration: 1.0)){
            self.view?.isUserInteractionEnabled = true
        }
        
        addChild(instructions)
        appearTap()
        
        configureMainSoul()
        blur = SKSpriteNode(imageNamed: "soul_blur")
        blur.zPosition = ZPositions.elements - 1
        blur.size.width = 160
        blur.size.height = 160
        blur.position = CGPoint(x: frame.midX - blur.frame.midX, y: frame.midY -  blur.frame.midX)
        
        // create the scaling actions
        let scaleUpAction = SKAction.scale(to: 1.5, duration: 2)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 2)

        // create the sequence of actions that will be run in a loop
        let scaleSequence = SKAction.sequence([scaleUpAction, scaleDownAction])

        // create a repeating action that runs the scale sequence forever
        let repeatAction = SKAction.repeatForever(scaleSequence)
        
        blur.run(repeatAction)
        
        addChild(blur)
        
        
    }
    
    func playWithSoulScene(){
        
        blur.removeFromParent()
        tapSign.removeFromParent()
        
        currentScene = Scenes.initialPhase
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let wait = SKAction.wait(forDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let changeText = SKAction.run {
            self.instructions.text = "drag little soul slowly to it's friends"
        }
        
        let s = SKAction.sequence([fadeOut, wait, changeText, fadeIn])
        instructions.run(s)
        
        configureSouls()
        
    }
    
    // Contact notification
    func didBegin(_ contact: SKPhysicsContact) {
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        
        if currentScene == Scenes.initialPhase{
            
            if contact.bodyA.categoryBitMask == PhysicsCategories.soul &&
                contact.bodyB.categoryBitMask == PhysicsCategories.reds && labelShow != 1{
                
                if instructions.alpha > 0 {
                    instructions.fadeOut(withDuration: 1.0)
                }
                
                let sequence = SKAction.sequence([fadeOut, SKAction.removeFromParent()])
                label?.run(sequence)
                
                label = SKLabelNode(text: "you're not red enough")
                label.fontColor = .white
                label.fontSize = 36
                label.zPosition = ZPositions.text
                label.fontName = "Menlo"
                
                centerLabel()
                label.alpha = 0
                addChild(label)
                
                let fadeIn = SKAction.fadeIn(withDuration: 1.0)
                label.run(fadeIn)
                
                labelShow = 1
                numTouches+=1
                
            } else if contact.bodyA.categoryBitMask == PhysicsCategories.soul &&
                        contact.bodyB.categoryBitMask == PhysicsCategories.blues && labelShow != 2 {
                
                let sequence = SKAction.sequence([fadeOut, SKAction.removeFromParent()])
                
                if instructions.alpha > 0 {
                    instructions.fadeOut(withDuration: 1.0)
                }
                
                label?.run(sequence)
                label = SKLabelNode(text: "you're not blue enough")
                label.fontColor = .white
                label.fontSize = 36
                label.zPosition = ZPositions.text
                label.fontName = "Menlo"
                
                label.alpha = 0
                addChild(label)
                
                centerLabel()
                
                let fadeIn = SKAction.fadeIn(withDuration: 1.0)
                label.run(fadeIn)
                
                labelShow = 2
                numTouches+=1
            }
            
            if numTouches > 2 {
                focusOnSoul()
            }
        } else if currentScene == Scenes.finalScene {
            
            if (contact.bodyA.categoryBitMask == PhysicsCategories.soul &&
                contact.bodyB.categoryBitMask == PhysicsCategories.reds)
            {
                
                if let redSoul = contact.bodyB.node as? SKSpriteNode {
                    // Get a reference to the SKSpriteNode object representing the enemy
                    // Change the sprite's image property as needed
                    redSoul.texture = SKTexture(imageNamed: soulImages[sIndex])
                    redSoul.physicsBody?.categoryBitMask = PhysicsCategories.none
                    sIndex+=1
                }
                            
                
            } else if ((contact.bodyA.categoryBitMask == PhysicsCategories.reds &&
                        contact.bodyB.categoryBitMask == PhysicsCategories.soul)){
                
                if let redSoul = contact.bodyA.node as? SKSpriteNode {
              
                    redSoul.texture = SKTexture(imageNamed: soulImages[sIndex])
                    redSoul.physicsBody?.categoryBitMask = PhysicsCategories.none
                    sIndex+=1
                }
            } else if (contact.bodyA.categoryBitMask == PhysicsCategories.soul &&
                       contact.bodyB.categoryBitMask == PhysicsCategories.blues){
                
                if let blueSoul = contact.bodyB.node as? SKSpriteNode {
                    blueSoul.texture = SKTexture(imageNamed: soulSecImages[ssIndex])
                    blueSoul.physicsBody?.categoryBitMask = PhysicsCategories.none
                    ssIndex+=1
                }
                
            } else if (contact.bodyA.categoryBitMask == PhysicsCategories.blues &&
                       contact.bodyB.categoryBitMask == PhysicsCategories.soul){
                
                if let blueSoul = contact.bodyA.node as? SKSpriteNode {
                    blueSoul.texture = SKTexture(imageNamed: soulSecImages[ssIndex])
                    blueSoul.physicsBody?.categoryBitMask = PhysicsCategories.none
                    ssIndex+=1
                }
                
            

                
                            
                
            }
            
        }
        
    }
    
    func focusOnSoul(){
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let sequence = SKAction.sequence([fadeOut, SKAction.removeFromParent()])
        label?.run(sequence)
        
        
        label = SKLabelNode(text: "not enough")
        label.fontName = "Menlo"
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        label.fontColor = .white
        label.fontSize = 36
        label.zPosition = ZPositions.text
        
        label.alpha = 0
        centerLabel()
        addChild(label)
        
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        
        self.view?.isUserInteractionEnabled = false
        label.run(fadeIn){
            self.view?.isUserInteractionEnabled = true
        }
        
        labelShow = 2
        
        for shape in shapesA{
            //shape.fadeOut(withDuration: 1.0)
            shape.removeFromParent()
        }
        
        for shape in shapesB{
            //shape.fadeOut(withDuration: 1.0)
            shape.removeFromParent()
        }
        
        //notEnoughAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.notEnoughAnimation()
        }

        
    }
    
    func notEnoughAnimation(){
        
        self.currentScene = Scenes.notEnough
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            // Create the animation
            
            self.soul.physicsBody = SKPhysicsBody(circleOfRadius: self.soul.size.width / 2.0)

            // Ajusta gravidade
            self.soul.physicsBody?.affectedByGravity = false
            self.soul.physicsBody?.isDynamic = false
            
            self.label.fontColor = .black
            
            self.colorSprite = SKShapeNode(circleOfRadius: self.soul.size.width / 2.0)
            self.colorSprite.fillColor = .white
            self.soul.addChild(self.colorSprite)
            
            
            // Screen turns white animation
            let scaleUp = SKAction.scale(to: 50.0, duration: 3.0)
            let backgroundColorChange = SKAction.run {
                
                let colorAction = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 3.0)
                self.run(colorAction)
            }
            let changeScene = SKAction.run{
                self.thirdScene()
            }
            let sequence = SKAction.sequence([scaleUp, backgroundColorChange, changeScene])
            self.soul.run(sequence)
            
            
        }
        
    }
    
    func thirdScene(){
        
        // Reset presentation string
        presentationString = 0
        
        // Set scene
        currentScene = Scenes.changeColor
        
        // Add whole stroke
        stroke = SKShapeNode(circleOfRadius: 350)
        stroke.fillColor = .white
        stroke.strokeColor = .black
        stroke.position = CGPoint(x: frame.midX - stroke.frame.midX, y: frame.midY - stroke.frame.midX)
        stroke.zPosition = ZPositions.elements
        stroke.alpha = 0
        stroke.fadeIn(withDuration: 1.0)
        
        addChild(stroke)
        appearTap()
        
    }
    
    func fourthScene(){
        
        currentScene = Scenes.clickScene
        tapSign.alpha = 0
        
        instructions.text = "tap fast on little soul"
        instructions.fontColor = .black
        instructions.zPosition = 10
        
        label.removeAllActions()
        label.alpha = 0
        // label.fadeOut(withDuration: 1.0)
        
        instructions.removeAllActions()
        instructions.fadeIn(withDuration: 2.0)
        
        addChild(instructions)
        
        fill = SKShapeNode(circleOfRadius: 150)
        fill.setScale(0.2)
        
        fill.fillColor = SoulColors.blue
        
        stroke.addChild(fill)
        
    }


    // Ao clicar, movemos a bolinha em direção ao dedo horizontalmente.
    func handleTouch(_ touch: UITouch) {
        
        let location = touch.location(in: self)
   
        if soul.contains(location){
            isSelected = true
        }
    }
    
    func tapScene(_ touch: UITouch){
        
        let location = touch.location(in: self)
        if fill.contains(location){
            instructions.alpha = 0
            if fill.xScale <= 350/150{
                trigger = true
                let scaleUp = SKAction.scale(to: fill.xScale + 1.0, duration: 0.1)
                fill.run(scaleUp, withKey: "scaleUp")
            } else {
                trigger = false
                tremble()
            }
            
        }
    }
    
    func tremble(){
        
        presentationString = 0
        
        
        fill.removeAllActions()
        let amplitudeX: CGFloat = 10.0, amplitudeY: CGFloat = 6.0, numberOfShakes = 3, durationOfShake = 0.1
        let nodePosition = stroke.position
        let moveRight = SKAction.moveBy(x: amplitudeX, y: 0, duration: durationOfShake/2), moveLeft = moveRight.reversed()
        let moveUp = SKAction.moveBy(x: 0, y: amplitudeY, duration: durationOfShake/2), moveDown = moveUp.reversed()
        let group = SKAction.group([SKAction.repeat(SKAction.sequence([moveRight, moveLeft]), count: numberOfShakes), SKAction.repeat(SKAction.sequence([moveUp, moveDown]), count: numberOfShakes)])
        let moveBack = SKAction.move(to: nodePosition, duration: 0.2)
        let repeatAction = SKAction.repeatForever(SKAction.sequence([group, moveBack]))
        fill.run(repeatAction)
        
        if currentScene == Scenes.clickScene {
            currentScene = Scenes.notBlue
            changeInstructionBlue()
        } else if currentScene == Scenes.secondClickScene {
            currentScene = Scenes.notRed
            changeInstructionRed()
        }
        
        
    }
    
    // Change sizes when window is resized or rotated
    func configureMinAndMaxSquare() {
        let minSide = min(size.height, size.width)
        let maxSide = max(size.height, size.width)

        minSquare = SKShapeNode(rectOf: CGSize(width: minSide, height: minSide))
        minSquare.strokeColor = .clear // Mude o .clear para .blue se quiser ver o quadrado mínimo

        maxSquare = SKShapeNode(rectOf: CGSize(width: maxSide, height: maxSide))
        maxSquare.strokeColor = .clear // Mude o .clear para .red se quiser ver o quadrado máximo

        // Adiciona os quadrados na cena
        addChild(minSquare)
        addChild(maxSquare)
    }
    
    
    // Configure main Soul
    func configureMainSoul() {
        
        soul = SKSpriteNode(imageNamed: "bolin")
        soul.size.width = 46
        soul.size.height = 46
        soul.position = CGPoint(x: frame.midX - soul.frame.midX, y: frame.midY - soul.frame.midX)
        soul.zPosition = ZPositions.elements
        
        setPhysicsBody(soul: soul)
        
        addChild(soul)
    }

    
    // Cria o limite da tela. Por padrão, a posição é (0, 0)
    func configureBoundaries(at position: CGPoint = .zero) {
        // Cria um limite de tela que colide com a bolinha
        let newBoundary = SKNode()
        newBoundary.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        newBoundary.physicsBody?.categoryBitMask = PhysicsCategories.boundary
        //newBoundary.physicsBody?.collisionBitMask = PhysicsCategories.soul | PhysicsCategories.blues | PhysicsCategories.reds
        newBoundary.position = position
        // newBoundary.physicsBody?.isDynamic = false

        // Adiciona o limite criado a cena e muda a referência da antiga pra nova
        addChild(newBoundary)
        boundary = newBoundary
    }
    
    func setPhysicsBody(soul: SKSpriteNode){
        // Configura a física da bolinha
        soul.physicsBody = SKPhysicsBody(circleOfRadius: soul.size.width * 2)

        // Sofre força da gravidade? Se move por colisões?
        soul.physicsBody?.affectedByGravity = false
        soul.physicsBody?.isDynamic = true
//
//        // O quanto quica de 0.0 a 1.0?
//        lightBall.physicsBody?.restitution = 0.75
//
//        // Qual a categoria física?
        soul.physicsBody?.categoryBitMask = PhysicsCategories.soul
//
//        // Com qual ou quais objetos colide? Com qual ou quais faz contato? (contato é notificado)
        soul.physicsBody?.collisionBitMask = PhysicsCategories.boundary
        soul.physicsBody?.contactTestBitMask = PhysicsCategories.blues | PhysicsCategories.reds
//
//
    }
    
    func configureSouls(){
        
        // soul.position = CGPoint(x: frame.midX - soul.frame.midX, y: frame.midY - soul.frame.midX)
        
        var minX = -size.width * 3 / 8.0
        var maxX = -size.width  / 8.0
        
        var maxY = self.size.height / 10.0
        var minY = -maxY
        
        // generates shapes
        for _ in 0..<10 {
            let shape = SKShapeNode(circleOfRadius: 23)
            
            let x = CGFloat.random(in: minX...maxX)
            let y = CGFloat.random(in: minY...maxY)
                        
            shape.position = CGPoint(x: x, y: y)
            shape.fillColor = SoulColors.blue
            shape.strokeColor = .clear
            shape.physicsBody = SKPhysicsBody(circleOfRadius: 23)
            addChild(shape)
            shapesA.append(shape)
        }
        
        // Apply random initial forces to the shapes
        let maxInitialForce: CGFloat = gravity
        for shape in shapesA {
            let dx = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let dy = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let initialForce = CGVector(dx: dx, dy: dy)
            shape.physicsBody?.applyForce(initialForce)
            shape.physicsBody?.categoryBitMask = PhysicsCategories.blues
        }
        
        
        minX = size.width / 8.0
        maxX = size.width * 3 / 8.0
        
        maxY = self.size.height / 10.0
        minY = -maxY
        
        for _ in 0..<10 {
            let shape = SKShapeNode(circleOfRadius: 23)
            
            let x = CGFloat.random(in: minX...maxX)
            let y = CGFloat.random(in: minY...maxY)
            
            shape.position = CGPoint(x: x, y: y)
            shape.fillColor = SoulColors.red
            shape.strokeColor = .clear
            shape.physicsBody = SKPhysicsBody(circleOfRadius: 23)
            addChild(shape)
            shapesB.append(shape)
        }
        
        
        for shape in shapesB {
            let dx = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let dy = CGFloat.random(in: -maxInitialForce...maxInitialForce)
            let initialForce = CGVector(dx: dx, dy: dy)
            shape.physicsBody?.applyForce(initialForce)
            shape.physicsBody?.categoryBitMask = PhysicsCategories.reds
        }
    }
}
