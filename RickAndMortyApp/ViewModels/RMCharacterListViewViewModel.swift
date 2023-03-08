//
//  CharacterListViewViewModel.swift
//  RickAndMortyApp
//
//  Created by Enes Sancar on 4.03.2023.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didLoadMoreCharacters(with newIndexPath: [IndexPath])
    func didSelectCharacter(_ character: RMCharacter)
}

final class RMCharacterListViewViewModel: NSObject {
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    public var isLoadingMoreCharacters = false
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters  {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.url)
                )
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    private var apiInfo: RMGetAllCharactersResponse.Info? = nil
    
    public func fetchCharacters() {
        RMService.shared.execute(
            .listCharactersRequest,
            expecting: RMGetAllCharactersResponse.self) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    strongSelf.apiInfo = info
                    
                    let originalCount = strongSelf.characters.count
                    let newCount = moreResults.count
                    let total = originalCount + newCount
                    let startingIndex = total - newCount - 1
                    let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount)).compactMap({
                        return IndexPath(row: $0, section: 0)
                    })
                    
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didLoadMoreCharacters(with: indexPathsToAdd)
                        //strongSelf.delegate?.didLoadInitialCharacters()
                        strongSelf.isLoadingMoreCharacters = false
                    }
                case .failure(let error):
                    print(String(describing: error))
                    self?.isLoadingMoreCharacters = false
                }
            }
    }
    
    // Paginate if additioal characters are needed
    public func fetchAdditionalCharacters(url: URL) {
        guard !isLoadingMoreCharacters else {
            return
        }
        
        isLoadingMoreCharacters = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            return
        }
        RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self) {
            [weak self] result in
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                self?.characters.append(contentsOf: moreResults)
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
                self?.isLoadingMoreCharacters = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
}

//MARK: - CollectionView Delegate/DataSource/DelegateFlowLayout
extension RMCharacterListViewViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.identifier, for: indexPath) as? RMCharacterCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
                for: indexPath
              ) as? RMFooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30) / 2
        let height = width * 1.5
        
        return CGSize(width: width,height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
}

//MARK: - Scroll View
extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMoreCharacters,
              !cellViewModels.isEmpty,
              let nextUrlString = apiInfo?.next,
              let url = URL(string: nextUrlString) else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] t in
            let offSet = scrollView.contentOffset.y // kaydırırken nerde olduğun
            let totalContentHeight = scrollView.contentSize.height // toplam cihaz uzunluk
            let totalScrollViewFixedHeight = scrollView.frame.size.height // toplam kaydırma
            
            if offSet >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAdditionalCharacters(url: url)
            }
            t.invalidate()
        }
    }
}