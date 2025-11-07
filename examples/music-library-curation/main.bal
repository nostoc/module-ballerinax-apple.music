import ballerina/io;
import ballerinax/apple.music;

configurable string userToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    
    // Initialize Apple Music client
    music:ApiKeysConfig apiKeysConfig = {
        authorization: userToken,
        musicUserToken: userToken
    };
    music:Client appleMusicClient = check new(apiKeysConfig);
    
    // Step 1: Search for a specific artist
    io:println("=== Step 1: Searching for artist ===");
    string artistSearchTerm = "taylor+swift";
    
    music:GetSearchResponseFromCatalogQueries searchQueries = {
        term: artistSearchTerm,
        types: ["artists"],
        'limit: 5
    };
    
    music:SearchResponse searchResponse = check appleMusicClient->/catalog/[storefront]/search(queries = searchQueries);
    
    music:ArtistsResponse? artistsResult = searchResponse.results.artists;
    if artistsResult is () {
        io:println("No artists found for the search term");
        return;
    }
    
    music:Artists[] artistsData = artistsResult.data;
    if artistsData.length() == 0 {
        io:println("No artists found for the search term");
        return;
    }
    
    music:Artists targetArtist = artistsData[0];
    io:println(string `Found artist: ${targetArtist.id}`);
    
    // Step 2: Get top songs for the artist
    io:println("=== Step 2: Retrieving artist's top songs ===");
    
    music:GetArtistViewFromCatalogQueries topSongsQueries = {
        'limit: 10
    };
    
    music:AlbumsResponse topSongsResponse = check appleMusicClient->/catalog/[storefront]/artists/[targetArtist.id]/view/["top-songs"](queries = topSongsQueries);
    
    io:println(string `Retrieved ${topSongsResponse.data.length()} albums containing top songs`);
    
    // Step 3: Search for songs to get specific song IDs
    io:println("=== Step 3: Searching for specific songs to add to library ===");
    
    music:GetSearchResponseFromCatalogQueries songSearchQueries = {
        term: "shake+it+off+taylor+swift",
        types: ["songs"],
        'limit: 3
    };
    
    music:SearchResponse songSearchResponse = check appleMusicClient->/catalog/[storefront]/search(queries = songSearchQueries);
    
    // Step 4: Add selected songs to personal library
    io:println("=== Step 4: Adding songs to personal library ===");
    
    // Prepare song IDs for library addition
    music:AddToLibraryQueriesIdsItemsString[] songIds = [
        "songs:1440818840",
        "songs:1440818842"
    ];
    
    music:AddToLibraryQueries addToLibraryQueries = {
        ids: songIds
    };
    
    map<string|string[]> authHeaders = {
        "Authorization": string `Bearer ${userToken}`
    };
    
    error? addResult = appleMusicClient->/me/library.post(headers = authHeaders, queries = addToLibraryQueries);
    
    if addResult is error {
        io:println(string `Error adding songs to library: ${addResult.message()}`);
    } else {
        io:println("Successfully added songs to personal library!");
    }
    
    // Step 5: Display summary
    io:println("=== Music Discovery Summary ===");
    io:println(string `Artist searched: ${artistSearchTerm}`);
    io:println(string `Top songs albums retrieved: ${topSongsResponse.data.length()}`);
    io:println(string `Songs added to library: ${songIds.length()}`);
    io:println("Music discovery and curation workflow completed!");
}