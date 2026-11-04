import SwiftUI
import SceneKit

/// Geonaut maskotunun gerçek 3B "clay" (kil) hâli — onboarding'de gülümser, göz kırpar, hafifçe süzülür.
/// Parçalar SceneKit ile koddan kurulur (ek dosya/paket yok). `animated` false ise (Hareketi azalt) durağandır.
struct ClayMascotView: UIViewRepresentable {
    var animated: Bool = true

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.isUserInteractionEnabled = false
        view.scene = ClayMascotScene.make(animated: animated)
        view.isPlaying = animated
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {}
}

private enum ClayMascotScene {
    private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor { UIColor(red: r, green: g, blue: b, alpha: 1) }
    private static let green = rgb(0.59, 0.89, 0.76), coral = rgb(1.0, 0.60, 0.49), coralDark = rgb(0.80, 0.35, 0.24)
    private static let gold = rgb(0.94, 0.84, 0.46), goldDark = rgb(0.76, 0.60, 0.10), lilac = rgb(0.74, 0.64, 0.95), ink = rgb(0.13, 0.16, 0.22)

    private static func v(_ x: Double, _ y: Double, _ z: Double) -> SCNVector3 { SCNVector3(Float(x), Float(y), Float(z)) }

    private static func clay(_ color: UIColor) -> SCNMaterial {
        let m = SCNMaterial()
        m.lightingModel = .physicallyBased
        m.diffuse.contents = color
        m.roughness.contents = 0.78
        m.metalness.contents = 0.0
        return m
    }

