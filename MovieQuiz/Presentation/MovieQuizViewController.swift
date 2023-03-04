import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        toggleButtons()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        toggleButtons()
    }

    private func toggleButtons() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // Индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }

    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // Скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // message - это описание ошибки
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true

        let alertPresenter = AlertPresenter()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз")
        { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.showAlert(with: alertModel, in: self )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewController = self

        imageView.layer.cornerRadius = 20

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

        imageView.layer.cornerRadius = 20
    }

    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderColor = UIColor.clear.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.presenter.correctAnswers = self.presenter.correctAnswers
            self.presenter.questionFactory = self.presenter.questionFactory
            self.presenter.showNextQuestionOrResults()
            self.toggleButtons()
        }
    }
}



























































