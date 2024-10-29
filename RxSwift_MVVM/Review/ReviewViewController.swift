//
//  ReviewViewController.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 10/10/24.
//

import UIKit
import RxSwift

fileprivate enum Section {
    case list
}

fileprivate enum Item: Hashable {
    case header(ReviewHeader)
    case content(String)
}

fileprivate struct ReviewHeader: Hashable {
    let id: String
    let name: String
    let url: String
}

final class ReviewViewController: UIViewController {
    let viewModel: ReviewViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private let disposeBag = DisposeBag()
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(ReviewHeaderCollectionViewCell.self, forCellWithReuseIdentifier: ReviewHeaderCollectionViewCell.id)
        collectionView.register(ReviewCollectionViewCell.self, forCellWithReuseIdentifier: ReviewCollectionViewCell.id)

        return collectionView
    }()
    
    init(id: Int, contentType: ContentType) {
        self.viewModel = ReviewViewModel(id: id, contentType: contentType)
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setUI()
        collectionView.rx.itemSelected.bind { indexPath in
            //sectionSnapshot.expand(headerItem)
            guard let item = self.dataSource?.itemIdentifier(for: indexPath),
                  var sectionSnapshot = self.dataSource?.snapshot(for: .list) else { return }
            
            if case .header = item {
                if sectionSnapshot.isExpanded(item) {
                    sectionSnapshot.collapse([item])
                } else {
                    sectionSnapshot.expand([item])
                }
                self.dataSource?.apply(sectionSnapshot, to: .list)
            }
        }.disposed(by: disposeBag)
    }
    
    
    func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .header(let header):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewHeaderCollectionViewCell.id, for: indexPath) as? ReviewHeaderCollectionViewCell
                cell?.configure(title: header.name, url: header.url)
                return cell
            case .content(let content):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.id, for: indexPath) as? ReviewCollectionViewCell
                cell?.configure(content: content)
                return cell
            }
        })
        var datasourceSnapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        datasourceSnapshot.appendSections([.list])
        dataSource?.apply(datasourceSnapshot)
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: ReviewViewModel.Input())
        output.reviewResult.map { result -> [ReviewModel] in
            switch result {
            case .success(let reviewList):
                return reviewList
            case .failure(let failure):
                return []
            }
            //클로저 내부에서 타입 추론이 불가능하다는 오류발생으로 명시적으로 지정 reviewList: [ReviewModel]
        }.bind { [weak self] (reviewList: [ReviewModel]) in
            guard !reviewList.isEmpty else { return }
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            
            reviewList.forEach { review in
                let header = ReviewHeader.init(id: review.id,
                                               name: review.author.name.isEmpty ? review.author.username : review.author.name,
                                               url: review.content)
                let headerItem = Item.header(header)
                let contentItem = Item.content(review.content)
                sectionSnapshot.append([headerItem])
                sectionSnapshot.append([contentItem], to: headerItem)
            }
            self?.dataSource?.apply(sectionSnapshot, to: .list)
        }.disposed(by: disposeBag)
    }
    
    func setUI() {
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setDataSource()
    }
}
