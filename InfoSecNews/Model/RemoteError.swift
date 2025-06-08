//
//  RemoteError.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.03.2025.
//

enum RemoteError: Error {
    case badResult
    case timeout

    // MARK: News Resolver Errors

    case emptyParsedData
    case lastDateIsNil
    case maxAttemptsReached

    enum NewsResolver: Error {
        case shitHappened
    }
}
