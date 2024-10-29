//
//  ViewModel.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 9/27/24.
//

import Foundation
import RxSwift

class ViewModel {
    let disposeBag = DisposeBag()
    
    private let tvNetwork: TVNetwork
    private let movieNetwork: MovieNetwork
    
    init() {
        let provider = NetworkProvider()
        tvNetwork = provider.makeTVNetwork()
        movieNetwork = provider.makeMovieNetwork()
    }
    
    struct Input {
        let tvTrigger: Observable<Void>
        let movieTrigger: Observable<Void>
    }
    
    struct Output {
        let tvList: Observable<[TV]>
        let movieResult: Observable<Result<MovieResult, Error>>
    }
    
    func transform(input: Input) -> Output {
        //1. trigger 2.네트워크 연결 3.해당 프로젝트에서는 Obsevable<[T]> -> Observable<TVListMoel> 4. VC로 전달 5.VC에서 구독
        
        //TVListModel의 result Observable<TVListMoel> -> Obsevable<[TV]>
        let tvList = input.tvTrigger.flatMapLatest { [unowned self] _ -> Observable<[TV]> in
            return self.tvNetwork.getTopRatedList()
                .map { model in
                    return model.results
                }
        }
        
        // Observable 1, 2, 3 을 합치고 싶다면 cont
        let movieResult = input.movieTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<MovieResult, Error>> in
            return Observable.combineLatest(self.movieNetwork.getNowPlayingList(),
                                            self.movieNetwork.getPopularList(),
                                            self.movieNetwork.getUpcomingList()) { upcoming, popular, nowPlaying -> Result<MovieResult, Error> in
                //return MovieResult(upcoming: upcoming, popular: popular, nowPlaying: nowPlaying)
                return .success(MovieResult(upcoming: upcoming, popular: popular, nowPlaying: nowPlaying))
            }.catchError { error in
                print(error)
                return Observable.just(.failure(error))
            }
        }
        
        return Output(tvList: tvList, movieResult: movieResult)
    }
}
