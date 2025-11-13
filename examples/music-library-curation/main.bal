import ballerina/io;
import ballerinax/apple.music;

configurable string appleTeamId = ?;
configurable string appleKeyId = ?;
configurable string applePrivateKey = ?;

public function main() returns error? {
    
    // Initialize the Apple Music client
    music:Client appleMusic = check new({
        authorization: {
            teamId: appleTeamId,
            keyId: appleKeyId,
            privateKey: applePrivateKey
        },
        musicUserToken: ""
    });

    io:println("🎵 Starting Music Discovery and Library Curation Workflow");
    
    // Step 1: Search for a favorite artist
    string favoriteArtist = "Taylor Swift";
    string storefront = "us";
    
    io:println(string `\n🔍 Searching for artist: ${favoriteArtist}`);
    
    string searchTerm = favoriteArtist.replace(" ", "+");
    music:SearchResponse searchResponse = check appleMusic->/catalog/[storefront]/search(
        queries = {
            term: searchTerm,
            types: ["artists", "albums"],
            'limit: 10
        }
    );
    
    // Extract artist information from search results
    if searchResponse.results.artists is music:ArtistsResponse {
        music:ArtistsResponse artistsResponse = <music:ArtistsResponse>searchResponse.results.artists;
        if artistsResponse.data.length() > 0 {
            music:Artists artist = artistsResponse.data[0];
            io:println(string `✅ Found artist: ${artist.id}`);
            
            // Step 2: Explore the artist's full album discography
            io:println(string `\n📀 Exploring ${favoriteArtist}'s full album discography...`);
            
            music:AlbumsResponse fullAlbumsResponse = check appleMusic->/catalog/[storefront]/artists/[artist.id]/view/["full-albums"](
                queries = {
                    'limit: 25
                }
            );
            
            io:println(string `Found ${fullAlbumsResponse.data.length()} full albums in discography`);
            
            // Step 3: Display albums and simulate user selection for library
            string[] selectedAlbumIds = [];
            
            io:println("\n🎼 Available Albums:");
            foreach int i in 0 ..< fullAlbumsResponse.data.length() {
                music:Albums album = fullAlbumsResponse.data[i];
                if album.attributes is music:AlbumsAttributes {
                    music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
                    io:println(string `${i + 1}. Album ID: ${album.id}`);
                    io:println(string `   Release Date: ${attrs.releaseDate ?: "Unknown"}`);
                    io:println(string `   Genres: ${string:'join(", ", ...attrs.genreNames)}`);
                    io:println(string `   Apple Digital Master: ${attrs.isMasteredForItunes}`);
                    
                    // Simulate user selection - selecting first 3 albums for library
                    if i < 3 {
                        selectedAlbumIds.push(album.id);
                        io:println("   ⭐ Selected for library");
                    }
                    io:println("");
                }
            }
            
            // Step 4: Add selected albums to personal library
            if selectedAlbumIds.length() > 0 {
                io:println(string `\n📚 Adding ${selectedAlbumIds.length()} selected albums to library...`);
                
                // Prepare album IDs for library addition
                music:AddToLibraryQueriesIdsItemsString[] libraryIds = [];
                foreach string albumId in selectedAlbumIds {
                    libraryIds.push(string `${albumId}:albums`);
                }
                
                error? addResult = appleMusic->/me/library.post(
                    queries = {
                        ids: libraryIds
                    }
                );
                
                if addResult is error {
                    io:println(string `❌ Error adding albums to library: ${addResult.message()}`);
                } else {
                    io:println("✅ Successfully added selected albums to your library for offline listening!");
                }
            }
            
            // Step 5: Also explore latest releases for discovery
            io:println(string `\n🆕 Checking ${favoriteArtist}'s latest releases...`);
            
            music:AlbumsResponse latestResponse = check appleMusic->/catalog/[storefront]/artists/[artist.id]/view/["latest-release"](
                queries = {
                    'limit: 5
                }
            );
            
            io:println(string `Found ${latestResponse.data.length()} latest releases`);
            foreach music:Albums latestAlbum in latestResponse.data {
                if latestAlbum.attributes is music:AlbumsAttributes {
                    music:AlbumsAttributes attrs = <music:AlbumsAttributes>latestAlbum.attributes;
                    io:println(string `🎵 Latest: Album ${latestAlbum.id} (${attrs.releaseDate ?: "Unknown date"})`);
                }
            }
            
        } else {
            io:println("❌ No artists found in search results");
        }
    } else {
        io:println("❌ No artist results returned from search");
    }
    
    io:println("\n🎉 Music discovery and library curation workflow completed!");
}