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

    static func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    static func openMainScreen() {
        let openMainScreenParams: [String: String] = [
            "event": "open",
            "screen": "Main"]
        AnalyticsService.report(event: "openMainScreen", params: openMainScreenParams)
    }

    static func closeMainScreen() {
        let closeMainScreenParams: [String: String] = [
            "event": "close",
            "screen": "Main"]
        AnalyticsService.report(event: "closeMainScreen", params: closeMainScreenParams)
    }

    static func addTrackerButton() {
        let addTrackerButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "add_track"]
        AnalyticsService.report(event: "addTrackerButtonTapped", params: addTrackerButtonTappedParams)
    }

    static func trackerButtonTapped() {
        let trackerButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "track"]
        AnalyticsService.report(event: "trackerButtonTapped", params: trackerButtonTappedParams)
    }

    static func filterButtonTapped() {
        let filterButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "filter"]
        AnalyticsService.report(event: "filterButtonTapped", params: filterButtonTappedParams)
    }

    static func editButtonTapped() {
        let editButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "edit"]
        AnalyticsService.report(event: "editButtonTappedParams", params: editButtonTappedParams)
    }

    static func deleteButtonTapped() {
        let deleteButtonTappedParams: [String: String] = [
            "event": "click",
            "screen": "Main",
            "item": "delete"]
        AnalyticsService.report(event: "deleteButtonTapped", params: deleteButtonTappedParams)
    }
}
