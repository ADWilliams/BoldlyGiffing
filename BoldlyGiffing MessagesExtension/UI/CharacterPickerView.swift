//
//  CharacterPickerView.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-07-20.
//  Copyright © 2017 Sweet Software. All rights reserved.
//


import UIKit

let loadCharacterNotification = Notification.Name("notification.loadCharacter")
let closePickerNotification = Notification.Name("notification.closePicker")
let characterPickerViewIdentifier = "characterPickerViewIdentifier"

final class CharacterPickerView: UICollectionReusableView {

    override var reuseIdentifier: String? {
        return characterPickerViewIdentifier
    }

    @IBOutlet var view: UIView!
    @IBOutlet weak var picardButton: LcarsButton!
    @IBOutlet weak var worfButton: LcarsButton!
    @IBOutlet weak var crusherButton: LcarsButton!
    @IBOutlet weak var rikerButton: UIButton!
    @IBOutlet weak var yarButton: UIButton!
    @IBOutlet weak var troiButton: UIButton!
    @IBOutlet weak var laForgeButton: LcarsButton!
    @IBOutlet weak var dataButton: LcarsButton!
    @IBOutlet weak var allCharactersButton: LcarsButton!
    @IBOutlet weak var closeButton: UIButton!

    @IBAction func closeButtonPressed(_ sender: Any) {
        close()
    }
    
    @IBAction func characterButtonPressed(_ sender: UIButton) {
//        switch sender {
//        case picardButton:
//            load(character: .Picard)
//        case worfButton:
//            load(character: .Worf)
//        case crusherButton:
//            load(character: .Crusher)
//        case rikerButton:
//            load(character: .Riker)
//        case yarButton:
//            load(character: .Yar)
//        case laForgeButton:
//            load(character: .LaForge)
//        case dataButton:
//            load(character: .Data)
//        case troiButton:
//            load(character: .Troi)
//        case allCharactersButton:
//            load(character: .All)
//        default:
//            return
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        
        let leftButtons = [picardButton, worfButton, crusherButton]
        leftButtons.forEach{ $0!.setRounded(corners: [.topLeft, .bottomLeft])}
        let rightButtons = [dataButton, laForgeButton, allCharactersButton]
        rightButtons.forEach { $0!.setRounded(corners: [.topRight, .bottomRight])}
        
        addSubview(view)
    }

    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "CharacterPickerView", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    private func close() {
        NotificationCenter.default.post(name: closePickerNotification, object: nil)
    }

    private func load(character: CharacterTag) {
        NotificationCenter.default.post(name: loadCharacterNotification, object: nil, userInfo: ["characterTag": character])
    }
}
