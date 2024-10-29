//
//  NetworkProvider.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 9/26/24.
//

import Foundation

final class NetworkProvider {
    private let endPoint: String
    
    init() {
        self.endPoint = "https://api.themoviedb.org/3"
    }
    
    func makeTVNetwork() -> TVNetwork {
        let network = Network<TVListModel>(endPoint)
        return TVNetwork(network: network)
    }
    
    func makeMovieNetwork() -> MovieNetwork {
        let network = Network<MovieListModel>(endPoint)
        return MovieNetwork(network: network)
    }
    
    func makeReviewNetwork() -> ReviewNetwork {
        let network = Network<ReviewListModel>(endPoint)
        return ReviewNetwork(network: network)
    }
}
