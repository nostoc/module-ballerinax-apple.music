import ballerina/io;
import ballerinax/apple.music;

configurable string accessToken = ?;
configurable string keyId = ?;
configurable string teamId = ?;
configurable string privateKey = ?;

public function main() returns error? {
    
    music:Client appleMusic = check new({
        authorization: accessToken,
        musicUserToken: accessToken
    });

    string storefront = "us";
    string favoriteArtist = "Taylor Swift";

    io:println("=== Music Discovery and Library Management Workflow ===");
    io:println("Searching for favorite artist: " + favoriteArtist);

    music:GetSearchResponseFromCatalogQueries searchQueries = {
        term: favoriteArtist,
        types: ["artists", "songs", "albums"],
        'limit: 10
    };

    music:SearchResponse searchResponse = check appleMusic->/catalog/[storefront]/search(queries = searchQueries);
    
    io:println("Search completed successfully!");
    
    if searchResponse.results.artists is music:ArtistsResponse {
        music:ArtistsResponse artistsResponse = <music:ArtistsResponse>searchResponse.results.artists;
        
        if artistsResponse.data.length() > 0 {
            music:Artists firstArtist = artistsResponse.data[0];
            string artistId = firstArtist.id;
            
            io:println("Found artist: " + artistId);
            io:println("Exploring artist's top songs...");

            music:GetArtistViewFromCatalogQueries topSongsQueries = {
                'limit: 10
            };

            music:AlbumsResponse topSongsResponse = check appleMusic->/catalog/[storefront]/artists/[artistId]/view/["top-songs"](queries = topSongsQueries);
            
            io:println("Retrieved " + topSongsResponse.data.length().toString() + " top songs");

            io:println("Exploring artist's latest releases...");
            
            music:GetArtistViewFromCatalogQueries latestReleaseQueries = {
                'limit: 5
            };

            music:AlbumsResponse latestReleaseResponse = check appleMusic->/catalog/[storefront]/artists/[artistId]/view/["latest-release"](queries = latestReleaseQueries);
            
            io:println("Retrieved " + latestReleaseResponse.data.length().toString() + " latest releases");

            string[] discoveredTrackIds = [];
            
            foreach music:Albums album in topSongsResponse.data {
                discoveredTrackIds.push("songs:" + album.id);
                if discoveredTrackIds.length() >= 3 {
                    break;
                }
            }

            if discoveredTrackIds.length() > 0 {
                io:println("Adding " + discoveredTrackIds.length().toString() + " discovered tracks to personal library...");
                
                music:AddToLibraryQueriesIdsItemsString[] libraryIds = [];
                foreach string trackId in discoveredTrackIds {
                    libraryIds.push(trackId);
                }

                music:AddToLibraryQueries libraryQueries = {
                    ids: libraryIds
                };

                error? addResult = appleMusic->/me/library.post(queries = libraryQueries);
                
                if addResult is error {
                    io:println("Error adding tracks to library: " + addResult.message());
                } else {
                    io:println("Successfully added tracks to personal library!");
                }
            }
        }
    }

    if searchResponse.results.albums is music:AlbumsResponse {
        music:AlbumsResponse albumsResponse = <music:AlbumsResponse>searchResponse.results.albums;
        io:println("Found " + albumsResponse.data.length().toString() + " albums in search results");
        
        foreach music:Albums album in albumsResponse.data {
            if album.attributes is music:AlbumsAttributes {
                music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
                io:println("Album: " + album.id + " - Genres: " + attrs.genreNames.toString());
            }
        }
    }

    io:println("=== Music Discovery Workflow Complete ===");
}