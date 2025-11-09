import ballerina/io;
import ballerinax/apple.music;

configurable string authorization = ?;
configurable string musicUserToken = ?;

public function main() returns error? {
    
    music:ApiKeysConfig apiConfig = {
        authorization: authorization,
        musicUserToken: musicUserToken
    };
    
    music:Client appleMusicClient = check new (apiConfig);
    
    io:println("Starting music discovery analysis...");
    
    // Step 1: Get all artists from user's library
    io:println("\n1. Fetching artists from your library...");
    music:LibraryArtistsResponse libraryArtistsResponse = check appleMusicClient->/me/library/artists();
    
    if libraryArtistsResponse.data.length() == 0 {
        io:println("No artists found in your library.");
        return;
    }
    
    io:println(string `Found ${libraryArtistsResponse.data.length()} artists in your library:`);
    foreach music:LibraryArtists artist in libraryArtistsResponse.data {
        string? artistName = artist.attributes?.name;
        if artistName is string {
            io:println(string `  - ${artistName}`);
        }
    }
    
    // Step 2: Get all albums currently in user's library
    io:println("\n2. Fetching your current album collection...");
    music:LibraryAlbumsResponse libraryAlbumsResponse = check appleMusicClient->/me/library/albums();
    
    // Create a set of album names for quick lookup
    map<boolean> ownedAlbums = {};
    foreach music:LibraryAlbums album in libraryAlbumsResponse.data {
        string? albumName = album.attributes?.name;
        if albumName is string {
            string? artistNameForAlbum = album.attributes?.artistName;
            string artistForKey = artistNameForAlbum ?: "Unknown";
            string albumKey = string `${artistForKey} - ${albumName}`;
            ownedAlbums[albumKey] = true;
        }
    }
    
    io:println(string `You currently own ${libraryAlbumsResponse.data.length()} albums`);
    
    // Step 3: For each artist, find albums not in library
    io:println("\n3. Analyzing recommendations for your favorite artists...");
    
    string[] recommendations = [];
    
    foreach music:LibraryArtists libraryArtist in libraryArtistsResponse.data {
        string? artistName = libraryArtist.attributes?.name;
        if artistName is string {
            io:println(string `\nAnalyzing ${artistName}...`);
            
            // Check if artist has relationships with albums
            if libraryArtist.relationships?.albums is music:LibraryAlbumsResponse {
                music:LibraryAlbumsResponse artistAlbums = <music:LibraryAlbumsResponse>libraryArtist.relationships?.albums;
                
                foreach music:LibraryAlbums album in artistAlbums.data {
                    string? albumName = album.attributes?.name;
                    if albumName is string {
                        string albumKey = string `${artistName} - ${albumName}`;
                        
                        if !ownedAlbums.hasKey(albumKey) {
                            string releaseDate = album.attributes?.releaseDate ?: "Unknown date";
                            recommendations.push(string `${artistName} - ${albumName} (${releaseDate})`);
                            io:println(string `  📀 Recommended: ${albumName}`);
                        }
                    }
                }
            }
        }
    }
    
    // Step 4: Display final recommendations
    io:println("\n🎵 MUSIC DISCOVERY RESULTS 🎵");
    io:println("===============================");
    
    if recommendations.length() > 0 {
        io:println(string `Found ${recommendations.length()} album recommendations based on your library:`);
        io:println("");
        
        int count = 1;
        foreach string recommendation in recommendations {
            io:println(string `${count}. ${recommendation}`);
            count += 1;
        }
        
        io:println("");
        io:println("These albums are by artists you already listen to but aren't in your collection yet!");
    } else {
        io:println("Great news! You seem to have a complete collection of albums by your favorite artists.");
        io:println("Consider exploring new artists or check back later for new releases!");
    }
    
    io:println("\nMusic discovery analysis complete! 🎶");
}