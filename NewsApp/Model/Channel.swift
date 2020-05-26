//
//  Channel.swift
//  NewsApp
//
//  Created by oleG on 22/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import Foundation

struct ChanelServerAnswer: Codable {
    var status: String
    var sources: [Channel]
}

struct Channel: Codable {
    var name: String
    var description: String
    var isFavorite: Bool?
    
    var id: String
    

    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ChannelsURL = DocumentsDirectory.appendingPathComponent("channels").appendingPathExtension("plist")
    


    static func loadChannels() -> [Channel]? {
        guard let codedChannels = try? Data(contentsOf: ChannelsURL) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<Channel>.self, from: codedChannels)
    }
    
    static func saveChannels(_ channels: [Channel]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedChannels = try? propertyListEncoder.encode(channels)
        try? codedChannels?.write(to: ChannelsURL, options: .noFileProtection)
    }
}

    
    
    
    
    
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case description
//
//    }
    
//    init(name: String, description: String, isFavorite: Bool, id: String) {
//        self.id = id
//        self.name = name
//        self.description = description
//        self.isFavorite = isFavorite
//    }
//
//    init(from decoder: Decoder) throws {
//        let valueContainer = try decoder.container(keyedBy:
//            CodingKeys.self)
//        self.id = try valueContainer.decode(String.self,
//                                               forKey: CodingKeys.id)
//        self.name = try valueContainer.decode(String.self,
//                                                     forKey: CodingKeys.name)
//        self.description = try valueContainer.decode(String.self, forKey:
//            CodingKeys.description)
//        //self.isFavorite = try valueContainer.decode(Bool.self, forKey: CodingKeys.isFavorite)
//
//    }

//    static func loadFavorites() -> [Channel]? {
//        return nil
//    }
    
//    static func loadSampleChannels() -> [Channel] { //MARK: TEMP!
//        let channel1 = Channel(name: "BBC", description: "sample BBC", isFavorite: false, id: "bbc")
//        let channel2 = Channel(name: "CNN", description: "sample CNN", isFavorite: true, id: "cnn")
//
//        return [channel1, channel2]
//        return [Channel]()
//    }

