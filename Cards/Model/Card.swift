//
//  Card.swift
//  Cards
//
//  Created by Daria on 29.08.2023.
//

import Foundation
import UIKit

//типы фигуры карт
enum CardType: CaseIterable {
    case circle
    case cross
    case square
    case fill
}

enum CardColor: CaseIterable {
case red
case green
case black
case gray
case brown
case yellow
case purple
case orange
}


typealias Card = (type: CardType, color: CardColor)
