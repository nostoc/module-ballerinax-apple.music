import ballerina/io;
import ballerinax/apple.music;

configurable string appleJWT = ?;
configurable string appleUserToken = ?;

public function main() returns error? {
    music:ApiKeysConfig config = {
        authorization: appleJWT,
        musicUserToken: appleUserToken
    };
    
    music:Client appleMusic = check new(config);
    
    io:println("=== Personalized Music Discovery Feature ===");
    io:println("Step 1: Fetching artists from user's personal library...");
    
    music:LibraryArtistsResponse libraryArtistsResponse = check appleMusic->/me/library/artists();
    
    io:println(string`Found ${libraryArtistsResponse.data.length()} artists in user's library`);
    
    foreach music:LibraryArtists libraryArtist in libraryArtistsResponse.data {
        io:println(string`\n--- Processing Artist: ${libraryArtist.attributes?.name ?: "Unknown"} ---`);
        
        music:LibraryAlbumsResponse? albumsRelationship = libraryArtist.relationships?.albums;
        if albumsRelationship is music:LibraryAlbumsResponse {
            io:println(string`Found ${albumsRelationship.data.length()} albums for this artist`);
            
            foreach var album in albumsRelationship.data {
                io:println(string`  Album: ${album.attributes?.name ?: "Unknown Album"}`);
                io:println(string`  Release Date: ${album.attributes?.releaseDate ?: "Unknown"}`);
                io:println(string`  Track Count: ${album.attributes?.trackCount ?: 0}`);
                
                anydata albumRelationshipsData = album.relationships;
                record {| anydata...; |}? albumRelationships = albumRelationshipsData is record {| anydata...; |} ? albumRelationshipsData : ();
                if albumRelationships is record {| anydata...; |} {
                    anydata tracksRelationshipData = albumRelationships["tracks"];
                    record {| anydata...; |}? tracksRelationship = tracksRelationshipData is record {| anydata...; |} ? tracksRelationshipData : ();
                    if tracksRelationship is record {| anydata...; |} {
                        io:println("    Tracks available for detailed analysis");
                    }
                }
            }
        }
        
        anydata catalogRelationshipData = libraryArtist.relationships?.catalog;
        record {| anydata...; |}? catalogRelationship = catalogRelationshipData is record {| anydata...; |} ? catalogRelationshipData : ();
        if catalogRelationship is record {| anydata...; |} {
            io:println("  Catalog reference available for discovering additional albums");
        }
    }
    
    io:println("\n=== Music Discovery Analysis Complete ===");
    io:println("Recommendation engine can now:");
    io:println("- Analyze user's favorite artists and genres");
    io:println("- Suggest similar artists based on library patterns");
    io:println("- Recommend albums user might have missed");
    io:println("- Build personalized playlists from track data");
}