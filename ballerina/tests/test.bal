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
configurable string authorization = isLiveServer ? os:getEnv("APPLE_MUSIC_AUTHORIZATION") : "test_authorization";
configurable string musicUserToken = isLiveServer ? os:getEnv("APPLE_MUSIC_USER_TOKEN") : "test_user_token";
configurable string serviceUrl = isLiveServer ? "https://api.music.apple.com/v1" : "http://localhost:9090/v1";

ApiKeysConfig apiKeyConfig = {authorization, musicUserToken};
ConnectionConfig config = {};
final Client appleMusicClient = check new Client(apiKeyConfig, config, serviceUrl);

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetMultipleCatalogAlbums() returns error? {
    AlbumsResponse response = check appleMusicClient->/catalog/us/albums(ids = ["1440857781"]);
    test:assertTrue(response.data.length() > 0, "Expected non-empty albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogAlbum() returns error? {
    AlbumsResponse response = check appleMusicClient->/catalog/us/albums/["1440857781"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogAlbumRelationship() returns error? {
    ArtistsResponse response = check appleMusicClient->/catalog/us/albums/["1440857781"]/artists();
    test:assertTrue(response.data.length() > 0, "Expected non-empty artists array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogAlbumRelationshipView() returns error? {
    MusicVideosResponse response = check appleMusicClient->/catalog/us/albums/["1440857781"]/view/["related-videos"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty music videos array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetMultipleCatalogArtists() returns error? {
    ArtistsResponse response = check appleMusicClient->/catalog/us/artists(ids = ["136975"]);
    test:assertTrue(response.data.length() > 0, "Expected non-empty artists array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogArtist() returns error? {
    ArtistsResponse response = check appleMusicClient->/catalog/us/artists/["136975"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty artists array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogArtistRelationship() returns error? {
    AlbumsResponse response = check appleMusicClient->/catalog/us/artists/["136975"]/albums();
    test:assertTrue(response.data.length() > 0, "Expected non-empty albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogArtistRelationshipView() returns error? {
    AlbumsResponse response = check appleMusicClient->/catalog/us/artists/["136975"]/view/["full-albums"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testSearchCatalogResources() returns error? {
    SearchResponse response = check appleMusicClient->/catalog/us/search(term = "beatles");
    SearchResponseResults? searchResults = response?.results;
    test:assertTrue(searchResults !is (), "Expected search results to be present");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetMultipleCatalogSongs() returns error? {
    SongsResponse response = check appleMusicClient->/catalog/us/songs(ids = ["1440857781"]);
    test:assertTrue(response.data.length() > 0, "Expected non-empty songs array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogSong() returns error? {
    SongsResponse response = check appleMusicClient->/catalog/us/songs/["1440857781"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty songs array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetCatalogSongRelationship() returns error? {
    SongsResponse response = check appleMusicClient->/catalog/us/songs/["1440857781"]/albums();
    test:assertTrue(response.data.length() > 0, "Expected non-empty songs array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetAllLibraryAlbums() returns error? {
    LibraryAlbumsResponse response = check appleMusicClient->/me/library/albums();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetLibraryAlbum() returns error? {
    LibraryAlbumsResponse response = check appleMusicClient->/me/library/albums/["l.abc123"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetLibraryAlbumRelationship() returns error? {
    LibraryArtistsResponse response = check appleMusicClient->/me/library/albums/["l.abc123"]/artists();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library artists array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetAllLibraryArtists() returns error? {
    LibraryArtistsResponse response = check appleMusicClient->/me/library/artists();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library artists array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetLibraryArtist() returns error? {
    LibraryArtistsResponse response = check appleMusicClient->/me/library/artists/["l.artist123"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library artists array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetLibraryArtistRelationship() returns error? {
    LibraryAlbumsResponse response = check appleMusicClient->/me/library/artists/["l.artist123"]/albums();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library albums array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetAllLibrarySongs() returns error? {
    LibrarySongsResponse response = check appleMusicClient->/me/library/songs();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library songs array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetLibrarySong() returns error? {
    LibrarySongsResponse response = check appleMusicClient->/me/library/songs/["l.song123"]();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library songs array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetLibrarySongRelationship() returns error? {
    LibrarySongsResponse response = check appleMusicClient->/me/library/songs/["l.song123"]/albums();
    test:assertTrue(response.data.length() > 0, "Expected non-empty library songs array");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testAddResourceToLibrary() returns error? {
    error? response = check appleMusicClient->/me/library.post(ids = ["1440857781"]);
    test:assertTrue(response is (), "Expected no error on successful post");
}