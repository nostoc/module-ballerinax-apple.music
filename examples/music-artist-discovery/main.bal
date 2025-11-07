import ballerinax/apple.music;
import ballerina/io;

configurable string developerToken = ?;

public function main() returns error? {
    
    music:Client appleMusicClient = check new ({
        authorization: developerToken,
        musicUserToken: ""
    });

    string storefront = "us";
    string searchTerm = "Shape+of+You";
    
    io:println("=== Music Discovery Application ===");
    io:println("Searching for song: " + searchTerm);
    
    music:SearchResponse searchResponse = check appleMusicClient->/catalog/[storefront]/search(
        queries = {
            term: searchTerm,
            types: ["songs"],
            'limit: 1
        }
    );
    
    music:SearchResponseResults searchResults = searchResponse.results;
    anydata songsDataAny = searchResults["songs"];
    
    if songsDataAny is () {
        io:println("No songs found for the search term");
        return;
    }
    
    music:Songs[] songsData = <music:Songs[]>songsDataAny;
    
    if songsData.length() == 0 {
        io:println("No songs found for the search term");
        return;
    }
    
    music:Songs firstSong = songsData[0];
    io:println("Found song: " + (firstSong.attributes?.name ?: "Unknown"));
    io:println("Album: " + (firstSong.attributes?.albumName ?: "Unknown"));
    io:println("Song ID: " + firstSong.id);
    
    io:println("\n=== Getting Artists for This Song ===");
    
    music:SongsResponse songArtistsResponse = check appleMusicClient->/catalog/[storefront]/songs/[firstSong.id]/artists(
        queries = {
            'limit: 5
        }
    );
    
    if songArtistsResponse.data.length() == 0 {
        io:println("No artists found for this song");
        return;
    }
    
    music:Songs primaryArtist = songArtistsResponse.data[0];
    io:println("Primary artist: " + (primaryArtist.attributes?.name ?: "Unknown"));
    io:println("Artist ID: " + primaryArtist.id);
    
    io:println("\n=== Finding Similar Artists for Music Discovery ===");
    
    music:AlbumsResponse similarArtistsResponse = check appleMusicClient->/catalog/[storefront]/artists/[primaryArtist.id]/view/["similar-artists"](
        queries = {
            'limit: 5
        }
    );
    
    if similarArtistsResponse.data.length() == 0 {
        io:println("No similar artists found");
        return;
    }
    
    io:println("Recommended similar artists based on your taste:");
    foreach int index in 0..<similarArtistsResponse.data.length() {
        music:Albums artist = similarArtistsResponse.data[index];
        io:println((index + 1).toString() + ". " + (artist.attributes?.name ?: "Unknown Artist"));
        string[] genreNames = artist.attributes?.genreNames ?: [];
        string genreString = string:'join(",", ...genreNames);
        io:println("   Genre: " + genreString);
    }
    
    io:println("\n=== Music Discovery Complete ===");
    io:println("Based on your interest in '" + (firstSong.attributes?.name ?: "Unknown") + "', we found " + 
               similarArtistsResponse.data.length().toString() + " similar artists for you to explore!");
}