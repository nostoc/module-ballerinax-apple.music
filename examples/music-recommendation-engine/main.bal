import ballerina/io;
import ballerina/lang.array;
import ballerina/regex;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    music:Client appleMusic = check new ({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("=== Building Personalized Music Recommendation Engine ===\n");

    // Step 1: Retrieve user's library songs to understand music taste
    io:println("Step 1: Analyzing user's music library...");
    music:LibrarySongsResponse libraryResponse = check appleMusic->/me/library/songs.get(
        'limit = 25,
        include = ["albums", "artists"]
    );

    io:println(string `Found ${libraryResponse.data.length()} songs in user's library`);
    
    // Extract genres and artist preferences from library
    map<int> genrePreferences = {};
    string[] favoriteArtistIds = [];
    
    foreach music:LibrarySongs song in libraryResponse.data {
        if song.attributes is music:LibrarySongsAttributes {
            music:LibrarySongsAttributes attrs = <music:LibrarySongsAttributes>song.attributes;
            foreach string genre in attrs.genreNames {
                if genrePreferences.hasKey(genre) {
                    genrePreferences[genre] = genrePreferences.get(genre) + 1;
                } else {
                    genrePreferences[genre] = 1;
                }
            }
        }
        
        // Extract artist IDs from relationships
        if song.relationships is music:LibrarySongsRelationships {
            music:LibrarySongsRelationships rels = <music:LibrarySongsRelationships>song.relationships;
            if rels.artists is music:ArtistsResponse {
                music:ArtistsResponse artistsResp = <music:ArtistsResponse>rels.artists;
                foreach var artist in artistsResp.data {
                    favoriteArtistIds.push(artist.id);
                }
            }
        }
    }

    io:println("User's top genres:");
    foreach var [genre, count] in genrePreferences.entries() {
        io:println(string `  - ${genre}: ${count} songs`);
    }

    // Step 2: Get detailed information about favorite artists
    io:println("\nStep 2: Analyzing favorite artists' genres and styles...");
    map<string[]> artistGenres = {};
    
    // Take first 5 artists to avoid too many API calls
    string[] topArtists = favoriteArtistIds.slice(0, 5);
    
    foreach string artistId in topArtists {
        music:LibraryAlbumsResponse|error artistGenresResult = appleMusic->/me/library/artists/[artistId]/genres.get(
            'limit = 10
        );
        
        if artistGenresResult is music:LibraryAlbumsResponse {
            string[] genres = [];
            foreach var album in artistGenresResult.data {
                if album.attributes is music:LibraryAlbumsAttributes {
                    music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
                    foreach string genre in attrs.genreNames {
                        if genres.indexOf(genre) is () {
                            genres.push(genre);
                        }
                    }
                }
            }
            artistGenres[artistId] = genres;
            io:println(string `Artist ${artistId} genres: ${string:'join(", ", ...genres)}`);
        }
    }

    // Step 3: Search catalog for new recommendations
    io:println("\nStep 3: Searching for personalized recommendations...");
    
    // Get top 3 genres for search
    [string, int][] genreEntries = genrePreferences.entries().toArray();
    [string, int][] sortedGenres = genreEntries.sort(array:DESCENDING, 
        isolated function([string, int] entry) returns int => entry[1]);
    string[] topGenres = sortedGenres.slice(0, 3).map(entry => entry[0]);
    
    // Search for songs in user's preferred genres
    foreach string genre in topGenres {
        io:println(string `\nSearching for ${genre} recommendations...`);
        
        string searchTerm = regex:replaceAll(genre, " ", "+");
        
        music:SearchResponse searchResult = check appleMusic->/catalog/[storefront]/search.get(
            term = searchTerm,
            types = ["songs", "artists"],
            'limit = 10
        );
        
        // Display song recommendations
        if searchResult.results.albums is music:AlbumsResponse {
            music:AlbumsResponse albumsResp = <music:AlbumsResponse>searchResult.results.albums;
            io:println(string `Found ${albumsResp.data.length()} album recommendations:`);
            foreach var album in albumsResp.data {
                if album.attributes is music:AlbumsAttributes {
                    music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
                    string albumName = attrs.name is string ? attrs.name : "Unknown";
                    io:println(string `  - Album: ${albumName}`);
                }
            }
        }
        
        // Display artist recommendations
        if searchResult.results.artists is music:ArtistsResponse {
            music:ArtistsResponse artistsResp = <music:ArtistsResponse>searchResult.results.artists;
            io:println(string `Found ${artistsResp.data.length()} artist recommendations:`);
            foreach var artist in artistsResp.data {
                io:println(string `  - Artist ID: ${artist.id}`);
            }
        }
    }

    // Step 4: Generate final recommendations summary
    io:println("\n=== Personalized Recommendations Summary ===");
    io:println(string `Based on your library of ${libraryResponse.data.length()} songs:`);
    io:println(string `Top genres: ${string:'join(", ", ...topGenres)}`);
    io:println(string `Analyzed ${favoriteArtistIds.length()} favorite artists`);
    io:println("Recommendation engine has found new content matching your taste!");
    
    return;
}