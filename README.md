# 네이버 오픈 API를 이용한 영화 정보 애플리케이션 만들기
## 시작하기에 앞서
이번 기술 블로그에서는 [네이버 개발자 센터](https://developers.naver.com/main/)에서 제공하는 **네이버 오픈 API**를 사용하는 방법에 대해서 알려드리고자 합니다. 
오픈 API란, API 중에서 플랫폼의 기능 또는 콘텐츠를 외부에서 웹 프로토콜(HTTP)로 호출해 사용할 수 있게 개방(open)한 API를 의미합니다. 
현재 네이버 오픈 API로 활용할 수 있는 기술에는 네아로(네이버 아이디로 로그인), 지도, 검색이 있으며, Clova의 음성 인식 기술과 음성 합성 기술, 얼굴 인식 기술, Papago의 기계 번역 기술 등이 있습니다.

### 예제 애플리케이션 소개
이번 포스트에서는 **영화 정보 애플리케이션**을 만들 것입니다. 사용자로부터 영화 검색어를 입력받은 후, 네이버 오픈 API 호출을 통해 검색어와 일치하는 영화 정보를 불러와 테이블뷰에 표시합니다. 그리고 원하는 영화를 터치하면 각 영화의 세부 정보를 보여줍니다. 
![Application Example Image](/tb000_media/0-1.png)
구현하고자 하는 핵심 기능은 **네이버의 검색 API**를 사용한 영화 검색 기능입니다. 영화 포스터 이미지를 불러오기 위해 **비동기 작업**을 사용해 지연 없이 바로 검색 결과를 확인할 수 있도록 테이블 뷰를 구성합니다. 마지막으로, **HTTP Request**를 사용하여 영화의 세부 정보를 보여주는 웹 뷰를 구성합니다. 

## 시작하기
### STEP 0. 스타터 프로젝트 다운로드
시작하기에 앞서 [GitHub](https://github.com/gfsusan/NaverAPIExample)에서 스타터 프로젝트를 다운로드하여 각 단계를 따라가시면 되겠습니다!  
프로젝트를 처음부터 만드시고 싶으신 분들은 아래 사진과 같이 UI를 구성해주시면 되겠습니다. 프로젝트를 만드실 때 **애플리케이션 이름**과 **애플리케이션 Bundle ID**를 기억해 두었다가 오픈API 신청 시 기입하시기 바랍니다. 
![Application UI](/tb000_media/0-2.png)

### STEP 1. 네이버 오픈 API

#### 애플리케이션 등록
네이버 오픈 API를 사용하기 위해서는 네이버로부터 **클라이언트 아이디**와 **클라이언트 시크릿**을 발급받아야 합니다. 이는 네이버 오픈API 사용자가 인증된 사용자인지 확인하는 고유한 아이디와 비밀번호로, 네이버 개발자센터의 **애플리케이션 등록** 메뉴에서 [애플리케이션을 등록](https://developers.naver.com/apps/#/register)하면 발급되는 값입니다. 

![Issue ClientID and ClientSecret](/tb000_media/1-1.png)
위와 같이 **애플리케이션 이름**을 프로젝트명과 동일하게 작성한 다음, **사용 API**를 **검색**으로 설정합니다. 마지막으로 **비로그인 오픈API 서비스 환경**에서 **iOS 설정**을 추가한 다음, Xcode 프로젝트 생성 시 **애플리케이션의 Bundle ID**를 정확하게 입력합니다. 

#### 클라이언트 아이디와 클라이언트 시크릿
애플리케이션 등록을 마치고 나면, [내 애플리케이션](https://developers.naver.com/apps/#/list) 항목 아래 등록한 애플리케이션의 목록이 나타납니다. 자신의 애플리케이션명을 클릭하면, 애플리케이션 정보가 나타나며, 자신의 **클라이언트 아이디**와 **클라이언트 시크릿**을 확인할 수 있습니다. 
![Check CliendID and ClientSecret](/tb000_media/1-2.png)

#### 코드
먼저, [Model.swift](https://github.com/gfsusan/NaverAPIExample/blob/master/NaverAPIExample/Model.swift)를 만들어 Movie 클래스를 만들어 줍니다. 

``` Swift
import Foundation
import UIKit

class Movie {
    var title:String?
    var link:String?
    var imageURL:String?
    var image:UIImage?
    var pubDate:String?
    var director:String?
    var actors:String?
    var userRating:String?
    
    init() {
        
    }
}
```

모든 속성은 Movie 객체를 생성한 후에 값을 입력해줄 것이기 때문에, Optional로 처리합니다.   
  
두번째는 [SearchViewController.swift](https://github.com/gfsusan/NaverAPIExample/blob/master/NaverAPIExample/SearchViewController.swift)입니다. 
``` Swift
class SearchViewController: UIViewController {
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let query = searchTextField.text {
            performSegue(withIdentifier: "searchSegue", sender: self)
        }
    }
  
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let moviesVC = segue.destination as? MoviesTableViewController {
            if let text = searchTextField.text {
                moviesVC.queryText = text
            }
        }
    }
 
}
```

먼저 SearchVC에서 MoviesTableVC로 향하는 **Segue**를 연결해두고, '검색'버튼을 눌렀을 때 Segue를 실행합니다. prepareForSegue 메소드에서는 MoviesTableVC의 **queryText** 필드에 텍스트 필드의 내용을 저장해줌으로써 다음 뷰로 검색어를 넘겨줍니다.  
  
세번째는 [MoviesTableViewController.swift](https://github.com/gfsusan/NaverAPIExample/blob/master/NaverAPIExample/MoviesTableViewController.swift)입니다. 
``` Swift
class MoviesTableViewController: UITableViewController, XMLParserDelegate{
    let clientID        = "huN1_ueBcLHV9AnTNwpi"    // ClientID
    let clientSecret    = "kb3OGCZ9rC"              // ClientSecret
    
    var queryText:String?                  // SearchVC에서 받아 오는 검색어
    var movies:[Movie]      = []           // API를 통해 받아온 결과를 저장할 array
    
    var strXMLData: String?         = ""   // xml 데이터를 저장
    var currentTag: String?  	    = ""   // 현재 item의 element를 저장
    var currentElement: String      = ""   // 현재 element의 내용을 저장
    var item: Movie?                = nil  // 검색하여 만들어지는 Movie 객체
}
```
우선, 위와  같이 MoviesTableViewController에게 **XMLParserDelegate** 프로토콜을 적용합니다.  
다음으로 네이버 개발자 센터에서 발급받은 **클라이언트 아이디**와 **클라이언트 시크릿**을 변수에 저장합니다. 
    

##### XML 데이터의 예
![Xml Data Example](/tb000_media/1-3.png)
**strXMLData**에는 https://openapi.naver.com에 요청한 쿼리에 대한 응답인 xml 데이터가 저장됩니다. **xml 데이터**는 위와 같은 형식으로 이루어져 있습니다. 우리가 주의 깊게 볼 부분은 <item> 태그로 둘러싸여 있는 부분입니다. title, link, subtitle, pubDate, director, actor, userRating 등에 해당하는 내용을 **element**라고 부르며, 각 element는 <title></title>과 같이 **태그**로 둘러싸여 있습니다. 이제 이 데이터를 Parse(분석, 또는 쪼갬)하여 Movie객체를 생성할 것입니다. **currentTag**는 현재 tag를 알려주는 변수이고, **currentElement**은 현재 element에 해당하는 데이터를 저장하게 될 변수입니다. **item**은 Movie의 객체로, 한 개의 item을 Parsing에 성공하면 하나의 객체가 완성되는 것입니다.  

``` Swift
    func searchMovies() {
        // movies 초기화
        movies = []
        
        // queryText가 없으면 return
        guard let query = queryText else {
            return
        }
        
        let urlString = "https://openapi.naver.com/v1/search/movie.xml?query=" + query
        let urlWithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: urlWithPercentEscapes!)
        
        var request = URLRequest(url: url!)
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러가 있으면 리턴
            guard error == nil else {
                print(error)
                return
            }
            
            // 데이터가 비었으면 출력 후 리턴
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            // 데이터 초기화
            self.item?.actors = ""
            self.item?.director = ""
            self.item?.imageURL = ""
            self.item?.link = ""
            self.item?.pubDate = ""
            self.item?.title = ""
            self.item?.userRating = ""
            
            // Parse the XML
            let parser = XMLParser(data: Data(data))
            parser.delegate = self
            let success:Bool = parser.parse()
            if success {
                print(self.strXMLData)
            } else {
                print("parse failure!")
            }
        }
        task.resume()
    }

```
**10-12**: 요청 텍스트를 담아 url을 생성합니다. Line 10의 코드를 작성하는 이유는 **query** 문자열 안에 url에 허용되지 않는 문자가 들어있을 때 인코딩을 통해서 HTTP 요청을 보낼 때 문제가 생기지 않도록 하는 것입니다.   
**14-17**: URL Request를 생성합니다. URL 요청에는 앞서 발급받은 클라이언트 아이디와 클라이언트 시크릿을 함께 전송합니다.  
**19-30**: URL Connection Task를 생성합니다. 에러가 있거나, 데이터가 비어있으면 리턴합니다. 그리고 item을 초기화합니다.  
**42-49**: **parse()** 메소드를 호출하여 xml parsing을 시작합니다. parse()메소드를 호출하게 되면, **parserDidStartElement**, **parserFoundCharacters**, **parserDidEndElement** 메소드가 차례로 호출됩니다.  
  
##### parserDidStartElement()
``` Swift
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "title" || elementName == "link" || elementName == "image" || elementName == "pubDate" || elementName == "director" || elementName == "actor" || elementName == "userRating" {
            currentElement = ""
            if elementName == "title" {
                item = Movie()
            }
        }
    }
```
이 메소드는 parser가 시작태그를 발견했을 때 호출됩니다. 태그의 내용은 "**elementName**"에 매개변수로 주어집니다. 태그가 title, link, image, pubDate, director, actor, 또는 userRating과 일치하면 currentElement를 초기화하고, 첫 번째 태그인 title과 일치하면 새로운 Movie 객체를 생성합니다. 


##### parserFoundCharacers()
``` Swift
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElement += string
    }
```
이 메소드는 **parserDidStartElement**() 다음으로 호출됩니다. 시작 태그를 인식한 후 데이터를 읽었음을 의미하는데, 간단하게 **currentElement**에 string의 내용을 덧붙여줍니다.


##### parserDidEndElement()
``` Swift
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "title" {
            item?.title = currentElement.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        } else if elementName == "link" {
            item?.link = currentElement
        } else if elementName == "image" {
            item?.imageURL = currentElement
        } else if elementName == "pubDate" {
            item?.pubDate = currentElement
        } else if elementName == "director" {
            item?.director = currentElement
            if item?.director != "" {
                item?.director?.removeLast()
            }
        } else if elementName == "actor" {
            item?.actors = currentElement
            if item?.actors != "" {
                item?.actors?.removeLast()
            }
        } else if elementName == "userRating" {
            item?.userRating = currentElement
            movies.append(self.item!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
```
이 메소드는 **parserFoundCharaters**() 다음으로 호출되며, 끝 태그를 인식했다는 의미입니다. 이 메소드에서는 현재 태그에 해당하는 Movie의 속성을 지정해줍니다. 예를 들어, </title>을 발견했으면 ```item?.title = currentElement```을 해줍니다. Line 3에서 *replacingOccurrences*를 해주는 것은 검색API에서 검색어와 일치하는 문자열을 볼드체 태그로 감싸서 응답을 주기 때문에 태그를 제거해 주는 작업입니다.  
**10-14**와 **15-19** 같은 경우에는 다수의 인물을 구분하기 위해 "|" 문자를 구별자로 사용하는데, 문자열의 마지막에 불필요한 "|"를 삭제해주는 작업입니다.   
**20-25**에는 item을 movies 배열에 추가해주고, 테이블뷰를 새로고침합니다. **DispatchQueue.main.async**에 대해서는 **STEP 2**에서 다룹니다. 



### STEP 2. 비동기 작업
다음은 **비동기 작업**에 대해서 알아봅시다. 
쇼핑 애플리케이션 사용 경험을 떠올려 보면, 테이블 뷰에 콘텐츠가 로딩된 후, 상품 이미지가 하나 둘 씩 나타나는 것을 보신 적이 있을 것입니다. 이는 웹으로부터 사진을 다운로드하느라 뷰가 늦게 로딩되는 것을 방지하기 위해서, 기본 이미지를 먼저 띄워 놓고, 백그라운드에서 이미지 다운로드가 완료되는 즉시 이미지를 뷰에 나타내는 것입니다.  따라서 비동기 작업 큐(Queue)에 사진 다운로드와 같은 작업을 넣어 두고, 뷰가 로딩된 이후에 차례로 작업을 완료해 나가는 것입니다.   
이번 단계에서는 MoviesTableVC가 로딩된 이후에 차례로 영화의 포스터 이미지를 다운로드 받아 테이블 뷰에 표시하는 기능을 구현할 것입니다. 우선 [Model.swift](https://github.com/gfsusan/NaverAPIExample/blob/master/NaverAPIExample/Model.swift)의 **getPosterImage**() 메소드를 구현하고, [MoviesTableViewController.swift](https://github.com/gfsusan/NaverAPIExample/blob/master/NaverAPIExample/MoviesTableViewController.swift)의 **tableView(cellForRowAt)** 메소드를 살펴봅시다. 

##### Model.swift
``` Swift
    func getPosterImage() {
        guard imageURL != nil else {
            return nil
        }
        if let url = URL(string: imageURL!) {
            if let imgData = try? Data(contentsOf: url) {
                if let image = UIImage(data: imgData) {
		    self.image = image
                }
            }
        }
        return
    }
```
여기서는 movie 객체의 imageURL이 존재하는지 먼저 확인한 다음, imageURL을 가지고 URL 객체를 생성하여 이를 가지고 이미지 데이터를 불러옵니다. 이미지 데이터를 사용해서 UIImage를 생성하고, self의 image에 저장합니다.  
   

##### MoviesTableViewController.swift
``` Swift
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCellIdentifier", for: indexPath) as! MoviesTableViewCell
        let movie = movies[indexPath.row]
        
	// cell 구성 부분 생략

        // Async activity
        // 영화 포스터 이미지 불러오기
        if let posterImage = movie.image {
            cell.posterImageView.image = posterImage
        } else {
            cell.posterImageView.image = UIImage(named: "noImage")
            DispatchQueue.main.async(execute: {
                movie.getPosterImage()
                guard let thumbImage = movie.image else {
                    return
                }
                cell.posterImageView.image = thumbImage
            })
        }
        return cell
    }
```
**9-10**: image가 이미 존재하면 즉시 이미지를 cell에 나타냅니다.  
**11-20**: 이미지가 없으면, 우선 디폴트 이미지를 cell에 먼저 나타내고 비동기 작업 큐에 이미지 다운로드 작업을 넣어둔 다음, 이미지 다운로드 작업이 끝나면 포스터 이미지를 cell에 나타냅니다.    
 

### STEP 3. UIWebView 사용
이제 셀을 터치했을 때 영화의 세부정보를 볼 수 있는 뷰를 구성할 것입니다. 이 뷰는 웹 뷰를 포함하고 있으며, 뒤로 가기, 앞으로가기, 새로고침 버튼을 구현할 것입니다. 우선 MoviesTableVCa에서 MoviesDetailVC로 넘어가는 Segue를 구성해줍니다. 

##### MoviesTableViewController.swift
``` Swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let movieDetailVC = segue.destination as? MovieDetailViewController {
            if let index = tableView.indexPathForSelectedRow?.row {
                movieDetailVC.urlString = movies[index].link
            }
        }
    }
```

##### MovieDetailViewController.swift
``` Swift
class MovieDetailViewController: UIViewController {
    
    var urlString:String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlStr = urlString {
            let url = URL (string: urlStr);
            let request = URLRequest(url: url!);
            webView.loadRequest(request);
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @IBAction func forwardButtonPressed(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @IBAction func reloadButtonPressed(_ sender: Any) {
        webView.reload()
    }
}
```
**7-14**: **viewDidLoad**()에서 URL을 생성하여 URL 요청을 생성합니다. 그리고 웹뷰에 요청에 대한 응답을 나타냅니다.  
**16-20**: 뒤로가기 버튼 액션. 뒤로 갈 페이지가 존재하면 해당 페이지로 이동합니다.  
**21-25**: 앞으로가기 버튼 액션. 앞으로 갈 페이지가 존재하면 해당 페이지로 이동합니다.  
**26-28**: 새로고침 버튼 액션. 페이지를 새로고침합니다.  
  

