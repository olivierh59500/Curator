import Foundation

public struct Curator {
    
}

extension Curator {
    public static func save(
        _ keepable: CuratorKeepable,
        to location: CuratorLocation,
        options: Data.WritingOptions = [ .atomic]
        ) throws {
        let url = try location.standardizedFileURL()
        
        let fileExistResult = url.crt.fileExist
        if fileExistResult.fileExist {
            if fileExistResult.isDirectory {
                throw Error.locationIsDirectory(location)
            }
            else if options.contains( .withoutOverwriting) {
                throw Error.locationFileExist(location)
            }
        }
        else {
            try url.crt.createDirectory(fileExistResult: fileExistResult)
        }
        
        let data = try keepable.asData()
        
        try data.write(to: url, options: options)
    }
    
    public static func getData(
        from location: CuratorLocation,
        options: Data.ReadingOptions = []
        ) throws -> Data {
        let url = try location.standardizedFileURL()
        
        let fileExistResult = url.crt.fileExist
        
        if !fileExistResult.fileExist {
            throw Error.locationFileNotExist(location)
        }
        
        if fileExistResult.isDirectory {
            throw Error.locationIsDirectory(location)
        }
        
        let data = try Data(
            contentsOf: url,
            options: options
        )
        
        return data
    }
    
    private static func convertToFilePathURL(from location: CuratorLocation) throws -> URL {
        let locationURL = try location.standardizedFileURL()
        let locationNSURL = locationURL as NSURL
        
        guard let resultURL = locationNSURL.filePathURL else {
            throw Error.unableToConvertToFilePathURL(from: location)
        }
        
        return resultURL
    }
    
    public static func move(
        from src: CuratorLocation,
        to dst: CuratorLocation
        ) throws {
        let srcURL = try convertToFilePathURL(from: src)
        
        let srcFileExistResult = srcURL.crt.fileExist
        
        if !srcFileExistResult.fileExist {
            throw Error.locationFileNotExist(src)
        }
        
        let dstURL = try dst.standardizedFileURL()
        
        if srcURL == dstURL {
            return
        }
        
        let dstFileExistResult = dstURL.crt.fileExist
        
        if dstFileExistResult.fileExist {
            throw Error.locationFileExist(dst)
        }
        try dstURL.crt.createDirectory(fileExistResult: dstFileExistResult)
        
        try CuratorFileManager.moveItem(at: srcURL, to: dstURL)
    }
    
    public static func delete(
        location: CuratorLocation,
        allowDirectory: Bool = false
        ) throws {
        let url = try location.standardizedFileURL()
        
        let fileExistResult = url.crt.fileExist
        
        if !fileExistResult.fileExist {
            throw Error.locationFileNotExist(location)
        }
        
        if !allowDirectory && fileExistResult.isDirectory {
            throw Error.locationIsDirectory(location)
        }
        
        try CuratorFileManager.removeItem(at: url)
    }
    
    public static func link(
        from src: CuratorLocation,
        to dst: CuratorLocation
        ) throws {
        let srcURL = try convertToFilePathURL(from: src)
        
        let srcFileExistResult = srcURL.crt.fileExist
        
        if !srcFileExistResult.fileExist {
            throw Error.locationFileNotExist(src)
        }
        
        let dstURL = try dst.standardizedFileURL()
        
        if srcURL == dstURL {
            return
        }
        
        let dstFileExistResult = dstURL.crt.fileExist
        
        if dstFileExistResult.fileExist {
            throw Error.locationFileExist(dst)
        }
        try dstURL.crt.createDirectory(fileExistResult: dstFileExistResult)
        
        try CuratorFileManager.linkItem(at: srcURL, to: dstURL)
    }
    
    public static func createDirectory(
        at location: CuratorLocation
        ) throws {
        let url = try location.standardizedFileURL()
        
        let directoryURL = url.crt.getDirectoryURL(greedy: true)
        
        try directoryURL.crt.createDirectory()
    }
}
