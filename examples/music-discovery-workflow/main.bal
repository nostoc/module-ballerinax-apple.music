import ballerina/io;
import ballerinax/apple.music;

configurable string bearerToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    
    music:ConnectionConfig connectionConfig = {
        auth: {
            token: bearerToken
        },
        musicUserToken: ""
    };
    
    music:Client appleMusicClient = check new (connectionConfig);

    string searchTerm = "Bohemian Rhapsody";
    io:println(string `Starting music discovery for: ${searchTerm}`);
    
    music:GetSearchResponseFromCatalogQueries searchQuery = {
        term: searchTerm,
        types: ["songs", "artists"],
        'limit: 10
    };
    
    music:SearchResponse searchResults = check appleMusicClient->/catalog/[storefront]/search(queries = searchQuery);
    io:println("Search completed successfully");
    
    music:ArtistsResponse? artistsResponse = searchResults.results.artists;
    if artistsResponse is () {
        io:println("No artists found for the search term");
        return;
    }
    
    music:Artists[] artistsData = artistsResponse.data;
    if artistsData.length() == 0 {
        io:println("No artists found for the search term");
        return;
    }
    
    music:Artists firstArtist = artistsData[0];
    io:println(string `Found artist: ${firstArtist.id}`);
    
    music:GetArtistFromCatalogQueries artistQuery = {
        views: ["top-songs", "similar-artists"]
    };
    
    music:ArtistsResponse artistDetails = check appleMusicClient->/catalog/[storefront]/artists/[firstArtist.id](queries = artistQuery);
    io:println("Retrieved detailed artist information");
    
    music:GetArtistViewFromCatalogQueries topSongsQuery = {
        'limit: 10
    };
    
    music:AlbumsResponse topSongs = check appleMusicClient->/catalog/[storefront]/artists/[firstArtist.id]/view/["top-songs"](queries = topSongsQuery);
    io:println(string `Found ${topSongs.data.length()} top albums/songs for recommendations`);
    
    music:GetArtistViewFromCatalogQueries similarArtistsQuery = {
        'limit: 5
    };
    
    music:AlbumsResponse similarArtists = check appleMusicClient->/catalog/[storefront]/artists/[firstArtist.id]/view/["similar-artists"](queries = similarArtistsQuery);
    io:println(string `Found ${similarArtists.data.length()} similar artists for discovery`);
    
    io:println("\n=== Music Discovery Results ===");
    io:println(string `Original search: ${searchTerm}`);
    io:println(string `Main artist ID: ${firstArtist.id}`);
    io:println(string `Top songs/albums found: ${topSongs.data.length()}`);
    io:println(string `Similar artists found: ${similarArtists.data.length()}`);
    io:println("Music discovery workflow completed successfully!");
}