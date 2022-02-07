//
//  PXSecurityProfileTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 31/01/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN


class PXSecurityProfileTests: XCTestCase {
    
    private func defaultsKey(_ key: String) -> String {
        return "eu.pretix.pretixscan.ios.\(key)"
    }

    func testPXSecurityProfileDefaultsToFull() {
        let profile = PXSecurityProfile(rawValue: nil)
        XCTAssertEqual(profile, PXSecurityProfile.full)
    }
    
    func testPXSecurityProfileInvalidValuesParsedAsFull() {
        let value: String? = "something which is not a profile we know of"
        let profile = PXSecurityProfile(rawValue: value)
        XCTAssertEqual(profile, PXSecurityProfile.full)
    }
    
    func testPXSecurityProfileSupportsFull() {
        let profile = PXSecurityProfile(rawValue: "full")
        XCTAssertEqual(profile, PXSecurityProfile.full)
    }
    
    func testPXSecurityProfileSupportsKiosk() {
        let profile = PXSecurityProfile(rawValue: "pretixscan_online_kiosk")
        XCTAssertEqual(profile, PXSecurityProfile.kiosk)
    }
    
    func testPXSecurityProfileSupportsNoOrders() {
        let profile = PXSecurityProfile(rawValue: "pretixscan_online_noorders")
        XCTAssertEqual(profile, PXSecurityProfile.noOrders)
    }
    
