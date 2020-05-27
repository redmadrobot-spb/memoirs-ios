//
// RemoteLoggerError
// Robologs
//
// Created by Alex Babaev on 27 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

public enum RemoteLoggerError: Error {
    case transportIsNotConfigured
    case transport(RemoteLoggerTransportError?)
}
