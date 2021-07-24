//
//  FileViewModel.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/22.
//

import Foundation

class FileViewModel{
    
    static var shared = FileViewModel()
    
    func saveFile(_ data : String, fileName : String){
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let sampleFileName = directory.appendingPathComponent(fileName)
            do{
                try data.write(to: sampleFileName, atomically: true, encoding: .utf8)
            }catch let error{
                print("1 \(error.localizedDescription)")
            }
        }
    }
    
    func loadFile(_ name : String) -> Data?{
        let nsDocument = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocument, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let file = URL(fileURLWithPath: dirPath).appendingPathComponent(name) 
            if let data = try? Data(contentsOf: file){
                return data
            }
            return nil
        }
        return nil
    }
    
    func loadFile(_ name : String) -> NSData?{
        let nsDocument = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocument, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let file = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
            if let data = NSData(contentsOf: file){
                return data
            }
            return nil
        }
        return nil
    }
    
    func deleteFile(_ name : String){
        let nsDocument = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocument, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let file = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
            do{
                try FileManager.default.removeItem(at: file)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
}
