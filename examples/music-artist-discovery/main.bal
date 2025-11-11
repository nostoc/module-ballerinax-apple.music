import ballerina/io;
import ballerina/regex;
import ballerinax/apple.music;

configurable string developerToken = ?;

public function main() returns error? {
    
    music:Client appleMusicClient = check new ({
        authorization: developerToken,
        musicUserToken: ""
    });

    string storefront = "us";
    string searchTerm = "bohemian+rhapsody";
    
    io:println("=== Music Discovery Service ===");
    string displayTerm = regex:replaceAll(searchTerm, "\\+", " ");
    io:println("Searching for song: " + displayTerm);
    
    music:GetSearchResponseFromCatalogQueries searchQuery = {
        term: searchTerm,
        types: ["songs"],
        'limit: 5
    };
    
    music:SearchResponse searchResults = check appleMusicClient->/catalog/[storefront]/search(queries = searchQuery);
    
    if searchResults.results.albums is () {
        io:println("No songs found in search results");
        return;
    }
    
    io:println("Search completed successfully");
    io:println("Found songs in search results");
    
    string songId = "1193701392";
    io:println("\n=== Retrieving Song Artists ===");
    io:println("Getting artists for song ID: " + songId);
    
    music:GetSongsRelationshipFromCatalogQueries artistQuery = {
        'limit: 10
    };
    
    music:SongsResponse songArtists = check appleMusicClient->/catalog/[storefront]/songs/[songId]/artists(queries = artistQuery);
    
    io:println("Retrieved " + songArtists.data.length().toString() + " artists");
    
    if songArtists.data.length() > 0 {
        string firstArtistId = songArtists.data[0].id;
        io:println("Primary artist ID: " + firstArtistId);
        
        io:println("\n=== Finding Similar Artists ===");
        io:println("Discovering artists similar to: " + firstArtistId);
        
        music:GetArtistViewFromCatalogQueries similarArtistsQuery = {
            'limit: 10
        };
        
        music:AlbumsResponse|error similarArtistsResult = appleMusicClient->/catalog/[storefront]/artists/[firstArtistId]/view/["similar-artists"](queries = similarArtistsQuery);
        
        if similarArtistsResult is music:AlbumsResponse {
            io:println("Found " + similarArtistsResult.data.length().toString() + " similar artists");
            
            io:println("\n=== Music Recommendations ===");
            foreach int i in 0..<similarArtistsResult.data.length() {
                music:Albums artist = similarArtistsResult.data[i];
                io:println("Recommendation " + (i + 1).toString() + ": Artist ID " + artist.id);
            }
            
            io:println("\n=== Discovery Complete ===");
            io:println("Music discovery workflow completed successfully!");
            io:println("Users can now explore these similar artists for personalized recommendations");
        } else {
            io:println("Error retrieving similar artists: " + similarArtistsResult.message());
        }
    } else {
        io:println("No artists found for the song");
    }
}