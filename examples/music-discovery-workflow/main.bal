import ballerina/io;
import ballerinax/apple.music;

configurable string userToken = ?;
configurable string developerToken = ?;

public function main() returns error? {
    
    music:Client appleMusicClient = check new({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("=== Music Discovery and Personalization Workflow ===\n");

    // Step 1: Search for music based on user preferences
    io:println("Step 1: Searching for rock music in the catalog...");
    
    music:SearchResponse searchResults = check appleMusicClient->/catalog/["us"]/search(
        term = "rock+alternative",
        types = ["songs", "albums", "artists"],
        'limit = 10
    );
    
    io:println("Search completed successfully!");
    
    // Display search results summary
    music:SearchResponseResults? results = searchResults.results;
    if results is music:SearchResponseResults {
        music:AlbumsResponse? albums = results.albums;
        if albums is music:AlbumsResponse {
            io:println(string `Found ${albums.data.length()} albums`);
        }
        
        music:ArtistsResponse? artists = results.artists;
        if artists is music:ArtistsResponse {
            io:println(string `Found ${artists.data.length()} artists`);
        }
    }
    
    io:println("");

    // Step 2: Get detailed information about a promising track
    io:println("Step 2: Retrieving detailed information about a specific song...");
    
    string sampleSongId = "1440857781";
    
    music:SongsResponse songDetails = check appleMusicClient->/catalog/["us"]/songs/[sampleSongId](
        include = ["albums", "artists"],
        extend = ["artistUrl"]
    );
    
    io:println("Song details retrieved successfully!");
    
    // Display song information
    if songDetails.data.length() > 0 {
        music:Songs songItem = songDetails.data[0];
        io:println(string `Song ID: ${songItem.id}`);
        io:println(string `Type: ${songItem.'type}`);
        
        music:SongsAttributes? attributes = songItem.attributes;
        if attributes is music:SongsAttributes {
            string? albumName = attributes.albumName;
            if albumName is string {
                io:println(string `Album: ${albumName}`);
            }
            
            string[]? genreNames = attributes.genreNames;
            if genreNames is string[] {
                io:println(string `Genres: ${genreNames.toString()}`);
            }
            
            int? durationInMillis = attributes.durationInMillis;
            if durationInMillis is int {
                io:println(string `Duration: ${durationInMillis}ms`);
            }
            
            decimal? trackNumber = attributes.trackNumber;
            if trackNumber is decimal {
                io:println(string `Track Number: ${trackNumber.toString()}`);
            }
        }
    }
    
    io:println("");

    // Step 3: Add selected discoveries to user's personal library
    io:println("Step 3: Adding discovered music to personal library...");
    
    string[] discoveredSongIds = [sampleSongId, "1440857782"];
    string[] libraryIds = [];
    
    foreach string songId in discoveredSongIds {
        libraryIds.push(string `songs:${songId}`);
    }
    
    error? addResult = appleMusicClient->/me/library.post(
        ids = libraryIds
    );
    
    if addResult is error {
        io:println(string `Error adding to library: ${addResult.message()}`);
    } else {
        io:println("Successfully added discovered songs to personal library!");
        io:println(string `Added ${libraryIds.length()} songs to library`);
    }
    
    io:println("");
    io:println("=== Music Discovery Workflow Complete ===");
    io:println("Users can now enjoy their personalized music discoveries!");
}