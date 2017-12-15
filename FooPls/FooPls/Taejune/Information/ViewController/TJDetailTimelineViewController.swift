
import UIKit
import Firebase
import GooglePlacePicker

class TJDetailTimelineViewController: UIViewController, GMSPlacePickerViewControllerDelegate, UINavigationControllerDelegate , UIImagePickerControllerDelegate {

    //MARK: - Firebase
    var reference = Database.database().reference()
    var userID = Auth.auth().currentUser?.uid
    
    //MARK: - Property
    var postingIndex: String = ""
    var date: String?
    var longitude: Double?
    var latitude: Double?
    var address: String?
    var selectedKey: String?
    var photoName: String?
    
    @IBOutlet weak var detailDateLabel: UILabel!
    @IBOutlet weak var detailTitleTextField: UITextField!
    @IBOutlet weak var detailImgView: UIImageView!
    @IBOutlet weak var detailLocationTitleLabel: UILabel!
    @IBOutlet weak var detailLocationAddressLabel: UILabel!
    @IBOutlet weak var detailContentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetailData()
    }
    
    private func loadDetailData() {
        reference.child("users").child(userID!).child("calendar").child(selectedKey!).observe(.value) { [weak self] (snapshot) in
            guard let `self` = self else { return }
            if let value = snapshot.value as? [String: Any] {
                self.detailDateLabel.text = value["date"] as? String
                self.detailTitleTextField.text = value["title"] as? String
                let imgURL = value["photoID"] as? String
                self.detailImgView.kf.setImage(with: URL(string: imgURL!))
                self.detailLocationTitleLabel.text = value["locationTitle"] as? String
                self.detailLocationAddressLabel.text = value["address"] as? String
                self.detailContentTextView.text = value["content"] as? String
                self.photoName = value["photoName"] as? String
                self.date = value["date"] as? String
                self.longitude = value["longitude"] as? Double
                self.latitude = value["latitude"] as? Double
                self.address = value["address"] as? String
            }
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 글쓰기 버튼
    @IBAction func writeBtnAction(_ sender: UIButton) {
        guard let contentTitle = detailTitleTextField.text else { return }
        guard let _ = detailImgView.image else { return }
        guard let locationTitle = detailLocationTitleLabel.text else { return }
        guard let contentTxtView = detailContentTextView.text else { return }
        
        let alertSheet = UIAlertController(title: "등록", message: "이 글을 수정하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .default) { [unowned self] (action) in
            guard let uploadImg = UIImageJPEGRepresentation(self.detailImgView.image!, 0.3) else { return }

            Storage.storage().reference().child("calendar_images").child(self.photoName!).putData(uploadImg, metadata: nil, completion: { [unowned self] (metaData, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }else {
                    guard let photoID = metaData?.downloadURL()?.absoluteString else { return }
                    
                    let calendarDic = ["title": contentTitle,
                                       "author": self.userID!,
                                       "content": contentTxtView,
                                       "photoID": photoID,
                                       "photoName": self.photoName!,
                                       "locationTitle": locationTitle,
                                       "longitude": self.longitude!,
                                       "latitude": self.latitude!,
                                       "address": self.address!,
                                       "date": self.date!,
                                       "postTime": ServerValue.timestamp()] as [String: Any]
                    // MARK: Noti
                    NotificationCenter.default.post(name: .reload, object: contentTitle)
                    self.reference.child("users").child(self.userID!).child("calendar").child(self.selectedKey!).setValue(calendarDic)
                    let key = self.reference.child("users").childByAutoId().key
                    let postKey = NSArray(array: [key])
                    self.reference.child("posts").setValue(postKey)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "아니오", style: .default, handler: nil)
        alertSheet.addAction(okAction)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
    
    @IBAction func detailImgBtnAction(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let photo = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.detailImgView.image = photo
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func detailLocationBtnAction(_ sender: UIButton) {
        //잠시 주석처리함.
        let center = CLLocationCoordinate2D(latitude: 37.566627, longitude: 126.978432)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
        
        placePicker.navigationController?.navigationBar.barTintColor = UIColor.black
        placePicker.navigationController?.navigationBar.isTranslucent = false
        
        //구글 PlacePicker와 연결함
        //        let storyboard = UIStoryboard(name: "SKMain", bundle: nil)
        //        if let googlePicekerVC = storyboard.instantiateViewController(withIdentifier: "googlePlacePickerVC") as? UINavigationController {
        //            present(googlePicekerVC, animated: true, completion: nil)
        //        }
    }
    
    //MARK: - 장소를 선택했을 때 실행되는 메소드
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        viewController.dismiss(animated: true, completion: nil)
        self.longitude = place.coordinate.longitude
        self.latitude = place.coordinate.latitude
        self.detailLocationTitleLabel.text = place.name
        self.detailLocationAddressLabel.text = place.formattedAddress
        self.address = place.formattedAddress
    }
}