//
//  ARView.swift
//  ARDemoNFT
//
//  Created by Edgar Borovik on 14/04/2022.
//

import ARKit
import SwiftUI

final class ARView: UIViewController {
    private lazy var recognizer: UITapGestureRecognizer = .init(target: self, action: #selector(onTap))
    private lazy var imageFetcher: NFTImageFetcher = .init()
    private var nftNode: SCNNode = .init()
    private var isImageFetching = false
    private var arView: ARSCNView {
        view as? ARSCNView ?? ARSCNView(frame: .zero)
    }

    // MARK: LifeCycle

    override func loadView() {
        view = ARSCNView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.scene = SCNScene()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nftNode = SCNNode(geometry: SCNPlane(width: 0.5, height: 0.5))

        nftNode.position = SCNVector3(0.1, 0.1, -1)
        nftNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "nft")
        arView.scene.rootNode.addChildNode(nftNode)
        view.addGestureRecognizer(recognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        arView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    // MARK: Handlers

    @objc
    private func onTap() {
        guard !isImageFetching else {
            return
        }
        isImageFetching = true
        imageFetcher.fetchRandom { [weak self] image in
            defer { self?.isImageFetching = false }
            guard let image = image else {
                return
            }
            self?.nftNode.geometry?.firstMaterial?.diffuse.contents = image
        }
    }
}

// MARK: - ARSCNViewDelegate

extension ARView: ARSCNViewDelegate {
    func sessionWasInterrupted(_ session: ARSession) {}

    func sessionInterruptionEnded(_ session: ARSession) {}

    func session(_ session: ARSession, didFailWithError error: Error) {}

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}
}

// MARK: - ARViewIndicator

struct ARViewIndicator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARView {
        ARView()
    }

    func updateUIViewController(_ uiViewController: ARView, context: UIViewControllerRepresentableContext<ARViewIndicator>) {}
}
