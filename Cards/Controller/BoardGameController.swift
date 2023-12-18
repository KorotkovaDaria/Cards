//
//  BoardGameController.swift
//  Cards
//
//  Created by Daria on 29.08.2023.
//

import UIKit

class BoardGameController: UIViewController {
    //MARK: - Свойства
    //количество пар уникальных карточек
    var cardsPairsCounts = 8
    //сущность "Игра"
    lazy var game: Game = getNewGame()
    private var flippedCards = [UIView]()
    
    //MARK: - loadView
    override func loadView() {
        super.loadView()
        //добавляем кнопку на сцену
        view.addSubview(startButtomView)
        //добавляем игровое пое на сцену
        view.addSubview(boardGameView)
    }
    //MARK: - функция для начала новой игры
    
    private func getNewGame() -> Game {
        let game = Game()
        game.cardsCount = self.cardsPairsCounts
        game.generateCards()
        return game
    }

    //MARK: - кнопка для запуска/перезапуска игры
    lazy var startButtomView = getStartButtonView()
    
    private func getStartButtonView() -> UIButton {
        //1. Создаем кнопку
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        //2. изменяем положение кнопки
        button.center.x = view.center.x
        //3.Получем лоступ к текущему окну
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available")
        }
        //определяем отступ сверху от границ окна до Safe Area
        let topPadding = window.safeAreaInsets.top
        //устанавливаем координату Y кнопки в соотвествии с отступом
        button.frame.origin.y = topPadding
        //4. Настраиваем внешний вид кнопки
        //устанавливаем текст
        button.setTitle("Начать игру", for: .normal)
        //устанавливаем цыет текста для обычного (не нажатого) состояния
        button.setTitleColor(.black, for: .normal)
        //устанавливаем цвет текста для нажатого состояния
        button.setTitleColor(.white, for: .highlighted)
        //устанавливаем фотовый цвет
        button.backgroundColor = .systemGray4
        //скругляем края
        button.layer.cornerRadius = 20
        
        //5.подключаем обработчик нажатия на кнопку
        button.addTarget(nil, action: #selector(startGame(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func startGame(_ sender: UIButton) {
        game = getNewGame()
        let cards = getCardsBy(modelData: game.cards)
        placeCardsOnBoard(cards)
    }
    
    
    //MARK: - Игровое поле
    lazy var boardGameView = getBoardGameView()
    
    private func getBoardGameView() -> UIView {
        //отступ игрового поля от ближайших элементов
        let margin: CGFloat = 10
        
        let boardView = UIView()
        //указываем координаты
        //x
        boardView.frame.origin.x = margin
        //y
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available")
        }
        let topPadding = window.safeAreaInsets.top
        boardView.frame.origin.y = topPadding + startButtomView.frame.height + margin
        
        //расчитываем ширину
        boardView.frame.size.width = UIScreen.main.bounds.width - margin*2
        //расчитываем высоту
        //с учетом нижнего отступа
        let bottomPadding = window.safeAreaInsets.bottom
        boardView.frame.size.height = UIScreen.main.bounds.height - boardView.frame.origin.y - margin - bottomPadding
        //изменяем стиль игрового поля
        boardView.layer.cornerRadius = 5
        boardView.backgroundColor = UIColor(red: 0.6, green: 0.7, blue: 0.4, alpha: 0.3)
        
        return boardView
    }
    
    //MARK: - генерация массива карточек на основе данных модели
    private func getCardsBy(modelData: [Card]) -> [UIView] {
        //хранилище для представлений карточек
        var cardViews = [UIView]()
        //фабрика карточек
        let cardViewFactory = CardViewFactory()
        //перебираем массив карточек в Модели
        for (index, modelCard) in modelData.enumerated() {
            //добавляем первый экземпляр карты
            let cardOne = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardOne.tag = index
            cardViews.append(cardOne)
            
            //добавляем второй экземпляр карты
            let cardTwo = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardTwo.tag = index
            cardViews.append(cardTwo)
        }
        //добавляем все картам обработчик переворота
        for card in cardViews {
            (card as! FlippableView).flipCompletionHandler = { flippedCard in
                //переносим карточку ввер по иэрархии
                flippedCard.superview?.bringSubviewToFront(flippedCard)
            }
        }
        //добавляем всем картам обработчик переворотв
        for card in cardViews {
            (card as! FlippableView).flipCompletionHandler = { [self] flippedCard in
                //переносим карточку вверх иерархии
                flippedCard.superview?.bringSubviewToFront(flippedCard)
                
                //добавляем или удаляем карточку
                if flippedCard.isFlipped {
                    self.flippedCards.append(flippedCard)
                } else {
                    if let cardIndex = self.flippedCards.firstIndex(of: flippedCard) {
                        self.flippedCards.remove(at: cardIndex)
                    }
                }
                
                //если перевернуто 2 карточки
                if self.flippedCards.count == 2 {
                    //получаем карточки мз данных модели
                    let firstCard = game.cards[self.flippedCards.first!.tag]
                    let secondCard = game.cards[self.flippedCards.last!.tag]
                    
                    // если карточки одинаковые
                    if game.checkCards(firstCard, secondCard) {
                        //сперва анимировано скрываем их
                        UIView.animate(withDuration: 0.3, animations:  {
                            self.flippedCards.first!.layer.opacity = 0
                            self.flippedCards.last!.layer.opacity = 0
                            //после чего удаляем из иерархии
                        }, completion: { _ in
                            self.flippedCards.first!.removeFromSuperview()
                            self.flippedCards.last!.removeFromSuperview()
                            self.flippedCards = []
                        })
                        //в ином случае
                    } else {
                        //переворачиваем карточки рубашкой вверх
                        for card in self.flippedCards {
                            (card as! FlippableView).flip()
                        }
                    }
                }
            }
        }
        return cardViews
    }
    
    //размер карточек
    private var cardSize: CGSize {
        CGSize(width: 80, height: 120)
    }
    //предельные координаты размещения карточки
    private var cardMaxXCoordinate: Int {
        Int(boardGameView.frame.width - cardSize.width)
    }
    
    private var cardMaxYCoordinate: Int {
        Int(boardGameView.frame.height - cardSize.height)
    }
    
    //Игральные карточки
    var cardViews = [UIView]()
    
    private func placeCardsOnBoard(_ cards: [UIView]) {
        //удаляем все имеющиеся на игровом поле карточки
        for card in cardViews {
            card.removeFromSuperview()
        }
        cardViews = cards
        //перебераем карточки
        for card in cardViews {
            //для каждой карточки генерируем случайные координаты
            let randomXCoordinate = Int.random(in: 0...cardMaxXCoordinate)
            let randomYCoordinate = Int.random(in: 0...cardMaxYCoordinate)
            card.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            //размещаем карточку на игровом поле
            boardGameView.addSubview(card)
        }
    }
}
