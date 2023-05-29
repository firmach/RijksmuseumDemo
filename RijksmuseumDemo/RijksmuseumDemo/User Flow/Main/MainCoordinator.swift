//
//  MainCoordinator.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit


final class MainCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let artObjectsCollectionViewModel = ArtObjectsCollectionViewModel(
            dependencies: DefaultArtObjectsViewModelDependencies()
        )

        let artObjectsCollectionViewController = ArtObjectsCollectionViewController(
            coordinator: self,
            viewModel: artObjectsCollectionViewModel
        )
        navigationController.pushViewController(artObjectsCollectionViewController, animated: false)
    }

    func detailArtObject(artObject: ArtObject) {
        let artObjectsViewModelDependencies = DefaultArtObjectsViewModelDependencies()
        let artObjectDetailsViewModel = ArtObjectDetailsViewModel(
            objectNumber: artObject.objectNumber,
            dependencies: artObjectsViewModelDependencies
        )
        let artObjectDetailsViewController = ArtObjectDetailsViewController(viewModel: artObjectDetailsViewModel)
        navigationController.pushViewController(artObjectDetailsViewController, animated: true)
    }

}
