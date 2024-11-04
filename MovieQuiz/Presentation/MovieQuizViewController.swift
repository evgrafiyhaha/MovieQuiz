import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IB Outlets
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!

    // MARK: - Private Properties
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var currentQuestion: QuizQuestion?

    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory

        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter

        statisticService = StatisticService()

        questionFactory.requestNextQuestion()

    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - IB Actions
    @IBAction private func noButonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let userAnswer = false
        let correctAnswer = currentQuestion.correctAnswer

        showAnswerResult(isCorrect: userAnswer == correctAnswer)
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let userAnswer = true
        let correctAnswer = currentQuestion.correctAnswer

        showAnswerResult(isCorrect: userAnswer == correctAnswer)
    }

    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }

     private func show(quiz result: QuizResultsViewModel) {
         let alert = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
             guard let self = self else { return }
             self.currentQuestionIndex = .zero
             self.correctAnswers = .zero

             questionFactory.requestNextQuestion()

         }
        alertPresenter.showAlert(alert: alert)
    }

    private func showAnswerResult(isCorrect: Bool) {

        yesButton.isEnabled = false
        noButton.isEnabled = false

        let color: UIColor = isCorrect ? .ypGreen : .ypRed
        correctAnswers += isCorrect ? 1 : 0

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color.cgColor
        imageView.layer.cornerRadius = 20

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = .zero
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let message: String = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКолличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/10 (\(dateConverterMoscow(date: statisticService.bestGame.date))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)

        } else {
            currentQuestionIndex += 1

            questionFactory.requestNextQuestion()
        }
    }
    private func dateConverterMoscow(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
            return dateFormatter.string(from: date)
        }
}

/*
 Mock-данные


 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
