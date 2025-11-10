import ballerina/io;
import ballerinax/apple.music;

configurable string accessToken = ?;
configurable string musicUserToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    
    // Initialize Apple Music client
    music:ApiKeysConfig apiKeyConfig = {
        authorization: accessToken,
        musicUserToken: musicUserToken
    };
    music:Client appleMusic = check new(apiKeyConfig = apiKeyConfig);
    
    io:println("🎵 Starting Music Discovery Workflow");
    io:println("=====================================");
    
    // Step 1: Search for trending rock artists
    io:println("\n🔍 Step 1: Searching for rock artists...");
    
    music:GetSearchResponseFromCatalogQueries searchQuery = {
        term: "rock+artists",
        types: ["artists"],
        'limit: 10
    };
    
    music:SearchResponse searchResults = check appleMusic->/catalog/[storefront]/search(queries = searchQuery);
    
    if searchResults.results.artists is music:ArtistsResponse {
        music:ArtistsResponse artistsResponse = <music:ArtistsResponse>searchResults.results.artists;
        io:println(string `Found ${artistsResponse.data.length()} rock artists`);
        
        if artistsResponse.data.length() > 0 {
            music:Artists firstArtist = artistsResponse.data[0];
            io:println(string `Selected artist: ${firstArtist.id}`);
            
            // Step 2: Get top songs for the selected artist
            io:println(string `\n🎤 Step 2: Getting top songs for artist ${firstArtist.id}...`);
            
            music:GetArtistViewFromCatalogQueries topSongsQuery = {
                'limit: 10
            };
            
            music:AlbumsResponse topSongsResponse = check appleMusic->/catalog/[storefront]/artists/[firstArtist.id]/view/["top-songs"](queries = topSongsQuery);
            
            io:println(string `Found ${topSongsResponse.data.length()} top albums/songs`);
            
            // Step 3: Get similar artists for music discovery
            io:println(string `\n🔗 Step 3: Finding similar artists to ${firstArtist.id}...`);
            
            music:GetArtistViewFromCatalogQueries similarArtistsQuery = {
                'limit: 5
            };
            
            music:AlbumsResponse|error similarArtistsResult = appleMusic->/catalog/[storefront]/artists/[firstArtist.id]/view/["similar-artists"](queries = similarArtistsQuery);
            
            if similarArtistsResult is music:AlbumsResponse {
                io:println(string `Found ${similarArtistsResult.data.length()} similar artists`);
            } else {
                io:println("Could not retrieve similar artists");
            }
            
            // Step 4: Add discovered tracks to personal library
            io:println("\n📚 Step 4: Adding discovered tracks to personal library...");
            
            // Collect song IDs from the top songs response
            string[] songIds = [];
            foreach music:Albums album in topSongsResponse.data {
                string[]? genreNames = album.attributes?.genreNames;
                if genreNames is string[] && genreNames.length() > 0 {
                    songIds.push(album.id);
                }
                if songIds.length() >= 3 {
                    break;
                }
            }
            
            if songIds.length() > 0 {
                music:AddToLibraryQueries libraryQuery = {
                    ids: songIds.map(id => <music:AddToLibraryQueriesIdsItemsString>string `${id}:albums`)
                };
                
                error? addResult = appleMusic->/me/library.post(queries = libraryQuery);
                
                if addResult is () {
                    io:println(string `Successfully added ${songIds.length()} items to library`);
                } else {
                    io:println("Failed to add items to library: " + addResult.message());
                }
            } else {
                io:println("No suitable tracks found to add to library");
            }
            
            // Step 5: Display workflow summary
            io:println("\n📊 Workflow Summary:");
            io:println("====================");
            io:println("✅ Searched for rock artists");
            io:println("✅ Retrieved top songs for selected artist");
            io:println("✅ Discovered similar artists");
            io:println("✅ Added tracks to personal library");
            io:println("\n🎉 Music discovery workflow completed successfully!");
            
        } else {
            io:println("No artists found in search results");
        }
    } else {
        io:println("No artists found in search response");
    }
}