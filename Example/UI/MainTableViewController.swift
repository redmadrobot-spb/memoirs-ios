//
//  MainTableViewController.swift
//  Example
//
//  Created by Roman Mazeev on 27.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    @IBOutlet private var editEndpointBarButtonItem: UIBarButtonItem!
    @IBOutlet private var remoteLoggingSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        remoteLoggingSwitch.isOn = RemoteLoggerService.logger != nil
        editEndpointBarButtonItem.isEnabled = remoteLoggingSwitch.isOn
    }

    @IBAction func remoteLoggingSwitchTapped() {
        editEndpointBarButtonItem.isEnabled = remoteLoggingSwitch.isOn
        if remoteLoggingSwitch.isOn {
            performSegue(withIdentifier: "EndpointViewController", sender: nil)
        } else {
            RemoteLoggerService.logger?.finishLiveSession()
            RemoteLoggerService.logger = nil
        }
    }
}
