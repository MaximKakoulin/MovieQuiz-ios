import Foundation


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // Сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // Сообщение об ошибки загрузки
}
