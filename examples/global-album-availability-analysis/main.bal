import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = "";

public function main() returns error? {
    
    music:Client appleMusic = check new({
        auth: {
            token: developerToken
        }
    });

    // Define the storefronts to analyze
    string[] storefronts = ["us", "gb", "jp", "de"];
    string[] storefrontNames = ["United States", "United Kingdom", "Japan", "Germany"];
    
    io:println("=== Music Discovery and Playlist Curation System ===");
    io:println("Analyzing album availability across international markets...\n");

    // Step 1: Get popular albums from US storefront
    io:println("Step 1: Retrieving album catalog from US storefront...");
    music:GetAlbumsFromCatalogQueries catalogQueries = {
        'limit: 25,
        offset: 0
    };
    music:AlbumsResponse usAlbumsResponse = check appleMusic->/catalog/["us"]/albums(queries = catalogQueries);
    
    if usAlbumsResponse.data is () {
        io:println("No albums found in US catalog");
        return;
    }
    
    music:Albums[] usAlbums = <music:Albums[]>usAlbumsResponse.data;
    io:println(string `Found ${usAlbums.length()} albums in US catalog\n`);

    // Step 2: Create a map to store availability data
    map<map<boolean>> availabilityMatrix = {};
    map<string> albumTitles = {};
    
    // Initialize availability matrix
    foreach music:Albums album in usAlbums {
        if album.id is string {
            string albumId = <string>album.id;
            availabilityMatrix[albumId] = {};
            
            // Store album title for reporting
            if album.attributes is record {} && album.attributes["name"] is string {
                albumTitles[albumId] = <string>album.attributes["name"];
            } else {
                albumTitles[albumId] = "Unknown Album";
            }
        }
    }

    // Step 3: Check availability across different regional storefronts
    io:println("Step 2: Checking album availability across regional markets...");
    
    foreach int i in 0 ..< storefronts.length() {
        string storefront = storefronts[i];
        string storefrontName = storefrontNames[i];
        
        io:println(string `Checking availability in ${storefrontName} (${storefront})...`);
        
        // Get album IDs to check
        string[] albumIds = [];
        foreach music:Albums album in usAlbums {
            if album.id is string {
                albumIds.push(<string>album.id);
            }
        }
        
        if albumIds.length() > 0 {
            // Check albums in current storefront
            string idsQuery = string:'join(",", ...albumIds);
            
            music:GetAlbumsFromCatalogQueries regionalQueries = {
                ids: idsQuery
            };
            music:AlbumsResponse regionalResponse = check appleMusic->/catalog/[storefront]/albums(queries = regionalQueries);
            
            // Mark available albums
            if regionalResponse.data is music:Albums[] {
                music:Albums[] regionalAlbums = <music:Albums[]>regionalResponse.data;
                
                foreach music:Albums regionalAlbum in regionalAlbums {
                    if regionalAlbum.id is string {
                        string albumId = <string>regionalAlbum.id;
                        map<boolean>? availabilityMap = availabilityMatrix[albumId];
                        if availabilityMap is map<boolean> {
                            availabilityMatrix[albumId][storefront] = true;
                        }
                    }
                }
            }
            
            // Mark unavailable albums as false
            foreach string albumId in albumIds {
                map<boolean>? availabilityMap = availabilityMatrix[albumId];
                if availabilityMap is map<boolean> && !availabilityMap.hasKey(storefront) {
                    availabilityMatrix[albumId][storefront] = false;
                }
            }
        }
    }
    
    io:println();

    // Step 4: Generate comprehensive availability report
    io:println("Step 3: Generating Global Availability Report...");
    string headerSeparator = "================================================================================";
    io:println(headerSeparator);
    io:println("INTERNATIONAL MUSIC AVAILABILITY ANALYSIS");
    io:println(headerSeparator);
    
    // Summary statistics
    int totalAlbums = availabilityMatrix.length();
    map<int> storefrontCounts = {};
    int globallyAvailable = 0;
    
    foreach string storefront in storefronts {
        storefrontCounts[storefront] = 0;
    }
    
    foreach string albumId in availabilityMatrix.keys() {
        int availableIn = 0;
        foreach string storefront in storefronts {
            map<boolean>? albumAvailability = availabilityMatrix[albumId];
            if albumAvailability is map<boolean> && albumAvailability.hasKey(storefront) && albumAvailability[storefront] == true {
                int currentCount = storefrontCounts[storefront] ?: 0;
                storefrontCounts[storefront] = currentCount + 1;
                availableIn += 1;
            }
        }
        if availableIn == storefronts.length() {
            globallyAvailable += 1;
        }
    }
    
    // Print summary
    io:println(string `\nSUMMARY:`);
    io:println(string `Total Albums Analyzed: ${totalAlbums}`);
    io:println(string `Globally Available: ${globallyAvailable}`);
    decimal globalRate = totalAlbums > 0 ? <decimal>(globallyAvailable * 100) / <decimal>totalAlbums : 0.0;
    io:println(string `Global Availability Rate: ${globalRate}%\n`);
    
    io:println("REGIONAL AVAILABILITY:");
    foreach int i in 0 ..< storefronts.length() {
        string storefront = storefronts[i];
        string storefrontName = storefrontNames[i];
        int count = storefrontCounts[storefront] ?: 0;
        decimal percentage = totalAlbums > 0 ? <decimal>(count * 100) / <decimal>totalAlbums : 0.0;
        io:println(string `${storefrontName}: ${count}/${totalAlbums} (${percentage}%)`);
    }
    
    // Detailed album-by-album report
    io:println("\nDETAILED AVAILABILITY MATRIX:");
    string detailSeparator = "--------------------------------------------------------------------------------";
    io:println(detailSeparator);
    io:println("Album Title                              US   UK   JP   DE   Markets");
    io:println(detailSeparator);
    
    foreach string albumId in availabilityMatrix.keys() {
        string title = albumTitles[albumId] ?: "Unknown";
        if title.length() > 37 {
            title = title.substring(0, 37) + "...";
        }
        
        map<boolean>? albumAvailability = availabilityMatrix[albumId];
        string usStatus = "✗";
        string gbStatus = "✗";
        string jpStatus = "✗";
        string deStatus = "✗";
        
        if albumAvailability is map<boolean> {
            usStatus = albumAvailability["us"] == true ? "✓" : "✗";
            gbStatus = albumAvailability["gb"] == true ? "✓" : "✗";
            jpStatus = albumAvailability["jp"] == true ? "✓" : "✗";
            deStatus = albumAvailability["de"] == true ? "✓" : "✗";
        }
        
        int marketCount = 0;
        if albumAvailability is map<boolean> {
            foreach string storefront in storefronts {
                if albumAvailability.hasKey(storefront) && albumAvailability[storefront] == true {
                    marketCount += 1;
                }
            }
        }
        
        string formattedTitle = string:padEnd(title, 40, " ");
        string formattedUs = string:padEnd(usStatus, 4, " ");
        string formattedGb = string:padEnd(gbStatus, 4, " ");
        string formattedJp = string:padEnd(jpStatus, 4, " ");
        string formattedDe = string:padEnd(deStatus, 4, " ");
        io:println(string `${formattedTitle} ${formattedUs} ${formattedGb} ${formattedJp} ${formattedDe} ${marketCount}/4`);
    }
    
    // Recommendations for music distributors
    io:println("\n" + headerSeparator);
    io:println("RECOMMENDATIONS FOR MUSIC DISTRIBUTORS:");
    io:println(headerSeparator);
    
    if globallyAvailable < totalAlbums {
        int missingAlbums = totalAlbums - globallyAvailable;
        io:println(string `• ${missingAlbums} albums have limited regional availability`);
        io:println("• Consider expanding distribution agreements for better global reach");
    }
    
    // Find the storefront with lowest availability
    string? lowestStorefront = ();
    int lowestCount = totalAlbums + 1;
    foreach int i in 0 ..< storefronts.length() {
        string storefront = storefronts[i];
        int count = storefrontCounts[storefront] ?: 0;
        if count < lowestCount {
            lowestCount = count;
            lowestStorefront = storefrontNames[i];
        }
    }
    
    if lowestStorefront is string {
        io:println(string `• ${lowestStorefront} has the lowest availability - potential market expansion opportunity`);
    }
    
    io:println("• Focus international promotion campaigns on markets with high availability");
    io:println("• Investigate licensing barriers in markets with low availability");
    
    io:println("\nAnalysis complete! Use this data to inform your international music promotion strategy.");
}