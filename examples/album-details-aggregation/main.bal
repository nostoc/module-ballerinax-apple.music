import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = "your-developer-token";
configurable string musicUserToken = "your-music-user-token";
configurable string storefront = "us";

public function main() returns error? {
    music:Client appleMusic = check new ({
        authorization: developerToken,
        musicUserToken: musicUserToken
    });

    string albumId = "1440857781";

    io:println("=== Fetching Album Details ===");
    music:AlbumsResponse albumResponse = check appleMusic->/catalog/[storefront]/albums/[albumId]({
        include: ["tracks", "artists"]
    });

    if albumResponse.data.length() == 0 {
        io:println("No album found");
        return;
    }

    music:Albums album = albumResponse.data[0];
    io:println(string `Album: ${album.attributes?.name ?: "Unknown"}`);
    io:println(string `Artist: ${album.attributes?.artistName ?: "Unknown"}`);
    io:println(string `Release Date: ${album.attributes?.releaseDate ?: "Unknown"}`);
    
    string[]? genreNames = album.attributes?.genreNames;
    string genreDisplay = "Unknown";
    if genreNames is string[] && genreNames.length() > 0 {
        genreDisplay = genreNames[0];
    }
    io:println(string `Genre: ${genreDisplay}`);
    
    decimal? trackCountDecimal = album.attributes?.trackCount;
    int trackCount = trackCountDecimal is decimal ? <int>trackCountDecimal : 0;
    io:println(string `Track Count: ${trackCount}`);

    io:println("\n=== Fetching Track Listings ===");
    music:SongsResponse tracksResponse = check appleMusic->/catalog/[storefront]/albums/[albumId]/tracks({
        'limit: "25"
    });

    io:println(string `Found ${tracksResponse.data.length()} tracks:`);
    foreach int i in 0 ..< tracksResponse.data.length() {
        music:Songs track = tracksResponse.data[i];
        io:println(string `${i + 1}. Track ID: ${track.id}`);
    }

    io:println("\n=== Fetching Contributing Artists ===");
    music:ArtistsResponse artistsResponse = check appleMusic->/catalog/[storefront]/albums/[albumId]/artists({
        'limit: "10"
    });

    io:println(string `Found ${artistsResponse.data.length()} contributing artists:`);
    foreach music:Artists artist in artistsResponse.data {
        io:println(string `Artist ID: ${artist.id}`);
        
        io:println(string `  Fetching detailed info for artist: ${artist.id}`);
        music:ArtistsResponse artistDetailResponse = check appleMusic->/catalog/[storefront]/artists/[artist.id]({
            views: ["top-songs", "latest-release"]
        });

        if artistDetailResponse.data.length() > 0 {
            music:Artists artistDetail = artistDetailResponse.data[0];
            io:println(string `  Artist: ${artistDetail.attributes?.name ?: "Unknown"}`);
            
            string[]? artistGenreNames = artistDetail.attributes?.genreNames;
            string artistGenreDisplay = "Unknown";
            if artistGenreNames is string[] && artistGenreNames.length() > 0 {
                artistGenreDisplay = artistGenreNames[0];
            }
            io:println(string `  Genre: ${artistGenreDisplay}`);
        }
    }

    io:println("\n=== Album Page Data Complete ===");
    io:println("Rich album page with full context ready for display");
}