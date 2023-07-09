/*
See LICENSE folder for this sample’s licensing information.
*/

import AVFoundation
import Foundation
import Speech
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
public class SpeechRecognizer {
    public enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        public var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    private var recordingSetup: Task<Void, Error>
    private var transcript: String = ""
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    /// Initializes a new speech recognizer. If this is the first time you've used the class, it
    /// requests access to the speech recognizer and the microphone.
    public init() {
        recognizer = SFSpeechRecognizer()
        recordingSetup = Task(priority: .background) { [recognizer] in
            guard recognizer != nil else {
                throw RecognizerError.nilRecognizer
            }
            guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                throw RecognizerError.notAuthorizedToRecognize
            }
            guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                throw RecognizerError.notPermittedToRecord
            }
        }
    }
    
    deinit {
        reset()
    }

    /// Begin transcribing audio.
    ///
    /// Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
    /// The resulting transcription is continuously written to the published `transcript` property.
    @MainActor
    public func startTranscription() async throws {
        do {
            _ = try await recordingSetup.value
            start()
        } catch {
            reset()
            handleError(error)
        }
    }

    @MainActor
    private func start() {
        Task.detached(priority: .background) { [weak self] in
            guard let self, let recognizer, recognizer.isAvailable else {
                self?.handleError(RecognizerError.recognizerIsUnavailable)
                return
            }

            do {
                try startRecognitionTask(recognizer: recognizer)
            } catch {
                self.reset()
                self.handleError(error)
            }
        }

    }
    
    /// Stop transcribing audio.
    public func finishTranscription() -> String {
        reset()
        return transcript
    }
    
    /// Reset the speech recognizer.
    public func reset() {
        speechRecognitionTask?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        speechRecognitionTask = nil
    }
    
    private func startRecognitionTask(recognizer: SFSpeechRecognizer) throws {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()

        self.audioEngine = audioEngine
        self.request = request

        self.speechRecognitionTask = recognizer.recognitionTask(
            with: request,
            resultHandler: self.recognitionHandler(result:error:)
        )
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
        }
        
        if let result = result {
            setTranscript(result.bestTranscription.formattedString)
        }
    }
    
    private func setTranscript(_ message: String) {
        transcript = message
    }
    
    private func handleError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
}

public extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

public extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
