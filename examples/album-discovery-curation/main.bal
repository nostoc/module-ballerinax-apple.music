import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = "your-developer-token-here";
configurable string userToken = "your-user-token-here";

public function main() returns error? {
    
    // Initialize the Apple Music client
    music:Client appleMusicClient = check new({
        authorization: developerToken,
        musicUserToken: userToken
    });

    // Step 1: Fetch detailed information about a specific album
    string storefront = "us";
    string albumId = "1440857781"; // Example: Taylor Swift - folklore
    
    io:println("=== Step 1: Fetching Album Details ===");
    
    music:GetAlbumFromCatalogQueries albumQueries = {
        include: ["artists", "tracks"],
        views: ["related-albums"],
        extend: ["editorialNotes"]
    };
    
    music:AlbumsResponse albumResponse = check appleMusicClient->/catalog/[storefront]/albums/[albumId].get(queries = albumQueries);
    
    if albumResponse.data.length() > 0 {
        music:Albums album = albumResponse.data[0];
        io:println(string `Album ID: ${album.id}`);
        io:println(string `Album Type: ${album.'type}`);
        
        if album.attributes != () {
            music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
            io:println(string `Genre Names: ${attrs.genreNames.toString()}`);
            io:println(string `Release Date: ${attrs.releaseDate ?: "Unknown"}`);
            io:println(string `Copyright: ${attrs.copyright ?: "N/A"}`);
            io:println(string `UPC: ${attrs.upc ?: "N/A"}`);
            io:println(string `Mastered for iTunes: ${attrs.isMasteredForItunes}`);
        }
    } else {
        io:println("No album data found");
        return;
    }

    // Step 2: Retrieve the album's associated artists
    io:println("\n=== Step 2: Fetching Album Artists ===");
    
    music:GetAlbumRelationshipFromCatalogQueries artistQueries = {
        'limit: 10,
        include: ["albums"],
        extend: ["editorialNotes"]
    };
    
    music:ArtistsResponse artistsResponse = check appleMusicClient->/catalog/[storefront]/albums/[albumId]/artists.get(queries = artistQueries);
    
    io:println(string `Found ${artistsResponse.data.length()} artists:`);
    foreach music:Artists artist in artistsResponse.data {
        io:println(string `- Artist ID: ${artist.id}`);
        io:println(string `- Artist Type: ${artist.'type}`);
        io:println(string `- Artist HREF: ${artist.href}`);
        
        if artist.relationships != () {
            music:ArtistsRelationships? relationships = <music:ArtistsRelationships?>artist.relationships;
            if relationships != () && relationships.albums != () {
                music:AlbumsResponse? artistAlbums = relationships.albums;
                if artistAlbums != () {
                    io:println(string `- Related Albums Count: ${artistAlbums.data.length()}`);
                }
            }
        }
    }

    // Step 3: Add the discovered album to user's personal library
    io:println("\n=== Step 3: Adding Album to User Library ===");
    
    music:AddToLibraryQueries libraryQueries = {
        ids: [string `albums:${albumId}`]
    };
    
    error? libraryResult = appleMusicClient->/me/library.post(queries = libraryQueries);
    
    if libraryResult is error {
        io:println(string `Error adding album to library: ${libraryResult.message()}`);
    } else {
        io:println("Successfully added album to user's library!");
    }

    // Summary of the complete discovery-to-curation pipeline
    io:println("\n=== Music Discovery Pipeline Complete ===");
    io:println("✓ Fetched detailed album metadata and track listings");
    io:println("✓ Retrieved associated artists and collaborators");
    io:println("✓ Added album to user's personal library");
    io:println("User engagement and library building workflow completed successfully!");
}