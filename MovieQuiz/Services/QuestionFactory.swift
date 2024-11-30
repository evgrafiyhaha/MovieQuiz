import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var currentQuestionIndex: Int = .zero
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    private enum NetworkError: LocalizedError {
        case errorMessageError
        case imageLoadingError

        var localizedDescription: String {
            switch self {
            case .errorMessageError:
                return "Ошибка подключения к интернету"
            case .imageLoadingError:
                return "Не удалось загрузить изображение"
            }
        }
    }

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func requestNextQuestion() {
        guard let movie = movies.randomElement() else { return }

        moviesLoader.loadImage(url: movie.resizedImageURL) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let imageData):
                let rating = Float(movie.rating) ?? 0
                let questionRating = Float((5...9).randomElement() ?? 0)

                let comparisonOperator = Bool.random() ? ">" : "<"
                let correctAnswer = comparisonOperator == ">" ? (rating > questionRating) : (rating < questionRating)
                let comparisonWord = comparisonOperator == ">" ? "больше" : "меньше"

                let text = "Рейтинг этого фильма \(comparisonWord) чем \(Int(questionRating))?"

                let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)

                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: question)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if !mostPopularMovies.errorMessage.isEmpty {
                        self.delegate?.didFailToLoadData(with: NetworkError.errorMessageError)
                        return
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}

