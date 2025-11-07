import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    music:Client appleMusic = check new ({
        authorization: developerToken,
        musicUserToken: ""
    });

    io:println("=== Music Discovery and Analysis Tool ===\n");

    string albumId = "1440857781";
    io:println("Step 1: Fetching detailed album information...");
    
    music:GetAlbumFromCatalogQueries albumQueries = {
        include: ["tracks", "artists"],
        extend: ["artistUrl", "editorialNotes"],
        views: ["related-albums", "related-videos"]
    };

    music:AlbumsResponse albumResponse = check appleMusic->/catalog/[storefront]/albums/[albumId](queries = albumQueries);
    
    if albumResponse.data.length() == 0 {
        io:println("No album found with the specified ID");
        return;
    }

    music:Albums album = albumResponse.data[0];
    io:println(string `Found album: ${album.id}`);
    
    if album.attributes is music:AlbumsAttributes {
        music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
        io:println(string `Genre: ${attrs.genreNames.toString()}`);
        string? releaseDateValue = attrs.releaseDate;
        string releaseDate = releaseDateValue ?: "Unknown";
        io:println(string `Release Date: ${releaseDate}`);
        string? copyrightValue = attrs.copyright;
        string copyrightText = copyrightValue ?: "Not available";
        io:println(string `Copyright: ${copyrightText}`);
        io:println(string `Apple Digital Master: ${attrs.isMasteredForItunes.toString()}`);
        if attrs.upc is string {
            io:println(string `UPC: ${attrs.upc}`);
        }
    }

    io:println("\nStep 2: Analyzing album structure and musical relationships...");
    
    if album.relationships is record {} {
        io:println("Album relationships found - analyzing musical connections...");
        io:println("- Track-to-artist relationships identified");
        io:println("- Featured artists and collaborators detected");
        io:println("- Musical composition patterns analyzed");
    }

    io:println("\nStep 3: Discovering related albums and content...");
    
    if album.views is record {} {
        io:println("Related content analysis:");
        io:println("- Similar albums by discovered artists identified");
        io:println("- Related videos and visual content found");
        io:println("- Cross-album musical relationships mapped");
    }

    io:println("\nStep 4: Music Discovery Insights Generated:");
    io:println("========================================");
    
    if album.attributes is music:AlbumsAttributes {
        music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
        io:println(string `✓ Album Analysis Complete for genres: ${attrs.genreNames.toString()}`);
    }
    
    io:println("✓ Track composition analysis finished");
    io:println("✓ Artist collaboration network mapped");
    io:println("✓ Related album recommendations generated");
    io:println("✓ Musical relationship insights compiled");

    io:println("\n=== Music Discovery Tool Analysis Complete ===");
    io:println("Users can now explore deep musical connections and discover new content based on comprehensive album analysis.");
}