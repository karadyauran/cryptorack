//
//  CoinCapPriceService.swift
//  CryptoTrackerApp
//
//  Created by Александр Карадяур on 18.01.24.
//

import Combine
import Foundation
import Network

class CoinCapPriceService: NSObject {
    private let session = URLSession(configuration: .default)
    private var wsTask: URLSessionWebSocketTask?
    private var pingTryCount = 0
    
    private let coinDictionarySubject = CurrentValueSubject<[String: Coin], Never>([:])
    private var coinDictionary: [String: Coin] {coinDictionarySubject.value}
    
    private let connectionStateSubject = CurrentValueSubject<Bool, Never>(false)
    private var isConnected: Bool {connectionStateSubject.value}
    
    func connect() {
        let coins = CoinType.allCases
            .map {$0.rawValue}
            .joined(separator: ",")
        
        let url = URL(string: "wss://ws.coincap.io/prices?assets=\(coins)")!
        wsTask = session.webSocketTask(with: url)
        wsTask?.delegate = self
        wsTask?.resume()
        self.receiveMessage()
        self.schedulePing()
    }
    
    private func receiveMessage() {
        wsTask?.receive {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("[INFO] Received text message: \(text)")
                    if let data = text.data(using: .utf8) {
                        self.onReceiveData(data)
                    }
                    
                case .data(let data):
                    print("[INFO] Received binary data: \(data)")
                    self.onReceiveData(data)
                    
                default:
                    break
                }
                
                self.receiveMessage()
                
            case .failure(let error):
                print("[FAIL] Failed to receive meassage: \(error.localizedDescription)")
            }
        }
    }
    
    private func onReceiveData(_ data: Data) {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String:String] else {
            return
        }
        
        var newDictionary = [String:Coin]()
        dictionary.forEach {(key, value) in
            let value = Double(value) ?? 0
            newDictionary[key] = Coin(name: key.capitalized, value: value)
        }
        
        let mergeDictionary = coinDictionary.merging(newDictionary) {old, new in new}
        coinDictionarySubject.send(mergeDictionary)
    }
    
    private func schedulePing() {
        let identifier = self.wsTask?.taskIdentifier ?? -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
            guard let self = self, let task = self.wsTask,
                  task.taskIdentifier == identifier
            else {
                return
            }
            
            if task.state == .running, self.pingTryCount < 2 {
                self.pingTryCount += 1
                print("[INFO] Ping: Send Ping \(self.pingTryCount)")
                task.sendPing { [weak self] error in
                    if let error = error {
                        print("[FAIL] Ping failed: \(error.localizedDescription)")
                    } else if self?.wsTask?.taskIdentifier == identifier {
                        self?.pingTryCount = 0
                    }
                }
                self.schedulePing()
            } else {
                self.reconnect()
            }
        }
    }
    
    private func reconnect() {
        self.clearConnection()
        self.connect()
    }
    
    func clearConnection() {
        self.wsTask?.cancel()
        self.wsTask = nil
        self.pingTryCount = 0
        self.connectionStateSubject.send(false)
    }
 
    deinit {
        coinDictionarySubject.send(completion: .finished)
        connectionStateSubject.send(completion: .finished)
    }
}

extension CoinCapPriceService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.connectionStateSubject.send(true)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.connectionStateSubject.send(false)
    }
}
