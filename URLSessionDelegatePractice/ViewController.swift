//
//  ViewController.swift
//  URLSessionDelegatePractice
//
//  Created by 조규연 on 7/1/24.
//

import UIKit
import SnapKit

final class ViewController: UIViewController {
    enum Nasa: String, CaseIterable {
        
        static let baseURL = "https://apod.nasa.gov/apod/image/"
        
        case one = "2308/sombrero_spitzer_3000.jpg"
        case two = "2212/NGC1365-CDK24-CDK17.jpg"
        case three = "2307/M64Hubble.jpg"
        case four = "2306/BeyondEarth_Unknown_3000.jpg"
        case five = "2307/NGC6559_Block_1311.jpg"
        case six = "2304/OlympusMons_MarsExpress_6000.jpg"
        case seven = "2305/pia23122c-16.jpg"
        case eight = "2308/SunMonster_Wenz_960.jpg"
        case nine = "2307/AldrinVisor_Apollo11_4096.jpg"
         
        static var photo: URL {
            return URL(string: Nasa.baseURL + Nasa.allCases.randomElement()!.rawValue)!
        }
    }
    
    let nasaImageView = UIImageView()
    let progressLabel = UILabel()
    let requestButton = UIButton()
    
    var total: Double = 0
    var buffer: Data? {
        didSet {
            let result = Double(buffer?.count ?? 0) / total
            progressLabel.text = "\(result * 100) / 100"
        }
    }
    
    var session: URLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureHierachy()
        configureLayout()
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.finishTasksAndInvalidate()
    }
    
}

private extension ViewController {
    func configureHierachy() {
        self.view.addSubview(nasaImageView)
        self.view.addSubview(progressLabel)
        self.view.addSubview(requestButton)
    }
    
    func configureLayout() {
        requestButton.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(requestButton.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
        nasaImageView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(progressLabel.snp.bottom).offset(20)
        }
    }
    
    func configureView() {
        requestButton.backgroundColor = .red
        progressLabel.backgroundColor = .blue
        nasaImageView.backgroundColor = .darkGray
        
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
    }
    
    func callRequest() {
        let request = URLRequest(url: Nasa.photo)
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        session.dataTask(with: request).resume()
    }
    
    @objc func requestButtonTapped() {
        buffer = Data()
        requestButton.isEnabled = false
        callRequest()
    }
}

extension ViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
            guard let contentLengthString = response.value(forHTTPHeaderField: "Content-Length"), let contentLength = Double(contentLengthString) else {
                nasaImageView.image = UIImage(systemName: "star")
                return .cancel
            }
            total = contentLength
            return .allow
        } else {
            nasaImageView.image = UIImage(systemName: "star")
            return .cancel
        }
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer?.append(data)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if error != nil {
            progressLabel.text = "문제가 발생했습니다."
            nasaImageView.image = UIImage(systemName: "star")
        } else {
            guard let buffer else {
                print("buffer nil")
                return
            }
            let image = UIImage(data: buffer)
            nasaImageView.image = image
        }
        requestButton.isEnabled = true
    }
}
