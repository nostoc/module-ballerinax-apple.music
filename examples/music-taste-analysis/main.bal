import ballerina/io;
import ballerinax/apple.music;

configurable string authorization = ?;
configurable string musicUserToken = ?;

public function main() returns error? {
    
    music:ApiKeysConfig apiConfig = {
        authorization: authorization,
        musicUserToken: musicUserToken
    };
    
    music:Client appleMusic = check new (apiConfig);
    
    io:println("=== Music Discovery and Artist Analysis Workflow ===");
    io:println("");
    
    // Step 1: Retrieve all artists from user's personal library
    io:println("1. Fetching artists from user's personal library...");
    music:LibraryArtistsResponse libraryArtistsResponse = check appleMusic->/me/library/artists();
    
    io:println(string`Found ${libraryArtistsResponse.data.length()} artists in library`);
    
    string storefront = "us";
    
    // Step 2: Analyze each artist's detailed catalog information
    io:println("");
    io:println("2. Analyzing detailed catalog information for each artist...");
    
    music:Artists[] catalogArtists = [];
    
    foreach music:LibraryArtists libraryArtist in libraryArtistsResponse.data {
        io:println(string`Analyzing artist: ${libraryArtist.attributes?.name ?: "Unknown"}`);
        
        // Get detailed catalog information for the artist
        music:GetArtistFromCatalogQueries catalogQueries = {
            include: ["genres"],
            views: ["similar-artists", "top-songs"]
        };
        
        music:ArtistsResponse|error catalogResponse = appleMusic->/catalog/[storefront]/artists/[libraryArtist.id](queries = catalogQueries);
        
        if catalogResponse is music:ArtistsResponse {
            foreach music:Artists artist in catalogResponse.data {
                catalogArtists.push(artist);
                io:println(string`  - Catalog ID: ${artist.id}`);
            }
        } else {
            io:println(string`  - Could not fetch catalog info: ${catalogResponse.message()}`);
        }
    }
    
    // Step 3: Discover similar artists for music recommendations
    io:println("");
    io:println("3. Discovering similar artists for recommendations...");
    
    music:Albums[] similarArtistAlbums = [];
    int analysisCount = 0;
    
    foreach music:Artists catalogArtist in catalogArtists {
        if analysisCount >= 3 {
            break;
        }
        
        io:println(string`Finding similar artists for: ${catalogArtist.id}`);
        
        music:GetArtistViewFromCatalogQueries viewQueries = {
            'limit: 10,
            include: ["artists"]
        };
        
        music:AlbumsResponse|error similarArtistsResponse = appleMusic->/catalog/[storefront]/artists/[catalogArtist.id]/view/["similar-artists"](queries = viewQueries);
        
        if similarArtistsResponse is music:AlbumsResponse {
            io:println(string`  Found ${similarArtistsResponse.data.length()} similar artist recommendations`);
            
            foreach music:Albums album in similarArtistsResponse.data {
                similarArtistAlbums.push(album);
                io:println(string`    - Album: ${album.attributes?.releaseDate ?: "Unknown date"}`);
                
                if album.attributes?.genreNames is string[] {
                    string[] genres = <string[]>album.attributes?.genreNames;
                    io:println(string`      Genres: ${string:'join(", ", ...genres)}`);
                }
            }
        } else {
            io:println(string`  Could not fetch similar artists: ${similarArtistsResponse.message()}`);
        }
        
        analysisCount += 1;
    }
    
    // Step 4: Generate insights and recommendations
    io:println("");
    io:println("4. Music Taste Analysis Summary:");
    io:println(string`- Total library artists analyzed: ${libraryArtistsResponse.data.length()}`);
    io:println(string`- Catalog artists processed: ${catalogArtists.length()}`);
    io:println(string`- Similar artist recommendations found: ${similarArtistAlbums.length()}`);
    
    // Extract genre insights
    map<int> genreCount = {};
    foreach music:Albums album in similarArtistAlbums {
        if album.attributes?.genreNames is string[] {
            string[] genres = <string[]>album.attributes?.genreNames;
            foreach string genre in genres {
                int? currentCount = genreCount[genre];
                if currentCount is int {
                    genreCount[genre] = currentCount + 1;
                } else {
                    genreCount[genre] = 1;
                }
            }
        }
    }
    
    io:println("");
    io:println("Top recommended genres based on your taste:");
    foreach string genre in genreCount.keys() {
        int? genreCountValue = genreCount[genre];
        if genreCountValue is int {
            io:println(string`  - ${genre}: ${genreCountValue} recommendations`);
        }
    }
    
    io:println("");
    io:println("=== Workflow Complete ===");
}