import Foundation
import UIKit

final class AlertPresenter {
    weak private var delegate: UIViewController?

    func setup(delegate: UIViewController) {
        self.delegate = delegate
    }

    func showAlert(alert alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }

        alert.addAction(action)

        delegate?.present(alert, animated: true)
    }
}