//
//  ViewController.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 9/26/24.
//

import UIKit
import SnapKit
import RxSwift

//레이아웃
fileprivate enum Section: Hashable {
    case double
    case banner
    // 헤더에 String값을 전달하기위함
    case horizontal(String)
    case vertical(String)
}

//셀
fileprivate enum Item: Hashable {
    //normal은 같은 UI를 두개의 타입이 공통으로 사용하는 특수한 경우이기 때문에 타입을 하나더 만들예정
    //case normal(TV)
    case normal(Content)
    case bigImage(Movie)
    case list(Movie)
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>?
    let buttonView = ButtonView()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        
        collectionView.register(NormalCollectionViewCell.self, forCellWithReuseIdentifier: NormalCollectionViewCell.id)
        collectionView.register(MainBannerCollectionViewCell.self, forCellWithReuseIdentifier: MainBannerCollectionViewCell.id)
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.id)
        return collectionView
    }()
    let viewModel = ViewModel()
    // Subject : 이벤트를 발생시키면서 Obsevable 형태도 되는것 Observable이자 Observer의 역할을 동시에 수행하는 특별한 유형의 객체
    let tvTrigger = PublishSubject<Void>()
    let movieTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDataSource()
        bindViewModel()
        bindView()
        tvTrigger.onNext(())
    }

    private func setUI() {
        self.view.addSubview(buttonView)
        self.view.addSubview(collectionView)
                
        buttonView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(buttonView.snp.bottom)
        }
    }
    
    private  func bindViewModel() {
        let input = ViewModel.Input(tvTrigger: tvTrigger.asObservable(), movieTrigger: movieTrigger.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.tvList.bind { [weak self] (tvList) in
            print("tvList 결과값 : \(tvList)")
            //데이터가 떨어지는 부분
            var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
            let items = tvList.map { content in
                return Item.normal(Content(tv: content))
            }
            let section = Section.double
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            
            self?.dataSource?.apply(snapshot)
        }.disposed(by: disposeBag)
        
        output.movieResult.bind { result in
            print("movieResult 결과값 : \(result)")
            switch result {
            case .success(let movieResult):
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                let bigImageList = movieResult.nowPlaying.results.map { movie in
                    return Item.bigImage(movie)
                }
                let section = Section.banner
                snapshot.appendSections([section])
                snapshot.appendItems(bigImageList, toSection: section)
                
                let horizontalSection = Section.horizontal("Popular Movies")
                let horizontalList = movieResult.popular.results.map { popular in
                    return Item.normal(Content(movie: popular))
                }
                
                let verticalSection = Section.vertical("Upcoming Movies")
                
                snapshot.appendSections([horizontalSection])
                snapshot.appendItems(horizontalList, toSection: horizontalSection)
                
                let upcomingList = movieResult.upcoming.results.map { upcoming in
                    return Item.list(upcoming)
                }
                
                snapshot.appendSections([verticalSection])
                snapshot.appendItems(upcomingList, toSection: verticalSection)
                
                self.dataSource?.apply(snapshot)
            case .failure(let error):
                // error toast
                print(error)
            }
           
        }.disposed(by: disposeBag)
    }
    
    private func bindView() {
        buttonView.tvButton.rx.tap.bind { [weak self] in
            self?.tvTrigger.onNext(Void())
        }.disposed(by: disposeBag)
        
        buttonView.movieButton.rx.tap.bind { [weak self] in
            self?.movieTrigger.onNext(Void())
        }.disposed(by: disposeBag)
        
        //RX를 사용하여 해당 이벤트 받아오는 방법
        collectionView.rx.itemSelected.bind { indexPath in
            print(indexPath)
            let item = self.dataSource?.itemIdentifier(for: indexPath)
            switch item {
            case .normal(let content):
                print("content")
                let viewController = ReviewViewController(id: content.id, contentType: content.type)
                self.present(viewController, animated: true)
            default:
                print("default")
            }
        }.disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 14
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            
            switch section {
            case .banner:
                return self?.createMainSection()
                
            case .horizontal:
                return self?.createHorizontalSection()
                
            case .vertical(let string):
                return self?.createVerticalListSection()
                
            default:
                return self?.createDoubleSection()
            }
        }, configuration: config)
    }
    
    private func createMainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(640))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createVerticalListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 3 )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createDoubleSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .normal(let contentData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NormalCollectionViewCell.id, for: indexPath) as? NormalCollectionViewCell
                cell?.configure(title: contentData.title, review: contentData.vote, description: contentData.overview, imageURL: contentData.posterURL)
                
                return cell
                
            case .bigImage(let movieData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainBannerCollectionViewCell.id, for: indexPath) as? MainBannerCollectionViewCell
                cell?.configure(title: movieData.title, overView: movieData.overview, review: movieData.vote, url: movieData.posterURL)
                
                return cell
                
            case .list(let movieData):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as? ListCollectionViewCell
                cell?.configure(title: movieData.title, releaseDate: movieData.releaseDate, url: movieData.posterURL)
                
                return cell
            }
        })
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.id, for: indexPath)
            let section = self.dataSource?.sectionIdentifier(for: indexPath.section)
            
            switch section {
            case .horizontal(let string), .vertical(let string):
                (header as? HeaderView)?.configure(title: string)
                
            default:
                print("default")
            }
            return header
        }
    }
}
