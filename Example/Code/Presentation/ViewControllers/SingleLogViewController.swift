//
// SingleLogViewController
// Example
//
// Created by Roman Mazeev on 28.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import UIKit
import Robologs

class SingleLogViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var logsTextView: UITextView!
    @IBOutlet private var selectedLogLevelSegmentedControl: UISegmentedControl!
    @IBOutlet private var labelTextField: UITextField!
    @IBOutlet private var messageTextField: UITextField!
    @IBOutlet private var formBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var formStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogger()
        setupKeyboardShowing()
    }

    private var logText: String = ""

    private func setupLogger() {
        Loggers.instance.bufferLoggerHandler = { [weak self] logs in
            guard let self = self else { return }

            self.logText += logs.joined(separator: "\n") + "\n"
            if self.logText.count > 8192 {
                self.logText = String(self.logText.suffix(8192))
            }
            self.logsTextView.text = self.logText
            self.logsTextView.scrollRectToVisible(
                CGRect(x: 0, y: self.logsTextView.contentSize.height - 1, width: 1, height: 1),
                animated: false
            )
        }
    }

    private func setupKeyboardShowing() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        if formBottomConstraint.constant <= keyboardSize.height {
            formBottomConstraint.constant = keyboardSize.height

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        formBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func sendLogButtonTapped() {
        Loggers.instance.logger.log(
            level: Level.allCases[selectedLogLevelSegmentedControl.selectedSegmentIndex],
            "\(messageTextField.text ?? "empty log")",
            label: labelTextField.text ?? ""
        )
    }

    @IBAction
    private func autoGenerateMessage() {
        messageTextField.text = String(loremIpsum.prefix((0 ..< loremIpsum.count).randomElement() ?? 123))
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == labelTextField {
            messageTextField.becomeFirstResponder()
            return true
        } else if textField == messageTextField {
            messageTextField.resignFirstResponder()
            return true
        } else {
            return true
        }
    }

    // swiftlint:disable line_length
    private let loremIpsum: String =
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Commodo viverra maecenas accumsan lacus vel facilisis volutpat est velit. Dui vivamus arcu felis bibendum. Felis bibendum ut tristique et egestas quis ipsum suspendisse. Parturient montes nascetur ridiculus mus mauris vitae ultricies leo. Interdum velit laoreet id donec ultrices. Tincidunt augue interdum velit euismod in pellentesque. Scelerisque eu ultrices vitae auctor eu. Morbi tincidunt augue interdum velit euismod in pellentesque. Tristique senectus et netus et malesuada fames. Vulputate sapien nec sagittis aliquam malesuada bibendum.
        Ac turpis egestas sed tempus urna et pharetra. Sit amet est placerat in egestas erat imperdiet sed. Praesent elementum facilisis leo vel fringilla est ullamcorper eget nulla. Varius duis at consectetur lorem donec massa sapien faucibus. Amet purus gravida quis blandit. Consectetur lorem donec massa sapien faucibus. In aliquam sem fringilla ut morbi tincidunt. Lectus mauris ultrices eros in. Velit ut tortor pretium viverra suspendisse potenti nullam ac. Velit laoreet id donec ultrices tincidunt. Mauris sit amet massa vitae tortor condimentum lacinia quis vel. Platea dictumst quisque sagittis purus sit. Lectus sit amet est placerat in egestas erat imperdiet. Volutpat sed cras ornare arcu dui vivamus. Tincidunt praesent semper feugiat nibh sed. Vestibulum mattis ullamcorper velit sed ullamcorper. Nullam vehicula ipsum a arcu cursus vitae congue mauris.
        Semper risus in hendrerit gravida rutrum quisque non tellus orci. Donec et odio pellentesque diam volutpat commodo sed egestas egestas. Tellus pellentesque eu tincidunt tortor aliquam nulla facilisi cras fermentum. Euismod quis viverra nibh cras pulvinar mattis nunc. Dictum at tempor commodo ullamcorper a lacus. Elit ut aliquam purus sit. Sit amet venenatis urna cursus eget nunc scelerisque viverra. Faucibus et molestie ac feugiat sed lectus vestibulum. Nullam non nisi est sit. Aliquam sem et tortor consequat id porta nibh. Id nibh tortor id aliquet lectus. Elit pellentesque habitant morbi tristique senectus et netus et. Tincidunt id aliquet risus feugiat in ante metus dictum. Pretium nibh ipsum consequat nisl vel pretium. Fringilla ut morbi tincidunt augue interdum velit euismod.
        Nullam non nisi est sit amet facilisis. Gravida in fermentum et sollicitudin ac orci phasellus egestas. At auctor urna nunc id cursus metus. Non pulvinar neque laoreet suspendisse interdum. Purus semper eget duis at tellus. Blandit cursus risus at ultrices mi tempus imperdiet nulla. Leo duis ut diam quam nulla porttitor massa. Ultrices dui sapien eget mi proin sed. Malesuada fames ac turpis egestas sed tempus urna et pharetra. Tristique senectus et netus et malesuada fames ac turpis. Odio eu feugiat pretium nibh ipsum consequat nisl.
        Risus ultricies tristique nulla aliquet enim tortor at. Tellus orci ac auctor augue. Aenean sed adipiscing diam donec. Lorem ipsum dolor sit amet consectetur. Eget velit aliquet sagittis id consectetur purus. Volutpat diam ut venenatis tellus in metus vulputate eu. Lobortis feugiat vivamus at augue. Morbi enim nunc faucibus a pellentesque. Diam sit amet nisl suscipit adipiscing bibendum est ultricies integer. Commodo elit at imperdiet dui accumsan sit amet. Dolor sed viverra ipsum nunc aliquet. Sed tempus urna et pharetra. Risus feugiat in ante metus dictum at tempor commodo ullamcorper. Odio morbi quis commodo odio aenean sed adipiscing diam donec. Consequat interdum varius sit amet. Neque sodales ut etiam sit amet nisl purus. Velit sed ullamcorper morbi tincidunt ornare massa eget. Nisl nunc mi ipsum faucibus vitae aliquet nec.
        Feugiat scelerisque varius morbi enim nunc faucibus a pellentesque sit. Eget gravida cum sociis natoque penatibus et magnis. Risus pretium quam vulputate dignissim suspendisse in est ante in. Magna ac placerat vestibulum lectus. Ultricies mi eget mauris pharetra et ultrices neque ornare. Pellentesque eu tincidunt tortor aliquam nulla facilisi. Lectus magna fringilla urna porttitor rhoncus dolor purus non. Urna molestie at elementum eu facilisis. Tempor id eu nisl nunc mi ipsum faucibus vitae. Proin libero nunc consequat interdum varius. Aenean sed adipiscing diam donec adipiscing tristique risus. Lobortis mattis aliquam faucibus purus in. Aliquet enim tortor at auctor urna nunc id cursus metus. Consectetur adipiscing elit pellentesque habitant morbi tristique senectus. Tortor at auctor urna nunc id cursus. Mauris augue neque gravida in fermentum et sollicitudin ac orci.
        Nec feugiat in fermentum posuere urna nec tincidunt praesent semper. Ultrices tincidunt arcu non sodales neque sodales ut etiam. Sed adipiscing diam donec adipiscing tristique risus nec feugiat in. Vulputate sapien nec sagittis aliquam malesuada bibendum arcu vitae elementum. Varius duis at consectetur lorem donec massa. Vitae auctor eu augue ut lectus arcu bibendum. Quisque egestas diam in arcu cursus euismod quis. Ut venenatis tellus in metus. Sem viverra aliquet eget sit. Tincidunt augue interdum velit euismod in pellentesque massa. Nullam ac tortor vitae purus faucibus ornare suspendisse sed nisi. Diam maecenas sed enim ut sem viverra aliquet eget. Rutrum quisque non tellus orci ac auctor augue. Donec ac odio tempor orci dapibus ultrices in iaculis nunc. Sem viverra aliquet eget sit amet tellus.
        Tortor vitae purus faucibus ornare suspendisse. Nunc congue nisi vitae suscipit tellus mauris a. A cras semper auctor neque vitae tempus quam. Donec pretium vulputate sapien nec sagittis aliquam. Nunc sed blandit libero volutpat sed cras ornare. Enim diam vulputate ut pharetra sit amet aliquam id diam. Natoque penatibus et magnis dis. Pulvinar sapien et ligula ullamcorper malesuada. Tristique senectus et netus et malesuada fames ac turpis. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Urna porttitor rhoncus dolor purus non enim praesent elementum. Tellus at urna condimentum mattis pellentesque id nibh tortor. Fermentum et sollicitudin ac orci phasellus egestas. Libero volutpat sed cras ornare arcu dui vivamus. Mi sit amet mauris commodo quis imperdiet massa.
        Scelerisque purus semper eget duis at. Tellus elementum sagittis vitae et leo duis ut diam. Faucibus turpis in eu mi bibendum neque. Congue quisque egestas diam in arcu. Magna etiam tempor orci eu. Nunc id cursus metus aliquam eleifend mi in. Dui nunc mattis enim ut. Rhoncus aenean vel elit scelerisque. Egestas integer eget aliquet nibh. Arcu cursus vitae congue mauris rhoncus aenean. Nascetur ridiculus mus mauris vitae ultricies leo. Congue nisi vitae suscipit tellus mauris a diam maecenas. Id venenatis a condimentum vitae sapien pellentesque habitant.
        Fringilla est ullamcorper eget nulla facilisi etiam dignissim diam quis. Eget duis at tellus at urna condimentum mattis pellentesque. Risus in hendrerit gravida rutrum. Velit dignissim sodales ut eu sem integer. Ornare quam viverra orci sagittis eu volutpat odio facilisis. Dui id ornare arcu odio ut sem nulla. Pulvinar mattis nunc sed blandit libero. Ullamcorper morbi tincidunt ornare massa eget egestas. Urna neque viverra justo nec ultrices. Eget dolor morbi non arcu risus quis varius.
        Mattis aliquam faucibus purus in massa tempor. Nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est. Nunc lobortis mattis aliquam faucibus purus. Egestas pretium aenean pharetra magna ac placerat vestibulum lectus. Duis at tellus at urna. Convallis aenean et tortor at risus viverra. Tempus urna et pharetra pharetra massa massa. Ornare quam viverra orci sagittis eu volutpat odio facilisis mauris. Elit pellentesque habitant morbi tristique. Odio pellentesque diam volutpat commodo sed.
        Nam libero justo laoreet sit amet cursus. Morbi tempus iaculis urna id volutpat lacus. Orci nulla pellentesque dignissim enim sit. Iaculis at erat pellentesque adipiscing. Scelerisque fermentum dui faucibus in ornare quam viverra orci. Arcu cursus vitae congue mauris rhoncus aenean vel. Curabitur gravida arcu ac tortor dignissim convallis. Quis imperdiet massa tincidunt nunc pulvinar sapien. Semper risus in hendrerit gravida rutrum. Mattis nunc sed blandit libero volutpat sed cras. Massa sapien faucibus et molestie ac feugiat sed. Euismod in pellentesque massa placerat duis ultricies lacus sed turpis. Malesuada fames ac turpis egestas sed tempus urna et. Mi bibendum neque egestas congue. Bibendum at varius vel pharetra vel. Facilisis magna etiam tempor orci eu. Nisi est sit amet facilisis magna etiam tempor orci eu.
        Mollis aliquam ut porttitor leo. Et pharetra pharetra massa massa ultricies mi quis hendrerit dolor. Urna condimentum mattis pellentesque id nibh tortor id. At ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Purus gravida quis blandit turpis cursus in. Ultrices dui sapien eget mi proin sed. Ante in nibh mauris cursus mattis molestie a iaculis at. Neque sodales ut etiam sit amet nisl purus. Vulputate odio ut enim blandit volutpat. Aenean sed adipiscing diam donec adipiscing. Duis ultricies lacus sed turpis tincidunt. Dignissim suspendisse in est ante. Quis viverra nibh cras pulvinar mattis nunc. Donec massa sapien faucibus et molestie. Faucibus et molestie ac feugiat. Aenean euismod elementum nisi quis eleifend quam adipiscing. Leo a diam sollicitudin tempor id eu. Proin libero nunc consequat interdum varius. Elit eget gravida cum sociis natoque penatibus et magnis dis. Tristique risus nec feugiat in.
        Malesuada fames ac turpis egestas sed tempus urna et. Et malesuada fames ac turpis egestas maecenas pharetra convallis posuere. Sit amet nisl suscipit adipiscing bibendum. Est sit amet facilisis magna etiam tempor orci eu lobortis. Turpis egestas sed tempus urna et. Donec ultrices tincidunt arcu non sodales neque sodales ut. Consequat interdum varius sit amet mattis vulputate enim. Augue neque gravida in fermentum et sollicitudin ac. Nulla facilisi etiam dignissim diam quis. Suscipit adipiscing bibendum est ultricies integer quis auctor elit sed. Praesent elementum facilisis leo vel. Quis hendrerit dolor magna eget est lorem. Diam maecenas sed enim ut.
        In ante metus dictum at tempor commodo ullamcorper. Semper auctor neque vitae tempus quam. Vel pharetra vel turpis nunc. Curabitur gravida arcu ac tortor dignissim. Fringilla est ullamcorper eget nulla. Donec et odio pellentesque diam volutpat commodo. Morbi blandit cursus risus at ultrices. Lacus laoreet non curabitur gravida arcu ac tortor dignissim. Placerat orci nulla pellentesque dignissim. At tempor commodo ullamcorper a lacus vestibulum sed arcu. Consequat nisl vel pretium lectus quam id leo. Iaculis urna id volutpat lacus laoreet non curabitur. Et netus et malesuada fames ac turpis egestas sed. Id velit ut tortor pretium viverra.
        Eget egestas purus viverra accumsan in. Ullamcorper morbi tincidunt ornare massa eget egestas. Orci porta non pulvinar neque laoreet suspendisse interdum. Sit amet cursus sit amet dictum sit amet. Vel pretium lectus quam id. Quam elementum pulvinar etiam non quam. Tortor pretium viverra suspendisse potenti. Facilisis sed odio morbi quis commodo odio aenean. Non tellus orci ac auctor. Aliquam nulla facilisi cras fermentum odio. Cursus turpis massa tincidunt dui ut ornare lectus. Vitae suscipit tellus mauris a. Posuere lorem ipsum dolor sit amet consectetur. Tincidunt ornare massa eget egestas purus viverra. Dolor sit amet consectetur adipiscing elit. Fermentum posuere urna nec tincidunt praesent semper feugiat nibh. Amet mattis vulputate enim nulla aliquet porttitor lacus.
        Sem et tortor consequat id porta nibh venenatis cras sed. Donec ac odio tempor orci. Tempus urna et pharetra pharetra massa massa ultricies mi quis. Nec sagittis aliquam malesuada bibendum arcu vitae elementum. Massa tincidunt nunc pulvinar sapien et ligula. Lectus magna fringilla urna porttitor rhoncus dolor purus non enim. Est lorem ipsum dolor sit amet. Vitae purus faucibus ornare suspendisse sed. Augue interdum velit euismod in pellentesque massa placerat duis ultricies. Diam quam nulla porttitor massa id. Bibendum neque egestas congue quisque egestas diam in arcu. Lectus vestibulum mattis ullamcorper velit sed ullamcorper morbi tincidunt. Nisl tincidunt eget nullam non nisi est.
        Morbi quis commodo odio aenean sed adipiscing diam donec. Sit amet mattis vulputate enim nulla. Pellentesque pulvinar pellentesque habitant morbi. Nullam ac tortor vitae purus faucibus ornare. Arcu bibendum at varius vel pharetra vel. Amet tellus cras adipiscing enim. Volutpat consequat mauris nunc congue nisi vitae. Nisl vel pretium lectus quam id. Diam phasellus vestibulum lorem sed risus ultricies. Magna sit amet purus gravida quis blandit turpis. Mauris nunc congue nisi vitae suscipit tellus mauris. Eget mauris pharetra et ultrices neque ornare aenean. Nisi quis eleifend quam adipiscing vitae. Faucibus vitae aliquet nec ullamcorper sit amet risus nullam. Eu scelerisque felis imperdiet proin fermentum leo vel orci. Ultrices dui sapien eget mi proin. Varius sit amet mattis vulputate. Volutpat maecenas volutpat blandit aliquam etiam erat velit scelerisque in. Neque vitae tempus quam pellentesque nec nam aliquam sem.
        Vulputate dignissim suspendisse in est ante in nibh mauris cursus. Elit ut aliquam purus sit. Nunc congue nisi vitae suscipit tellus mauris a diam maecenas. Massa id neque aliquam vestibulum morbi blandit. Lorem ipsum dolor sit amet. Cras adipiscing enim eu turpis egestas pretium. Mi eget mauris pharetra et ultrices neque ornare aenean. At auctor urna nunc id cursus metus. Neque sodales ut etiam sit amet nisl. Urna et pharetra pharetra massa massa ultricies. Sed viverra ipsum nunc aliquet bibendum enim facilisis. Semper eget duis at tellus at urna.
        Nibh tellus molestie nunc non. Senectus et netus et malesuada fames ac turpis. Aliquam sem et tortor consequat id porta nibh. Et netus et malesuada fames. In vitae turpis massa sed. Massa tincidunt dui ut ornare lectus. Proin fermentum leo vel orci. Sagittis vitae et leo duis ut diam quam. Quam id leo in vitae turpis. Ut tellus elementum sagittis vitae et.
        Neque convallis a cras semper auctor neque vitae tempus quam. Enim blandit volutpat maecenas volutpat blandit aliquam etiam erat. Metus vulputate eu scelerisque felis. Libero justo laoreet sit amet cursus sit. Donec enim diam vulputate ut pharetra sit. A pellentesque sit amet porttitor. Lectus arcu bibendum at varius vel. Ac placerat vestibulum lectus mauris ultrices eros in cursus. Nec dui nunc mattis enim ut tellus elementum sagittis vitae. Risus in hendrerit gravida rutrum quisque non tellus. Aliquam malesuada bibendum arcu vitae elementum curabitur vitae nunc. At tellus at urna condimentum mattis pellentesque id nibh. Ultricies lacus sed turpis tincidunt id aliquet. Nunc scelerisque viverra mauris in.
        Id venenatis a condimentum vitae sapien pellentesque. At varius vel pharetra vel turpis nunc eget lorem. Nunc vel risus commodo viverra maecenas accumsan lacus vel. Tristique risus nec feugiat in. Donec et odio pellentesque diam volutpat commodo sed. Feugiat nibh sed pulvinar proin gravida hendrerit. Suspendisse ultrices gravida dictum fusce ut placerat orci nulla pellentesque. Nulla porttitor massa id neque aliquam vestibulum morbi. Egestas tellus rutrum tellus pellentesque eu. Eu volutpat odio facilisis mauris sit. Risus ultricies tristique nulla aliquet enim tortor at. Amet purus gravida quis blandit turpis cursus in hac habitasse. Odio morbi quis commodo odio. Nisi quis eleifend quam adipiscing vitae proin sagittis. Vitae turpis massa sed elementum tempus egestas. Euismod lacinia at quis risus sed.
        Cursus mattis molestie a iaculis at. Vel pretium lectus quam id leo. Ac tortor vitae purus faucibus ornare suspendisse sed. Quam id leo in vitae turpis massa sed elementum. Molestie at elementum eu facilisis sed odio. Libero volutpat sed cras ornare arcu dui vivamus arcu felis. Leo vel fringilla est ullamcorper eget nulla facilisi. Blandit libero volutpat sed cras ornare arcu dui. Odio pellentesque diam volutpat commodo sed egestas egestas fringilla phasellus. Est placerat in egestas erat imperdiet sed euismod nisi porta. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Ornare suspendisse sed nisi lacus sed viverra tellus. Luctus accumsan tortor posuere ac. Nisi vitae suscipit tellus mauris a diam. Arcu cursus euismod quis viverra nibh cras pulvinar. Quis viverra nibh cras pulvinar mattis nunc. Est sit amet facilisis magna etiam tempor orci eu. Adipiscing commodo elit at imperdiet dui.
        Aliquam ultrices sagittis orci a scelerisque. Tellus integer feugiat scelerisque varius morbi enim nunc faucibus a. Massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada. Amet facilisis magna etiam tempor orci eu lobortis elementum nibh. Velit euismod in pellentesque massa placerat duis. Enim blandit volutpat maecenas volutpat blandit. Et leo duis ut diam quam nulla. Rhoncus aenean vel elit scelerisque. Faucibus nisl tincidunt eget nullam. Imperdiet massa tincidunt nunc pulvinar sapien et ligula.
        Id venenatis a condimentum vitae sapien pellentesque habitant. Purus sit amet volutpat consequat mauris nunc congue nisi vitae. Ornare quam viverra orci sagittis eu volutpat odio. Sed ullamcorper morbi tincidunt ornare massa eget egestas purus. Tortor consequat id porta nibh. In eu mi bibendum neque egestas congue. Nunc aliquet bibendum enim facilisis gravida neque convallis. Id aliquet risus feugiat in ante metus. Magna ac placerat vestibulum lectus mauris ultrices eros in cursus. Placerat duis ultricies lacus sed turpis tincidunt id. Egestas congue quisque egestas diam in. Proin fermentum leo vel orci porta non pulvinar neque laoreet. Porttitor leo a diam sollicitudin tempor id eu nisl nunc. Mauris ultrices eros in cursus turpis massa tincidunt. Sit amet massa vitae tortor condimentum lacinia quis vel eros. Quis commodo odio aenean sed adipiscing diam donec adipiscing tristique. Viverra accumsan in nisl nisi scelerisque. Cursus euismod quis viverra nibh cras.
        Volutpat maecenas volutpat blandit aliquam. Venenatis tellus in metus vulputate eu scelerisque felis. Venenatis tellus in metus vulputate eu scelerisque. Egestas purus viverra accumsan in nisl nisi. Leo urna molestie at elementum eu facilisis sed odio. Sem fringilla ut morbi tincidunt. Turpis nunc eget lorem dolor sed viverra. Felis eget nunc lobortis mattis. Placerat vestibulum lectus mauris ultrices eros in cursus turpis. Nisi lacus sed viverra tellus in hac habitasse. Leo vel fringilla est ullamcorper eget nulla. Quisque id diam vel quam elementum pulvinar etiam non. Faucibus a pellentesque sit amet porttitor eget. Ullamcorper eget nulla facilisi etiam dignissim diam quis. Quis ipsum suspendisse ultrices gravida dictum fusce ut placerat orci. Nibh nisl condimentum id venenatis a condimentum. Egestas maecenas pharetra convallis posuere. Nisi porta lorem mollis aliquam ut porttitor. Sem nulla pharetra diam sit amet nisl.
        Leo a diam sollicitudin tempor id eu nisl. Non sodales neque sodales ut etiam sit amet nisl. Faucibus nisl tincidunt eget nullam. Imperdiet dui accumsan sit amet nulla facilisi morbi tempus. Morbi tempus iaculis urna id. Pellentesque eu tincidunt tortor aliquam nulla facilisi. Orci dapibus ultrices in iaculis nunc sed augue. Et leo duis ut diam quam nulla. Neque aliquam vestibulum morbi blandit cursus risus at. Augue eget arcu dictum varius. Porttitor massa id neque aliquam vestibulum.
        Tortor dignissim convallis aenean et. Habitant morbi tristique senectus et netus et malesuada fames ac. Maecenas volutpat blandit aliquam etiam. Non blandit massa enim nec dui. Ultricies tristique nulla aliquet enim tortor at auctor. Ornare arcu odio ut sem. Tellus mauris a diam maecenas. Nisi scelerisque eu ultrices vitae auctor eu. Vitae nunc sed velit dignissim sodales ut. Lorem ipsum dolor sit amet consectetur adipiscing elit pellentesque. Eget mi proin sed libero enim sed faucibus.
        Proin nibh nisl condimentum id venenatis a. Blandit cursus risus at ultrices mi. Est sit amet facilisis magna etiam tempor orci eu. Lobortis mattis aliquam faucibus purus in massa tempor nec. Quam pellentesque nec nam aliquam. Sit amet facilisis magna etiam tempor orci eu lobortis elementum. Diam vulputate ut pharetra sit amet aliquam id. Morbi tristique senectus et netus et malesuada fames ac. At risus viverra adipiscing at in. Sed arcu non odio euismod lacinia at quis risus. Feugiat in ante metus dictum at. Dignissim cras tincidunt lobortis feugiat vivamus at augue. Pellentesque habitant morbi tristique senectus et netus et malesuada. Bibendum est ultricies integer quis auctor elit sed vulputate mi. Magna ac placerat vestibulum lectus mauris ultrices eros.
        Tempor nec feugiat nisl pretium fusce id velit ut. Risus nullam eget felis eget nunc lobortis mattis aliquam. Diam volutpat commodo sed egestas egestas fringilla phasellus faucibus. Malesuada fames ac turpis egestas sed tempus. Nunc aliquet bibendum enim facilisis gravida neque. Tristique sollicitudin nibh sit amet. Praesent tristique magna sit amet purus gravida quis blandit. Elementum nisi quis eleifend quam adipiscing vitae. Vehicula ipsum a arcu cursus vitae. Quam vulputate dignissim suspendisse in est. Mauris ultrices eros in cursus turpis massa tincidunt dui ut. Vestibulum morbi blandit cursus risus at ultrices mi tempus.
        """
    // swiftlint:enable line_length
}
