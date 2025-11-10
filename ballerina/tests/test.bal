// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/os;
import ballerina/test;
import apple.music.mock.server as _;

configurable boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
configurable string serviceUrl = isLiveServer ? "https://api.music.apple.com/v1" : "http://localhost:9090";

ConnectionConfig config = {};
final Client appleMusicClient = check new Client(serviceUrl, config);

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetMultipleCatalogAlbums() returns error? {
    AlbumsResponse response = check appleMusicClient->/catalog/us/albums(ids = ["1234567890", "0987654321"]);
    Albums[]? albumsData = response.data;
    if albumsData is Albums[] {
        test:assertTrue(albumsData.length() > 0, "Expected a non-empty albums array");
    } else {
        test:assertFail("Expected albums data to be present");
    }
}