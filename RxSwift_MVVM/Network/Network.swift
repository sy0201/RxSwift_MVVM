//
//  Network.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 9/26/24.
//

import Foundation
import RxSwift
import RxAlamofire


class Network<T: Decodable> {
    
    private let endPoint: String
    private let queue: ConcurrentDispatchQueueScheduler
    init(_ endPoint: String) {
        self.endPoint = endPoint
        self.queue = ConcurrentDispatchQueueScheduler(qos: .background)
    }
    
    func getItemList(path: String, language: String = "ko") -> Observable<T> {
        let fullPath = "\(endPoint)\(path)?api_key=\(APIKEY)&language=\(language)"
        print("Full API Request Path: \(fullPath)")
        
        return RxAlamofire.data(.get, fullPath)
            .observeOn(queue)
            .do(onNext: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API Response: \(jsonString)")
                }
            })
            .map { data -> T in
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("Error decoding JSON: \(error)")
                    throw error
                }
            }
        
    }
}
