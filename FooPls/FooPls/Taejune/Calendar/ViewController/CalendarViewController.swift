
import UIKit
import JTAppleCalendar
import Firebase

class CalendarViewController: UIViewController {
    
    //MARK: - Property
    // 사용자 정의 팝업
    let popUpView: PopView = UINib(nibName:"PopView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! PopView
    var contentTitleList: [String] = []
    var contentKeys: [String] = []
    weak var postDelegate: PostCellDelegate?
    var reference: DatabaseReference!
    var userID: String!
    let formater = DateFormatter()
    var oldDate: String = ""
    var selectedDate: String?
    var contentDates: [String] = []
    
    //MARK: - IBOutlet
    @IBOutlet weak var customNaviBar: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearMonthLb: UILabel!
    
    //MARK: - 셀의 내부의 텍스트와 선택 됐을 때의 뷰를 색 지정
    let outsideMonthColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1.0)
    let monthColor = UIColor.black
    let selectedMonthColor = UIColor(red: 58.0/255.0, green: 41.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    let currentDateSelectedViewColor = UIColor(red: 78.0/255.0, green: 63.0/255.0, blue: 93.0/255.0, alpha: 1.0)
    let currentDayColor = UIColor(red: 1, green: 1, blue: 200.0/255.0, alpha: 1)
    let noCurrentDayColor = UIColor(red: 1, green: 254.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        reference = Database.database().reference()
        userID = Auth.auth().currentUser?.uid
        loadDate()
        setUpPopUpView()
        popUpView.alpha = 0
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUpView(_:)))
        gesture.delegate = self
        self.popUpView.baseSuperView.addGestureRecognizer(gesture)
    }
    
    //매번 캘린더를 셋업해줘야하기 때문에 viewWillAppear에서 실행
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCalendar()
    }
    
    //MARK: - @objc
    //제스쳐를 통헤 팝업뷰 밖을 누르게 되면 빠져나오는 효과를 줌
    @objc func dismissPopUpView(_ tap: UITapGestureRecognizer){
        self.popUpView.alpha = 0
    }
    
    //MARK: - Method
    private func loadDate() {
        reference.child("users").child(userID!).child("calendar").observe(.value) { [weak self] (snapshot) in
            guard let `self` = self else { return }
            self.contentDates.removeAll()
            if let value = snapshot.value as? [String : [String: Any]] {
                for (_, calendarDic) in value {
                    guard let date = calendarDic["date"] as? String else {return}
                    self.contentDates.append(date)
                    self.calendarView.reloadData()
                }
            }
        }
    }
    
    //MARK: - 처음 뷰가 불렸을 때 캘린더 셋팅
    private func setupCalendar() {
        //날짜 cell들의 간격
        calendarView.minimumLineSpacing = 0.5
        calendarView.minimumInteritemSpacing = 0
        //로드 될때 현재의 년, 월을 레이블에 나타내기 위해
        calendarView.visibleDates { (segInfo) in
            let date = segInfo.monthDates.first!.date
            
            self.formater.dateFormat = "yyyy년 MM월"
            self.yearMonthLb.text = self.formater.string(from: date)
            self.calendarView.scrollToDate(Date.init())
        }
    }
    
    //MARK: - 보이는 날의 정보를 보여 주기 위한 메소드
    private func setupViewCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        self.formater.dateFormat = "yyyy년 MM월"
        self.yearMonthLb.text = self.formater.string(from: date)
    }
    
    //셀이 선택 되었을 때 텍스트 색을 정해주기 위한 메소드
    private func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        formater.dateFormat = "yyyy년 MM월 dd일"
        let cellStateDay = formater.string(from: cellState.date)
        let currentDay = formater.string(from: Date.init())
        //현재 날짜의 셀의 배경을 다르게
        if currentDay == cellStateDay {
            validCell.backgroundColor = currentDayColor
        }else {
            validCell.backgroundColor = noCurrentDayColor
        }
        //선택된 셀의 뷰를 띄움
        if validCell.isSelected {
            validCell.calendarLb.textColor = selectedMonthColor
        }else {
            //현재 달의 텍스트 색과 다른 달의 텍스트 색을 다르게 함
            if cellState.dateBelongsTo == .thisMonth {
                validCell.calendarLb.textColor = monthColor
            }else {
                validCell.calendarLb.textColor = outsideMonthColor
            }
        }
    }
    
    //셀이 선택 되었을 때 셀의 선택 뷰를 표현하기 위한 메소드
    private func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        if validCell.isSelected {
            validCell.selectedView.isHidden = false
        }else {
            validCell.selectedView.isHidden = true
        }
    }
    
    //해당 날짜에 기록된 글이 있는지 확인하고 있으면 해당 날짜 셀에 그림 표시
    private func handleCellisContents(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        formater.dateFormat = "yyyy년 MM월 dd일"
        let cellStateDay = formater.string(from: cellState.date)
        if contentDates.contains(cellStateDay) {
            validCell.isContentImgView.isHidden = false
        }else {
            validCell.isContentImgView.isHidden = true
        }
    }
    
    //MARK: - Segue
    //선택된 데이터를 넘기기 위한 메소드
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewWrite" {
            let destinationController = segue.destination as! NewWriteViewController
            destinationController.selectedDate = selectedDate!
        }
    }
    
    //MARK: - IBAction
    //글쓰기 버튼 눌렀을 때
    @IBAction func writeBtnAction(_ sender: UIButton) {
        if selectedDate != nil {
            performSegue(withIdentifier: "NewWrite", sender: self)
        }else {
            let alertSheet = UIAlertController(title: "날짜 선택", message: "날짜를 선택해주세요", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertSheet.addAction(okAction)
            present(alertSheet, animated: true, completion: nil)
            return
        }
    }
}

