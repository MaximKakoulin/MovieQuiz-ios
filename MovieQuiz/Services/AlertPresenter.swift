import UIKit


final class AlertPresenter {
    func showAlert (with model: AlertModel, in viewController: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)

        alert.view.accessibilityIdentifier = "Game results"


        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)

        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}

