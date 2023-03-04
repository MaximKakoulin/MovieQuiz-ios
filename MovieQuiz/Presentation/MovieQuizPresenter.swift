import UIKit



final class MovieQuizPresenter {
    var noButton: UIButton!
    var yesButton: UIButton!
    var imageView: UIImageView!
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    weak var questionFactory: QuestionFactory?
    var statisticService: StatisticService?
    var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(), // распаковываем картинку
            question: model.text, // берём текст вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }

        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func toggleButtons() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

     func showNextQuestionOrResults() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        // объединить guard
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            guard let bestGame = statisticService?.bestGame else { return }

            let text =
            "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n Количество сыгранных квизов: \(gamesCount)\n Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n Средняя точность: \(String(format: "%.2f", totalAccuracy))%"


            let alertPresenter = AlertPresenter()
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз")
            { [weak self] _ in
                guard let self = self else { return }

                self.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }

            alertPresenter.showAlert(with: alertModel, in: viewController!)

        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
