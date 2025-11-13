import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    
    // Initialize the Apple Music client
    music:ApiKeysConfig apiKeyConfig = {
        authorization: developerToken,
        musicUserToken: userToken
    };
    
    music:Client appleMusicClient = check new(apiKeyConfig = apiKeyConfig);
    
    // Step 1: Search for a specific artist
    string artistName = "Taylor Swift";
    io:println("🔍 Searching for artist: " + artistName);
    
    music:GetSearchResponseFromCatalogQueries searchQueries = {
        term: artistName,
        types: ["artists"],
        'limit: 5
    };
    
    music:SearchResponse searchResponse = check appleMusicClient->/catalog/[storefront]/search(queries = searchQueries);
    
    music:ArtistsResponse? artistsResponse = searchResponse.results.artists;
    if artistsResponse is () {
        io:println("❌ No artists found for: " + artistName);
        return;
    }
    
    music:Artists[] artistsData = artistsResponse.data;
    if artistsData.length() == 0 {
        io:println("❌ No artists found for: " + artistName);
        return;
    }
    
    music:Artists firstArtist = artistsData[0];
    string artistId = firstArtist.id;
    io:println("✅ Found artist: " + (firstArtist.attributes?.name ?: "Unknown") + " (ID: " + artistId + ")");
    
    // Step 2: Explore the artist's top songs to discover new music
    io:println("\n🎵 Fetching top songs for music discovery...");
    
    music:GetArtistViewFromCatalogQueries topSongsQueries = {
        'limit: 10
    };
    
    music:AlbumsResponse topSongsResponse = check appleMusicClient->/catalog/[storefront]/artists/[artistId]/view/["top-songs"](queries = topSongsQueries);
    
    io:println("📀 Found " + topSongsResponse.data.length().toString() + " top albums/compilations");
    
    // Display discovered music
    string[] interestingTrackIds = [];
    foreach int i in 0..<topSongsResponse.data.length() {
        music:Albums album = topSongsResponse.data[i];
        string albumName = album.attributes?.name ?: "Unknown Album";
        string releaseDate = album.attributes?.releaseDate ?: "Unknown";
        io:println("  " + (i + 1).toString() + ". " + albumName + " (Released: " + releaseDate + ")");
        
        // Simulate selecting interesting tracks (using album IDs as track IDs for demo)
        if i < 3 {
            interestingTrackIds.push(album.id);
        }
    }
    
    // Step 3: Add interesting tracks to personal library
    if interestingTrackIds.length() > 0 {
        io:println("\n📚 Adding " + interestingTrackIds.length().toString() + " interesting items to personal library...");
        
        music:AddToLibraryQueriesIdsItemsString[] libraryIds = [];
        foreach string trackId in interestingTrackIds {
            libraryIds.push(trackId);
        }
        
        music:AddToLibraryQueries addToLibraryQueries = {
            ids: libraryIds
        };
        
        error? addResult = appleMusicClient->/me/library.post(queries = addToLibraryQueries);
        
        if addResult is error {
            io:println("❌ Failed to add items to library: " + addResult.message());
        } else {
            io:println("✅ Successfully added items to your personal library for later listening!");
        }
    }
    
    io:println("\n🎉 Music discovery and library management workflow completed!");
    io:println("You've discovered new music from " + artistName + " and saved your favorites to your library.");
}