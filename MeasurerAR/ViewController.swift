//
//  ViewController.swift
//  MeasurerAR
//
//  Created by Shubham Mishra on 19/04/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!

    
    var dotArray = [SCNNode]()
    var distanceText = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = SCNDebugOptions.showFeaturePoints
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func addDot(atLocation location: ARRaycastResult) {
        let dot = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.cyan
        dot.materials = [material]
        let dotNode = SCNNode(geometry: dot)
        dotNode.position = .init(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y, location.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotArray.append(dotNode)
    }
    
    func displayDistance() {
        let x1 = dotArray[0].position.x
        let y1 = dotArray[0].position.y
        let z1 = dotArray[0].position.z
        let x2 = dotArray[1].position.x
        let y2 = dotArray[1].position.y
        let z2 = dotArray[1].position.z
        
        let distance = sqrt(pow(x1-x2, 2) + pow(y1-y2, 2) + pow(z1-z2, 2))
        let distanceInMillimeters = distance * 1000
        let distanceString = String(format: "%.2f mm", distanceInMillimeters)
        distanceLabel.text = distanceString
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the center point of the screen
        let centerPoint = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)

        if dotArray.count == 2 {
            return
        }

        guard let query = sceneView.raycastQuery(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .any) else { return }

        let hitTestResult = sceneView.session.raycast(query)

        guard let result = hitTestResult.first else { return }

        addDot(atLocation: result)

        if dotArray.count == 2 {
            displayDistance()
        }
    }

    
    @IBAction func resetTapped(_ sender: UIBarButtonItem) {
        for dot in dotArray {
            dot.removeFromParentNode()
        }
        dotArray.removeAll()
        distanceText.removeFromParentNode()
        
        distanceLabel.text = ""
    }
    
    //    func addPlane(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [material]
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = planeAnchor.center
        planeNode.eulerAngles.x = -.pi/2
        
        node.addChildNode(planeNode)
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