    func testDefaultsConfigStoreDefaultsToFull() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.removeObject(forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .full)
    }
    
    func testDefaultsConfigStoreLoadsProfileFull() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set(PXSecurityProfile.full.rawValue, forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .full)
    }
    
    func testDefaultsConfigStoreLoadsProfileKiosk() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set(PXSecurityProfile.kiosk.rawValue, forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .kiosk)
    }
    
    func testDefaultsConfigStoreLoadsProfileNoOrders() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set(PXSecurityProfile.noOrders.rawValue, forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .noOrders)
    }
    
    
    // MARK: - Endpoit tests
    private func assertUrlMatchesSingleEndpointInProfile(url: String, method: String, profile: PXSecurityProfile, expectedName: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        
        let endpoints = PXSecurityProfileRequestValidator.matchingEndpoints(for: request, profile: profile)
        
        XCTAssertEqual(endpoints.count, 1, "The endpoint url for \(expectedName) must be matched exactly once. Did you register a regular expression for it?")
        XCTAssertEqual(endpoints[0].0, method)
        XCTAssertEqual(endpoints[0].1, expectedName)
    }
    
    /// This test validates that all URLs have a valid regular expression resulting in a unique endpoint match. The expected name is a string constant usually shared with the server by convention.
    func testProfilePretixScanV1Endpoints() {
    
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:event-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/", method: "GET", profile: .pretixscan, expectedName: "api-v1:event-detail")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:subevent-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/1/", method: "GET", profile: .pretixscan, expectedName: "api-v1:subevent-detail")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/categories/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:itemcategory-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/items/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:item-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/questions/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:question-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:checkinlist-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/status/", method: "GET", profile: .pretixscan, expectedName: "api-v1:checkinlist-status")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/failed_checkins/", method: "POST", profile: .pretixscan, expectedName: "api-v1:checkinlist-failed_checkins")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/", method: "GET", profile: .pretixscan, expectedName: "api-v1:checkinlistpos-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/abc1234/redeem/", method: "POST", profile: .pretixscan, expectedName: "api-v1:checkinlistpos-redeem")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/revokedsecrets/", method: "GET", profile: .pretixscan, expectedName: "api-v1:revokedsecrets-list")
        
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orders/", method: "GET", profile: .pretixscan, expectedName: "api-v1:order-list")
    }
    
    private func assertUrlInProfile(is allowed: Bool, url: String, method: String, profile: PXSecurityProfile, expectedName: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        
        if allowed {
            XCTAssertTrue(PXSecurityProfileRequestValidator.isAllowed(request, profile: profile), "The endpoint url for \(expectedName) is not allowed for this profile.")
        } else {
            XCTAssertFalse(PXSecurityProfileRequestValidator.isAllowed(request, profile: profile), "The endpoint url for \(expectedName) is not allowed for this profile.")
        }
        
    }
    
    /// This test validates that the requests are allowed for a given profile.
    func testProfileFullIsAllowed() {
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/?page=1&ordering=datetime", method: "GET", profile: .full, expectedName: "api-v1:event-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/", method: "GET", profile: .full, expectedName: "api-v1:event-detail")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/?page=1&ordering=datetime", method: "GET", profile: .full, expectedName: "api-v1:subevent-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/1/", method: "GET", profile: .full, expectedName: "api-v1:subevent-detail")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/categories/?page=1&ordering=datetime", method: "GET", profile: .full, expectedName: "api-v1:itemcategory-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/items/?page=1&ordering=datetime", method: "GET", profile: .full, expectedName: "api-v1:item-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/questions/?page=1&ordering=datetime", method: "GET", profile: .full, expectedName: "api-v1:question-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/?page=1&ordering=datetime", method: "GET", profile: .full, expectedName: "api-v1:checkinlist-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/status/", method: "GET", profile: .full, expectedName: "api-v1:checkinlist-status")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/failed_checkins/", method: "POST", profile: .full, expectedName: "api-v1:checkinlist-failed_checkins")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/", method: "GET", profile: .full, expectedName: "api-v1:checkinlistpos-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/abc1234/redeem/", method: "POST", profile: .full, expectedName: "api-v1:checkinlistpos-redeem")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/revokedsecrets/", method: "GET", profile: .full, expectedName: "api-v1:revokedsecrets-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orders/", method: "GET", profile: .full, expectedName: "api-v1:order-list")
    }
    
    /// This test validates that the requests are allowed for a given profile.
    func testProfilePretixScanIsAllowed() {
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:event-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/", method: "GET", profile: .pretixscan, expectedName: "api-v1:event-detail")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:subevent-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/1/", method: "GET", profile: .pretixscan, expectedName: "api-v1:subevent-detail")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/categories/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:itemcategory-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/items/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:item-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/questions/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:question-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:checkinlist-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/status/", method: "GET", profile: .pretixscan, expectedName: "api-v1:checkinlist-status")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/failed_checkins/", method: "POST", profile: .pretixscan, expectedName: "api-v1:checkinlist-failed_checkins")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/", method: "GET", profile: .pretixscan, expectedName: "api-v1:checkinlistpos-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/abc1234/redeem/", method: "POST", profile: .pretixscan, expectedName: "api-v1:checkinlistpos-redeem")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/revokedsecrets/", method: "GET", profile: .pretixscan, expectedName: "api-v1:revokedsecrets-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orders/", method: "GET", profile: .pretixscan, expectedName: "api-v1:order-list")
    }
    
    /// This test validates that the requests are allowed for a given profile.
    func testProfileNoOrdersIsAllowed() {
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/?page=1&ordering=datetime", method: "GET", profile: .noOrders, expectedName: "api-v1:event-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/", method: "GET", profile: .noOrders, expectedName: "api-v1:event-detail")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/?page=1&ordering=datetime", method: "GET", profile: .noOrders, expectedName: "api-v1:subevent-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/1/", method: "GET", profile: .noOrders, expectedName: "api-v1:subevent-detail")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/categories/?page=1&ordering=datetime", method: "GET", profile: .noOrders, expectedName: "api-v1:itemcategory-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/items/?page=1&ordering=datetime", method: "GET", profile: .noOrders, expectedName: "api-v1:item-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/questions/?page=1&ordering=datetime", method: "GET", profile: .noOrders, expectedName: "api-v1:question-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/?page=1&ordering=datetime", method: "GET", profile: .noOrders, expectedName: "api-v1:checkinlist-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/status/", method: "GET", profile: .noOrders, expectedName: "api-v1:checkinlist-status")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/failed_checkins/", method: "POST", profile: .noOrders, expectedName: "api-v1:checkinlist-failed_checkins")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/", method: "GET", profile: .noOrders, expectedName: "api-v1:checkinlistpos-list")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/checkinlists/123/positions/abc1234/redeem/", method: "POST", profile: .noOrders, expectedName: "api-v1:checkinlistpos-redeem")
        
        assertUrlInProfile(is: true, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/revokedsecrets/", method: "GET", profile: .noOrders, expectedName: "api-v1:revokedsecrets-list")
        
        // NOT ALLOWED
        assertUrlInProfile(is: false, url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orders/", method: "GET", profile: .noOrders, expectedName: "api-v1:order-list")
    }
}