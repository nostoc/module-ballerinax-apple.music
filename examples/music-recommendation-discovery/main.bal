import ballerina/io;
import ballerinax/apple.music;

configurable string userToken = ?;
configurable string developerToken = ?;

public function main() returns error? {
    // Initialize Apple Music client
    music:Client appleMusicClient = check new({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("=== Music Recommendation Engine ===");
    io:println("Analyzing user's music library for recommendations...\n");

    // Step 1: Retrieve all albums from user's library
    io:println("Step 1: Fetching user's library albums...");
    music:GetAlbumsFromLibraryQueries libraryQuery = {
        'limit: 25,
        include: ["artists", "tracks"]
    };
    
    music:LibraryAlbumsResponse libraryResponse = check appleMusicClient->/me/library/albums(queries = libraryQuery);
    io:println(string `Found ${libraryResponse.data.length()} albums in user's library`);

    // Step 2: Build comprehensive preference profile
    io:println("\nStep 2: Building preference profile from library...");
    string[] preferredGenres = [];
    string[] preferredArtists = [];
    
    foreach music:LibraryAlbums album in libraryResponse.data {
        if album.attributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
            
            io:println(string `Analyzing: "${attrs.name}" by ${attrs.artistName}`);
            
            // Collect genres for preference analysis
            foreach string genre in attrs.genreNames {
                if preferredGenres.indexOf(genre) == () {
                    preferredGenres.push(genre);
                }
            }
            
            // Collect artist names
            if preferredArtists.indexOf(attrs.artistName) == () {
                preferredArtists.push(attrs.artistName);
            }
            
            // Get detailed album information with track listings
            music:GetAlbumFromLibraryQueries detailQuery = {
                include: ["tracks", "artists"]
            };
            
            music:LibraryAlbumsResponse detailResponse = check appleMusicClient->/me/library/albums/[album.id](queries = detailQuery);
            
            if detailResponse.data.length() > 0 {
                music:LibraryAlbums detailedAlbum = detailResponse.data[0];
                if detailedAlbum.attributes is music:LibraryAlbumsAttributes {
                    music:LibraryAlbumsAttributes detailedAttrs = <music:LibraryAlbumsAttributes>detailedAlbum.attributes;
                    io:println(string `  - Track Count: ${detailedAttrs.trackCount}`);
                    io:println(string `  - Release Date: ${detailedAttrs.releaseDate ?: "Unknown"}`);
                    io:println(string `  - Genres: ${string:'join(", ", ...detailedAttrs.genreNames)}`);
                }
            }
        }
    }

    // Step 3: Explore album relationships for recommendations
    io:println("\nStep 3: Discovering related content and recommendations...");
    io:println(string `User's preferred genres: ${string:'join(", ", ...preferredGenres)}`);
    io:println(string `User's preferred artists: ${string:'join(", ", ...preferredArtists)}`);

    // Analyze relationships for each album to find similar content
    foreach music:LibraryAlbums album in libraryResponse.data.slice(0, 5) { // Limit to first 5 for demo
        if album.attributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = <music:LibraryAlbumsAttributes>album.attributes;
            io:println(string `\nExploring relationships for: "${attrs.name}"`);
            
            // Get related artists
            music:GetAlbumRelationshipFromLibraryQueries artistQuery = {
                'limit: 10
            };
            
            music:LibraryArtistsResponse|error artistsResult = appleMusicClient->/me/library/albums/[album.id]/artists(queries = artistQuery);
            if artistsResult is music:LibraryArtistsResponse {
                io:println(string `  Found ${artistsResult.data.length()} related artists`);
                foreach music:LibraryArtists artist in artistsResult.data {
                    if artist.attributes is music:LibraryArtistsAttributes {
                        music:LibraryArtistsAttributes artistAttrs = <music:LibraryArtistsAttributes>artist.attributes;
                        io:println(string `    - ${artistAttrs.name}`);
                    }
                }
            }
            
            // Get related genres
            music:LibraryArtistsResponse|error genresResult = appleMusicClient->/me/library/albums/[album.id]/genres(queries = artistQuery);
            if genresResult is music:LibraryArtistsResponse {
                io:println(string `  Found ${genresResult.data.length()} related genre connections`);
            }
            
            // Get track relationships
            music:LibraryArtistsResponse|error tracksResult = appleMusicClient->/me/library/albums/[album.id]/tracks(queries = artistQuery);
            if tracksResult is music:LibraryArtistsResponse {
                io:println(string `  Analyzed ${tracksResult.data.length()} track relationships`);
            }
        }
    }

    // Step 4: Generate recommendation summary
    io:println("\n=== RECOMMENDATION SUMMARY ===");
    io:println("Based on your music library analysis:");
    io:println(string `- You have ${libraryResponse.data.length()} albums in your collection`);
    io:println(string `- Your music spans ${preferredGenres.length()} different genres`);
    io:println(string `- You listen to ${preferredArtists.length()} different artists`);
    io:println("\nRecommendation Engine suggests exploring:");
    io:println("- Albums from similar artists in your preferred genres");
    io:println("- New releases in your most-played genres");
    io:println("- Collaborative playlists featuring your favorite artists");
    io:println("- Deep cuts and B-sides from artists already in your library");

    io:println("\n=== Analysis Complete ===");
}