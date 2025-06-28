//
//  ReportInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 3/30/22.
//

import Foundation

//  MARK: Interactor
protocol ReportInteractable {
  func reportComment(id: String, body: String?, response: LoadableSubject<Response>)
  func reportReview(id: String, body: String?, response: LoadableSubject<Response>)
  func reportUser(id: String, body: String?, response: LoadableSubject<Response>)
}

struct ReportInteractor: ReportInteractable {
  let api: ReportAPI
  
  func reportReview(id: String, body: String?, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.report(body: ["object_id": id, "object_type": "review", "body": body ?? ""])
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func reportComment(id: String, body: String?, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.report(body: ["object_id": id, "object_type": "comment", "body": body ?? ""])
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func reportUser(id: String, body: String?, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.report(body: ["object_id": id, "object_type": "user", "body": body ?? ""])
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
}

struct StubReportInteractor: ReportInteractable {
  func reportReview(id: String, body: String?, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReportInteractor")
  }
  
  func reportComment(id: String, body: String?, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReportInteractor")
  }
  
  func reportUser(id: String, body: String?, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReportInteractor")
  }
}
