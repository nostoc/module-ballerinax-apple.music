import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    
    music:Client appleMusic = check new({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("=== Music Discovery and Personal Library Management ===\n");

    // Step 1: Get user's current library albums to see what they already own
    io:println("Step 1: Fetching current library albums...");
    music:LibraryAlbumsResponse libraryResponse = check appleMusic->/me/library/albums();
    
    io:println(string`Found ${libraryResponse.data.length()} albums in your library:`);
    string[] existingAlbumNames = [];
    foreach music:LibraryAlbums album in libraryResponse.data {
        if album.attributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
            io:println(string`- ${attrs.name} by ${attrs.artistName}`);
            existingAlbumNames.push(attrs.name);
        }
    }
    io:println("");

    // Step 2: Simulate discovering new albums (in a real scenario, this would come from artist catalog search)
    io:println("Step 2: Discovering new albums to add to library...");
    
    // These would typically be album IDs discovered through artist catalog search
    string[] newAlbumIds = [
        "1440857781", // Example album ID - The Beatles "Abbey Road"
        "1440857901", // Example album ID - The Beatles "Sgt. Pepper's"
        "1440858123"  // Example album ID - The Beatles "Revolver"
    ];

    io:println("Found potential albums to add:");
    foreach string albumId in newAlbumIds {
        io:println(string`- Album ID: ${albumId}`);
    }
    io:println("");

    // Step 3: Add selected new albums to personal library
    io:println("Step 3: Adding new albums to your personal library...");
    
    music:AddToLibraryQueriesIdsItemsString[] albumIdsToAdd = [];
    foreach string albumId in newAlbumIds {
        albumIdsToAdd.push(albumId);
    }

    error? addResult = appleMusic->/me/library.post(queries = {
        ids: albumIdsToAdd
    });

    if addResult is error {
        io:println(string`Error adding albums to library: ${addResult.message()}`);
        return addResult;
    } else {
        io:println(string`Successfully added ${albumIdsToAdd.length()} albums to your library!`);
    }

    // Step 4: Verify the albums were added by fetching updated library
    io:println("\nStep 4: Verifying albums were added to library...");
    music:LibraryAlbumsResponse updatedLibraryResponse = check appleMusic->/me/library/albums('limit = 25);
    
    io:println(string`Updated library now contains ${updatedLibraryResponse.data.length()} albums:`);
    foreach music:LibraryAlbums album in updatedLibraryResponse.data {
        if album.attributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
            string status = existingAlbumNames.indexOf(attrs.name) != () ? "[Previously owned]" : "[Newly added]";
            io:println(string`- ${attrs.name} by ${attrs.artistName} ${status}`);
        }
    }

    io:println("\n=== Music discovery and library management completed successfully! ===");
}