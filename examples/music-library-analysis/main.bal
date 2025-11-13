import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;

public function main() returns error? {
    
    // Initialize Apple Music client
    music:Client appleMusicClient = check new ({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("Starting music discovery analysis...\n");

    // Step 1: Retrieve all albums from user's personal library
    io:println("1. Fetching albums from user library...");
    music:LibraryAlbumsResponse libraryAlbumsResponse = check appleMusicClient->/me/library/albums.get(
        headers = {"Music-User-Token": userToken},
        'limit = 25
    );

    io:println("Found " + libraryAlbumsResponse.data.length().toString() + " albums in library");
    
    // Display basic album information
    foreach music:LibraryAlbums album in libraryAlbumsResponse.data {
        if album.attributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
            io:println("  - " + attrs.name + " by " + attrs.artistName);
        }
    }

    io:println("\n2. Analyzing album relationships for music profiling...");

    // Step 2: For each album, fetch comprehensive relationship data
    foreach music:LibraryAlbums album in libraryAlbumsResponse.data {
        if album.attributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
            io:println("\nAnalyzing: " + attrs.name);

            // Get associated artists
            music:LibraryArtistsResponse|error artistsResponse = appleMusicClient->/me/library/albums/[album.id]/artists.get(
                headers = {"Music-User-Token": userToken},
                'limit = 10
            );

            if artistsResponse is music:LibraryArtistsResponse {
                io:println("  Artists (" + artistsResponse.data.length().toString() + "):");
                foreach music:LibraryArtists artist in artistsResponse.data {
                    if artist.attributes is music:LibraryArtistsAttributes {
                        music:LibraryArtistsAttributes artistAttrs = <music:LibraryArtistsAttributes>artist.attributes;
                        io:println("    - " + artistAttrs.name);
                    }
                }
            }

            // Get genre information
            io:println("  Genres: " + string:'join(", ", ...attrs.genreNames));
            
            // Get record label information
            music:LibraryArtistsResponse|error labelsResponse = appleMusicClient->/me/library/albums/[album.id]/["record-labels"].get(
                headers = {"Music-User-Token": userToken},
                'limit = 5
            );

            if labelsResponse is music:LibraryArtistsResponse {
                io:println("  Record Labels: " + labelsResponse.data.length().toString() + " found");
            }
        }
    }

    io:println("\n3. Fetching detailed catalog information for recommendations...");

    // Step 3: Use specific album IDs to get detailed catalog information
    string[] sampleAlbumIds = ["1440857781", "1440857782", "1440857783"]; // Sample catalog IDs
    string storefront = "us";

    foreach string albumId in sampleAlbumIds {
        io:println("\nFetching catalog details for album ID: " + albumId);
        
        music:AlbumsResponse|error catalogResponse = appleMusicClient->/catalog/[storefront]/albums/[albumId].get(
            include = ["artists", "genres", "tracks"],
            extend = ["artistUrl"],
            views = ["related-albums", "other-versions"]
        );

        if catalogResponse is music:AlbumsResponse {
            foreach music:Albums catalogAlbum in catalogResponse.data {
                if catalogAlbum.attributes is music:AlbumsAttributes {
                    music:AlbumsAttributes catalogAttrs = <music:AlbumsAttributes>catalogAlbum.attributes;
                    io:println("  Catalog Album: " + catalogAlbum.id);
                    io:println("  Genres: " + string:'join(", ", ...catalogAttrs.genreNames));
                    string? releaseDate = catalogAttrs.releaseDate;
                    string releaseDateStr = releaseDate ?: "Unknown";
                    io:println("  Release Date: " + releaseDateStr);
                    io:println("  Apple Digital Master: " + catalogAttrs.isMasteredForItunes.toString());
                    string? upcValue = catalogAttrs.upc;
                    if upcValue is string {
                        io:println("  UPC: " + upcValue);
                    }
                }
            }
        } else {
            io:println("  Could not fetch catalog data for album " + albumId);
        }
    }

    io:println("\n✅ Music discovery analysis complete!");
    io:println("Rich music profiles have been built with comprehensive metadata for recommendation algorithms.");
}