    private static func ellipsoid(_ radius: CGFloat, _ color: UIColor, scale: SCNVector3 = SCNVector3(1, 1, 1)) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.segmentCount = 64
        geometry.materials = [clay(color)]
        let node = SCNNode(geometry: geometry)
        node.scale = scale
        return node
    }

    /// Küre yüzeyinde (x, y) noktasına, yüzeye dik (dışarı bakan) yerleştirir.
    private static func place(_ node: SCNNode, x: Double, y: Double, lift: Double = 0, on parent: SCNNode) {
        let z = (max(0.0001, 1 - x * x - y * y)).squareRoot()
        let holder = SCNNode()
        holder.position = v(x * (1 + lift), y * (1 + lift), z * (1 + lift))
        holder.look(at: SCNVector3Zero) // -Z merkeze bakar → +Z dışarı
        holder.addChildNode(node)
        parent.addChildNode(holder)
    }

    static func make(animated: Bool) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        // Yumuşak ortam ışığı (kilin yumuşak gölgeleri)
        let envSize = CGSize(width: 512, height: 256)
        scene.lightingEnvironment.contents = UIGraphicsImageRenderer(size: envSize).image { ctx in
            let colors = [rgb(1.0, 0.99, 0.96).cgColor, rgb(0.95, 0.88, 0.80).cgColor, rgb(0.62, 0.58, 0.55).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.5, 1])!
            ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: envSize.height), options: [])
        }
        scene.lightingEnvironment.intensity = 0.5

        let root = SCNNode()
        root.eulerAngles = SCNVector3(0.06, -0.10, 0)
        scene.rootNode.addChildNode(root)

        root.addChildNode(ellipsoid(1, green))                                   // gövde

        let cap = ellipsoid(1, coral, scale: v(0.80, 0.30, 0.62))                // şapka
        cap.position = v(0, 0.80, 0.18)
        cap.eulerAngles = SCNVector3(0.40, 0, 0)
        root.addChildNode(cap)

        let rimGeo = SCNCylinder(radius: 0.16, height: 0.05); rimGeo.materials = [clay(goldDark)]   // madalyon
        let faceGeo = SCNCylinder(radius: 0.12, height: 0.07); faceGeo.materials = [clay(gold)]
        let rim = SCNNode(geometry: rimGeo), face = SCNNode(geometry: faceGeo)
        for node in [rim, face] { node.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) }
        face.position = v(0, 0, 0.012)
        let diamondGeo = SCNBox(width: 0.075, height: 0.075, length: 0.04, chamferRadius: 0.012); diamondGeo.materials = [clay(coralDark)]
        let diamond = SCNNode(geometry: diamondGeo)
        diamond.eulerAngles = SCNVector3(0, 0, Float.pi / 4)
        diamond.position = v(0, 0, 0.045)
        let medal = SCNNode()
        medal.position = v(-0.08, 0.74, 0.80)
        medal.eulerAngles = SCNVector3(-0.45, 0, 0)
        [rim, face, diamond].forEach { medal.addChildNode($0) }
        root.addChildNode(medal)

        place(ellipsoid(1, coral, scale: v(0.17, 0.235, 0.06)), x: -0.48, y: 0.49, lift: 0.005, on: root)   // yanaklar
        place(ellipsoid(1, coral, scale: v(0.21, 0.15, 0.06)), x: 0.58, y: -0.40, lift: 0.005, on: root)

        let eyeL = ellipsoid(1, ink, scale: v(0.105, 0.105, 0.06))                                         // gözler
        let eyeR = ellipsoid(1, ink, scale: v(0.105, 0.105, 0.06))
        place(eyeL, x: -0.30, y: -0.04, lift: 0.003, on: root)
        place(eyeR, x: 0.07, y: -0.04, lift: 0.003, on: root)

        let smile = SCNNode()                                                                              // gülümseme
        smile.position = v(-0.12, -0.38, 0)
        smile.pivot = SCNMatrix4MakeTranslation(-0.12, -0.38, 0)
        let steps = 70
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let x = -0.37 + 0.50 * t
            let y = -0.33 - 0.105 * (1 - pow(2 * t - 1, 2))
            let z = (max(0.0001, 1 - x * x - y * y)).squareRoot()
            let dot = ellipsoid(0.030, ink)
            dot.position = v(x, y, z + 0.004)
            smile.addChildNode(dot)
        }
        root.addChildNode(smile)

        let poleGeo = SCNCylinder(radius: 0.036, height: 0.62); poleGeo.materials = [clay(coralDark)]      // bayrak
        let pole = SCNNode(geometry: poleGeo); pole.position = v(0.80, -0.24, 0.64)
        root.addChildNode(pole)
        let triangle = UIBezierPath()
        triangle.move(to: .zero); triangle.addLine(to: CGPoint(x: 0.42, y: -0.13)); triangle.addLine(to: CGPoint(x: 0, y: -0.26)); triangle.close()
        let flagGeo = SCNShape(path: triangle, extrusionDepth: 0.07); flagGeo.chamferRadius = 0.025; flagGeo.materials = [clay(lilac)]
        let flag = SCNNode(geometry: flagGeo); flag.position = v(0.80, 0.05, 0.605)
        root.addChildNode(flag)

        let key = SCNNode(); key.light = SCNLight(); key.light?.type = .omni; key.light?.intensity = 420
        key.position = v(-3.2, 4.2, 6.5); scene.rootNode.addChildNode(key)
        let rimLight = SCNNode(); rimLight.light = SCNLight(); rimLight.light?.type = .omni; rimLight.light?.intensity = 110
        rimLight.light?.color = rgb(0.75, 0.88, 1.0); rimLight.position = v(4.5, 1.0, -3.0); scene.rootNode.addChildNode(rimLight)
        let camera = SCNNode(); camera.camera = SCNCamera(); camera.camera?.fieldOfView = 24
        camera.position = v(0, 0, 7.15); scene.rootNode.addChildNode(camera)

        if animated {
            // Süzülme + hafif sallanma
            let bob = SCNAction.sequence([.moveBy(x: 0, y: 0.05, z: 0, duration: 1.3), .moveBy(x: 0, y: -0.05, z: 0, duration: 1.3)])
            bob.timingMode = .easeInEaseOut
            root.runAction(.repeatForever(bob))
            let sway = SCNAction.sequence([.rotateBy(x: 0, y: 0.18, z: 0, duration: 1.8), .rotateBy(x: 0, y: -0.18, z: 0, duration: 1.8)])
            sway.timingMode = .easeInEaseOut
            root.runAction(.repeatForever(sway))

            // Göz kırpma (sağ göz) + aynı anda gülümsemenin genişlemesi, ~3 sn'de bir
            let baseEye = eyeR.scale
            let wink = SCNAction.sequence([
                .wait(duration: 2.2),
                .customAction(duration: 0.12) { node, elapsed in
                    let k = Float(min(1, elapsed / 0.12))
                    node.scale = SCNVector3(baseEye.x, baseEye.y * (1 - 0.9 * k), baseEye.z)
                },
                .wait(duration: 0.28),
                .customAction(duration: 0.14) { node, elapsed in
                    let k = Float(min(1, elapsed / 0.14))
                    node.scale = SCNVector3(baseEye.x, baseEye.y * (0.1 + 0.9 * k), baseEye.z)
                }
            ])
            eyeR.runAction(.repeatForever(wink))
            let grin = SCNAction.sequence([
                .wait(duration: 2.2),
                .scale(to: 1.14, duration: 0.14),
                .wait(duration: 0.3),
                .scale(to: 1.0, duration: 0.2)
            ])
            smile.runAction(.repeatForever(grin))
        }
        return scene
    }
}

#Preview {
    ClayMascotView().frame(width: 220, height: 220)
}
