//
//  TVNetwork.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 9/26/24.
//

import Foundation
import RxSwift

final class TVNetwork {
    private let network: Network<TVListModel>
    init(network: Network<TVListModel>) {
        self.network = network
    }
    
    func getTopRatedList() -> Observable<TVListModel> {
        return network.getItemList(path: "/tv/top_rated")
    }
}
