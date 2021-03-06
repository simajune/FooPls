//
//  PostModel.swift
//  FooplsProject
//
//  Created by ilhan won on 2017. 12. 5..
//  Copyright © 2017년 ilhan won. All rights reserved.
//

import Foundation
import Photos

struct  PostModel {
    
    //MARK : - Variable

    var storeName : String = ""
    var storeAddress : String = ""
    var nickName : String = ""
    var writerUid : String = ""

    //Optional
    var postingAutoID : String?
    var contentsText : String?
    var postTitle : String?
    var storeImg : UIImage?
    var imageurl : String?
    var thoughts : String?
    var date : String?
    var timeStamp : Any?
    var photoName : String?
    var author : String?
    var photoID: String?
    var storeImgData : Data?{
        if let image = storeImg
        {
            return UIImageJPEGRepresentation(image, 0.5)!
        }
        return nil
    }
    
    var latitude : Double?
    var longitude : Double?
    
    var postData : [PostModel] = []
    
    //캘린더 사용할 때 사용할 모델
    init(storeName : String, storeAddress : String, contentText : String, storeImgUrl : String, date : String,  timeStamp : String, lati : Double, longi : Double, photoName : String, postTitle : String, nickname : String ) {
        self.storeName = storeName
        self.storeAddress = storeAddress
        self.contentsText = contentText
        self.imageurl = storeImgUrl
        self.date = date
        self.timeStamp = timeStamp
        self.latitude = lati
        self.longitude = longi
        self.photoName = photoName
        self.postTitle = postTitle
        self.nickName = nickname
    }
    
    //포스팅 모델
    init(storeName : String, storeAddress : String, content : String, latitude : Double, longitude : Double, storeImgurl : String, date : String, timeStamp : Any, photoName : String, thoughts : String , nickname : String, autoID : String) {
        self.storeName = storeName
        self.storeAddress = storeAddress
        self.contentsText = content
        self.latitude = latitude
        self.longitude = longitude
        self.imageurl = storeImgurl
        self.date = date
        self.timeStamp = timeStamp
        self.photoName = photoName
        self.thoughts = thoughts
        self.nickName = nickname
        self.postingAutoID = autoID
    }
    
    //포스팅 이벤트 수신대기 메소드에서 대응해줄 모델
    init(dbValueObserver dic : [String : Any]) {
        self.storeName = (dic["storename"] as? String)!
        self.storeAddress = (dic["storeaddress"] as? String)!
        self.contentsText = dic["content"] as? String
        self.latitude = dic["latitude"] as? Double
        self.longitude = dic["longitude"] as? Double
        self.thoughts = dic["thoughts"] as? String
        self.date = dic["date"] as? String
        self.timeStamp = dic["timestamp"]
        self.photoName = dic["photoname"] as? String
        self.nickName = (dic["nickname"] as? String)!
        self.postingAutoID = dic["postingautoid"] as? String
        self.writerUid = (dic["uid"] as? String)!
    }
    
    //포스팅 이벤트 수신대기 메소드에서 대응해줄 모델
    init(storeName : String, storeAddress : String, contentText : String, storeImgurl : String, lati : Double, longi : Double, thoughts : String, nickname : String) {
        self.storeName = storeName
        self.storeAddress = storeAddress
        self.contentsText = contentText
        self.imageurl = storeImgurl
        self.latitude = lati
        self.longitude = longi
        self.thoughts = thoughts
        self.nickName = nickname
    }
    
    //구글플레이스에서 정보가져올때
    init (lati : Double, longi : Double, address : String, placename : String ) {
        self.storeName = placename
        self.storeAddress = address
        self.latitude = lati
        self.longitude = longi
    }
    
    init (imageUrl : String, photoname : String) {
        self.imageurl = imageUrl
        self.photoName = photoname
    }
    
    //Any = [String : [ String : [String : String]]]
    init(dictionary : [String : Any]) {
        self.storeName = (dictionary["storename"] as? String)!
        self.storeAddress = (dictionary["storeaddress"] as? String)!
        self.contentsText = dictionary["content"] as? String
        self.imageurl = dictionary["imageurl"] as? String
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.thoughts = dictionary["thoughts"] as? String
        self.date = dictionary["date"] as? String
        self.timeStamp = dictionary["timestamp"] as? String
        self.photoName = dictionary["photoname"] as? String
        self.nickName = (dictionary["nickname"] as? String)!
        self.photoID = dictionary["photoID"] as? String
    }
    
}

