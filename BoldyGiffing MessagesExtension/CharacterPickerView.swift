//
//  CharacterPickerView.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-07-20.
//  Copyright © 2017 SweetieApps. All rights reserved.
//

import UIKit

 let loadCharacterNotification = Notification.Name("notification.loadCharacter")

final class CharacterPickerView: UIView {

    @IBOutlet weak var picardButton: UIButton!
    @IBOutlet weak var worfButton: UIButton!
    @IBOutlet weak var crusherButton: UIButton!
    @IBOutlet weak var rikerButton: UIButton!
    @IBOutlet weak var yarButton: UIButton!
    @IBOutlet weak var laForgeButton: UIButton!
    @IBOutlet weak var dataButton: UIButton!
    @IBOutlet weak var troiButton: UIButton!
    @IBOutlet weak var allCharactersButton: UIButton!

    @IBAction func characterButtonPressed(_ sender: UIButton) {
        switch sender {
        case picardButton:
            load(character: .Picard)
        case worfButton:
            load(character: .Worf)
        case crusherButton:
            load(character: .Crusher)
        case rikerButton:
            load(character: .Riker)
        case yarButton:
            load(character: .Yar)
        case laForgeButton:
            load(character: .LaForge)
        case dataButton:
            load(character: .Data)
        case troiButton:
            load(character: .Troi)
        case allCharactersButton:
            load(character: .All)
        default:
            return
        }
    }

    func load(character: CharacterTag) {
        NotificationCenter.default.post(name: loadCharacterNotification, object: nil, userInfo: ["characterTag": character])
    }
}