//MARK: - Extension
extension CalendarViewController: JTAppleCalendarViewDelegate{
    //MARK: - 셀이 선택 되었을 때 불림
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        formater.dateFormat = "yyyy년 MM월 dd일"
        selectedDate = formater.string(from: date)
        // 데이트를 선택하면 그 날짜에 해당하는 데이터가 테이블 뷰에 나타남
        if oldDate == selectedDate {
            
            self.reference.child("users").child(self.userID!).child("calendar").queryOrdered(byChild: "date").queryEqual(toValue: self.selectedDate).observe(.value, with: { [weak self] (snapshot) in
                guard let `self` = self else { return }
                // 데이터 읽기 전에 배열 안에 든 데이터 지우고 데이터를 읽음
                self.contentTitleList.removeAll()
                if let value = snapshot.value as? [String : [String: Any]] {
                    for (key, calendarDic) in value {
                        guard let date = calendarDic["date"] as? String else { return }
                        if date == self.selectedDate {
                            guard let title = calendarDic["title"] as? String else { return }
                            self.contentKeys.insert(key, at: 0)
                            self.contentTitleList.insert(title, at: 0)
                        }
                    }
                }
                self.popUpView.tableView.reloadData()
            })
            self.popUpView.alpha = 1
            self.popUpWritingDelegate(date: selectedDate!)
        }else {
            oldDate = selectedDate!
        }
        handleCellisContents(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
    
    //MARK: - 셀의 선택이 풀렸을 때 불리는 함수
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellisContents(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
    
    //MARK: - 캔린더가 다시 보이게 될때 불리는 메소드, 팝업이 사라진 뒤 불림
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        handleCellisContents(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
    
    //MARK: - 스크롤 했을 때 보이는 날짜정보를 업데이트 하기 위한 메소드 (스크롤을 했을 때 불림)
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewCalendar(from: visibleDates)
    }
    
    //MARK: - 셀을 재사용할 때 셀의 상태와 셀의 정보를 읽기 위한 메소드
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.calendarLb.text = cellState.text
        handleCellisContents(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        
        return cell
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    //MARK: - 캘린더의 설정 (캘린더의 시작과 끝의 날짜를 지정)
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formater.dateFormat = "yyyy MM dd"
        formater.timeZone = Calendar.current.timeZone
        formater.locale = Calendar.current.locale
        
        let startDate = formater.date(from: "2017 01 01")!
        let endDate = formater.date(from: "2018 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
}

