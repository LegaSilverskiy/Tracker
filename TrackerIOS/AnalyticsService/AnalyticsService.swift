//
//  AnalyticsService.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/27/24.
//

import Foundation

import YandexMobileMetrica

struct AnalyticsService {

    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "ea8e6987-dafd-4123-90cc-8168a1abff4a") else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }

    private func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    func openMainScreen() {
        let openMainScreenParams: [String: String] = [
            "event": "open",
            "screen": "Main"]
        report(event: "openMainScreen", params: openMainScreenParams)
    }

    func closeMainScreen() {
        let closeMainScreenParams: [String: String] = [
            "event": "close",
            "screen": "Main"]
        report(event: "closeMainScreen", params: closeMainScreenParams)
    }

    func addTrackerButton() {
        let addTrackerButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "add_track"]
        report(event: "addTrackerButtonTapped", params: addTrackerButtonTappedParams)
    }

    func trackerButtonTapped() {
        let trackerButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "track"]
        report(event: "trackerButtonTapped", params: trackerButtonTappedParams)
    }

    func filterButtonTapped() {
        let filterButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "filter"]
        report(event: "filterButtonTapped", params: filterButtonTappedParams)
    }

    func editButtonTapped() {
        let editButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "edit"]
        report(event: "editButtonTappedParams", params: editButtonTappedParams)
    }

    func deleteButtonTapped() {
        let deleteButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "delete"]
        report(event: "deleteButtonTapped", params: deleteButtonTappedParams)
    }
}
