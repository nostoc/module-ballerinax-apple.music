import ballerina/io;
import ballerina/regex;
import ballerinax/apple.music;

configurable string userToken = ?;
configurable string authorization = ?;
configurable string storefront = "us";

public function main() returns error? {
    music:ApiKeysConfig apiKeyConfig = {
        authorization: authorization,
        musicUserToken: userToken
    };
    
    music:Client appleMusic = check new(apiKeyConfig = apiKeyConfig);
    
    io:println("=== Music Discovery and Library Management System ===\n");
    
    string searchArtist = "Taylor Swift";
    io:println("Step 1: Searching for artist: " + searchArtist);
    
    string searchTerm = searchArtist;
    string[] termParts = regex:split(searchTerm, " ");
    string formattedTerm = string:'join("+", ...termParts);
    
    music:GetSearchResponseFromCatalogQueries searchQueries = {
        term: formattedTerm,
        types: ["artists"],
        'limit: 5
    };
    
    music:SearchResponse searchResult = check appleMusic->/catalog/[storefront]/search(queries = searchQueries);
    
    music:ArtistsResponse? artistsResponse = searchResult.results.artists;
    if artistsResponse is () {
        io:println("No artists found for: " + searchArtist);
        return;
    }
    
    music:Artists[] artistsData = artistsResponse.data;
    if artistsData.length() == 0 {
        io:println("No artists found for: " + searchArtist);
        return;
    }
    
    music:Artists foundArtist = artistsData[0];
    io:println("Found artist: " + foundArtist.id);
    io:println("Artist details retrieved successfully\n");
    
    io:println("Step 2: Discovering top songs for the artist");
    
    music:GetArtistViewFromCatalogQueries topSongsQueries = {
        'limit: 10
    };
    
    music:AlbumsResponse topSongsResponse = check appleMusic->/catalog/[storefront]/artists/[foundArtist.id]/view/["top-songs"](queries = topSongsQueries);
    
    io:println("Retrieved " + topSongsResponse.data.length().toString() + " popular albums/songs");
    
    string[] recommendedSongIds = [];
    foreach int i in 0..<topSongsResponse.data.length() {
        music:Albums album = topSongsResponse.data[i];
        io:println("- Album/Song ID: " + album.id);
        music:AlbumsAttributes? albumAttributes = album.attributes;
        if albumAttributes is music:AlbumsAttributes {
            io:println("  Genres: " + albumAttributes.genreNames.toString());
            string? releaseDate = albumAttributes.releaseDate;
            if releaseDate is string {
                io:println("  Release Date: " + releaseDate);
            }
        }
        
        if i < 3 {
            recommendedSongIds.push(album.id);
        }
    }
    io:println("");
    
    io:println("Step 3: Adding recommended songs to personal library");
    
    if recommendedSongIds.length() > 0 {
        music:AddToLibraryQueriesIdsItemsString[] libraryIds = [];
        foreach string songId in recommendedSongIds {
            libraryIds.push(songId);
        }
        
        music:AddToLibraryQueries addToLibraryQueries = {
            ids: libraryIds
        };
        
        error? addResult = appleMusic->/me/library.post(queries = addToLibraryQueries);
        
        if addResult is error {
            io:println("Error adding songs to library: " + addResult.message());
        } else {
            io:println("Successfully added " + recommendedSongIds.length().toString() + " songs to your personal library");
            io:println("Added song IDs: " + recommendedSongIds.toString());
        }
    } else {
        io:println("No songs available to add to library");
    }
    
    io:println("\n=== Music Discovery and Library Management Complete ===");
    io:println("Workflow Summary:");
    io:println("1. ✓ Searched for artist: " + searchArtist);
    io:println("2. ✓ Discovered " + topSongsResponse.data.length().toString() + " popular tracks");
    io:println("3. ✓ Added " + recommendedSongIds.length().toString() + " songs to personal library");
    io:println("Your music library has been updated with new recommendations!");
}