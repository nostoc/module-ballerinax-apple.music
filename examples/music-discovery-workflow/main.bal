import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;

public function main() returns error? {
    
    // Initialize the Apple Music client
    music:ApiKeysConfig clientConfig = {
        authorization: developerToken,
        musicUserToken: userToken
    };
    
    music:Client musicClient = check new(clientConfig);

    io:println("=== Music Discovery and Collection Builder ===\n");

    // Step 1: Retrieve all albums from user's personal library
    io:println("Step 1: Fetching all albums from your music library...");
    
    music:GetAlbumsFromLibraryQueries libraryQuery = {
        'limit: 25,
        include: ["artists"]
    };
    
    music:LibraryAlbumsResponse libraryAlbumsResponse = check musicClient->/me/library/albums(queries = libraryQuery);
    
    io:println(string `Found ${libraryAlbumsResponse.data.length()} albums in your library:`);
    
    string? selectedAlbumId = ();
    foreach music:LibraryAlbums album in libraryAlbumsResponse.data {
        string albumName = album.attributes?.name ?: "Unknown Album";
        string artistName = album.attributes?.artistName ?: "Unknown Artist";
        io:println(string `- ${albumName} by ${artistName}`);
        if selectedAlbumId is () {
            selectedAlbumId = album.id;
        }
    }
    
    if selectedAlbumId is () {
        io:println("No albums found in library. Please add some albums to your Apple Music library first.");
        return;
    }

    string separatorLine = "";
    int counter = 0;
    while counter < 50 {
        separatorLine += "=";
        counter += 1;
    }
    io:println("\n" + separatorLine + "\n");

    // Step 2: Get detailed information about a specific album
    io:println("Step 2: Fetching detailed information for selected album...");
    
    music:GetAlbumFromLibraryQueries albumDetailQuery = {
        include: ["artists", "tracks"]
    };
    
    music:LibraryAlbumsResponse albumDetailResponse = check musicClient->/me/library/albums/[selectedAlbumId](queries = albumDetailQuery);
    
    if albumDetailResponse.data.length() > 0 {
        music:LibraryAlbums selectedAlbum = albumDetailResponse.data[0];
        io:println("Album Details:");
        string albumTitle = selectedAlbum.attributes?.name ?: "Unknown";
        string albumArtist = selectedAlbum.attributes?.artistName ?: "Unknown";
        string releaseDate = selectedAlbum.attributes?.releaseDate ?: "Unknown";
        string trackCount = selectedAlbum.attributes?.trackCount.toString();
        string genreNames = string:'join(", ", ...(selectedAlbum.attributes?.genreNames ?: []));
        string contentRating = selectedAlbum.attributes?.contentRating ?: "Not Rated";
        string dateAdded = selectedAlbum.attributes?.dateAdded ?: "Unknown";
        
        io:println(string `  Title: ${albumTitle}`);
        io:println(string `  Artist: ${albumArtist}`);
        io:println(string `  Release Date: ${releaseDate}`);
        io:println(string `  Track Count: ${trackCount}`);
        io:println(string `  Genres: ${genreNames}`);
        io:println(string `  Content Rating: ${contentRating}`);
        io:println(string `  Date Added to Library: ${dateAdded}`);
    }

    string separatorLine2 = "";
    int counter2 = 0;
    while counter2 < 50 {
        separatorLine2 += "=";
        counter2 += 1;
    }
    io:println("\n" + separatorLine2 + "\n");

    // Step 3: Explore album relationships to find connected artists
    io:println("Step 3: Discovering connected artists for music recommendations...");
    
    music:GetAlbumRelationshipFromLibraryQueries artistRelationQuery = {
        'limit: 10
    };
    
    music:LibraryArtistsResponse artistsResponse = check musicClient->/me/library/albums/[selectedAlbumId]/artists(queries = artistRelationQuery);
    
    io:println("Connected Artists (for building recommendations):");
    foreach music:LibraryArtists artist in artistsResponse.data {
        string artistName = artist.attributes?.name ?: "Unknown Artist";
        io:println(string `  - ${artistName} (ID: ${artist.id})`);
    }

    string separatorLine3 = "";
    int counter3 = 0;
    while counter3 < 50 {
        separatorLine3 += "=";
        counter3 += 1;
    }
    io:println("\n" + separatorLine3 + "\n");

    // Step 4: Analyze patterns for music discovery insights
    io:println("Step 4: Analyzing your music collection patterns...");
    
    map<int> genreCount = {};
    map<int> artistCount = {};
    
    foreach music:LibraryAlbums album in libraryAlbumsResponse.data {
        // Count genres
        string[]? genreNames = album.attributes?.genreNames;
        if genreNames is string[] {
            foreach string genre in genreNames {
                int currentCount = genreCount[genre] ?: 0;
                genreCount[genre] = currentCount + 1;
            }
        }
        
        // Count artists
        string? artistName = album.attributes?.artistName;
        if artistName is string {
            int currentCount = artistCount[artistName] ?: 0;
            artistCount[artistName] = currentCount + 1;
        }
    }
    
    io:println("Your Music Collection Insights:");
    io:println("Top Genres in Your Library:");
    foreach var [genre, count] in genreCount.entries() {
        io:println(string `  ${genre}: ${count} album(s)`);
    }
    
    io:println("\nTop Artists in Your Library:");
    foreach var [artist, count] in artistCount.entries() {
        io:println(string `  ${artist}: ${count} album(s)`);
    }
    
    io:println("\n=== Music Discovery Complete ===");
    io:println("Use this data to:");
    io:println("- Build personalized playlists based on your preferred genres");
    io:println("- Discover new artists similar to your collection patterns");
    io:println("- Find collaborative artists and featured performers");
    io:println("- Create curated recommendations for music exploration");
}