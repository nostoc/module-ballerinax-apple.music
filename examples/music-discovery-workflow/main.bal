import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = "your-developer-token-here";
configurable string musicUserToken = "your-music-user-token-here";
configurable string storefront = "us";

public function main() returns error? {
    
    // Initialize the Apple Music client
    music:Client musicClient = check new ({
        authorization: developerToken,
        musicUserToken: musicUserToken
    });

    io:println("=== Apple Music Discovery Workflow ===\n");

    // Step 1: Search for an artist by name
    string searchArtistName = "Radiohead";
    io:println("Step 1: Searching for artist: " + searchArtistName);
    
    music:SearchResponse searchResponse = check musicClient->/catalog/[storefront]/search(
        queries = {
            term: searchArtistName,
            types: ["artists"],
            'limit: 1
        }
    );

    music:ArtistsResponse? artistsResponse = searchResponse.results.artists;
    if artistsResponse is () || artistsResponse.data.length() == 0 {
        io:println("No artists found for search term: " + searchArtistName);
        return;
    }

    music:Artists targetArtist = artistsResponse.data[0];
    string artistId = targetArtist.id;
    io:println("Found artist ID: " + artistId);
    string artistName = targetArtist.attributes?.name ?: "Unknown";
    io:println("Artist name: " + artistName);

    // Step 2: Get similar artists for the found artist
    io:println("\nStep 2: Finding similar artists...");
    
    music:ArtistsResponse|error similarArtistsResult = musicClient->/catalog/[storefront]/artists/[artistId]/view/["similar-artists"](
        queries = {
            'limit: 5
        }
    );

    if similarArtistsResult is error {
        io:println("Error getting similar artists: " + similarArtistsResult.message());
        return;
    }

    music:ArtistsResponse similarArtistsResponse = similarArtistsResult;

    if similarArtistsResponse.data.length() == 0 {
        io:println("No similar artists found");
        return;
    }

    io:println("Found " + similarArtistsResponse.data.length().toString() + " similar artists:");
    foreach int i in 0..<similarArtistsResponse.data.length() {
        music:Artists similarArtist = similarArtistsResponse.data[i];
        string similarArtistName = similarArtist.attributes?.name ?: "Unknown Artist";
        io:println("  " + (i + 1).toString() + ". " + similarArtistName + " (ID: " + similarArtist.id + ")");
    }

    // Step 3: Get top songs for the first similar artist
    music:Artists selectedSimilarArtist = similarArtistsResponse.data[0];
    string similarArtistId = selectedSimilarArtist.id;
    string selectedArtistName = selectedSimilarArtist.attributes?.name ?: "Unknown Artist";
    
    io:println("\nStep 3: Getting top songs for similar artist: " + selectedArtistName);
    
    music:SongsResponse|error topSongsResult = musicClient->/catalog/[storefront]/artists/[similarArtistId]/view/["top-songs"](
        queries = {
            'limit: 10
        }
    );

    if topSongsResult is error {
        io:println("Error getting top songs: " + topSongsResult.message());
        return;
    }

    music:SongsResponse topSongsResponse = topSongsResult;

    if topSongsResponse.data.length() == 0 {
        io:println("No top songs found for artist: " + selectedArtistName);
        return;
    }

    io:println("\n=== Personalized Recommendation Playlist ===");
    io:println("Based on your interest in " + searchArtistName + ", here are top songs from " + selectedArtistName + ":");
    
    foreach int i in 0..<topSongsResponse.data.length() {
        music:Songs song = topSongsResponse.data[i];
        string songName = song.attributes?.name ?: "Unknown Song";
        music:SongsAttributes? songAttributes = song.attributes;
        string albumName = "Unknown Album";
        int duration = 0;
        
        if songAttributes is music:SongsAttributes {
            string? albumNameAttr = songAttributes?.albumName;
            if albumNameAttr is string {
                albumName = albumNameAttr;
            }
            int? durationAttr = songAttributes?.durationInMillis;
            if durationAttr is int {
                duration = durationAttr;
            }
        }
        
        int durationSeconds = duration / 1000;
        int minutes = durationSeconds / 60;
        int seconds = durationSeconds % 60;
        string secondsStr = seconds < 10 ? "0" + seconds.toString() : seconds.toString();
        
        io:println(string `  ${i + 1}. ${songName}`);
        io:println(string `     Album: ${albumName}`);
        io:println(string `     Duration: ${minutes}:${secondsStr}`);
        if song.attributes?.genreNames is string[] {
            string[] genres = <string[]>song.attributes?.genreNames;
            if genres.length() > 0 {
                io:println("     Genres: " + string:'join(", ", ...genres));
            }
        }
        io:println("");
    }

    io:println("=== Music Discovery Workflow Complete ===");
    io:println("Total recommendations generated: " + topSongsResponse.data.length().toString());
}