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
프로젝트를 처음부터 만드시고 싶으신 분들은 아래 사진과 같이 UI를 구성해주시면 되겠습니다. 프로젝트를 만드실 때 애플리케이션 이름과 애플리케이션 Bundle ID를 기억해 두었다가 오픈API 신청 시 기입하시기 바랍니다. 
![Application UI](/tb000_media/0-2.png)

### STEP 1. 네이버 오픈 API

#### 애플리케이션 등록
네이버 오픈 API를 사용하기 위해서는 네이버로부터 **클라이언트 아이디**와 **클라이언트 시크릿**을 발급받아야 합니다. 이는 네이버 오픈API 사용자가 인증된 사용자인지 확인하는 고유한 아이디와 비밀번호로, 네이버 개발자센터의 **애플리케이션 등록** 메뉴에서 [애플리케이션을 등록](https://developers.naver.com/apps/#/register)하면 발급되는 값입니다. 

![Issue ClientID and ClientSecret](/tb000_media/1-1.png)
위와 같이 **애플리케이션 이름**을 프로젝트명과 동일하게 작성한 다음, **사용 API**를 **검색**으로 설정합니다. 마지막으로 **비로그인 오픈API 서비스 환경**에서 **iOS 설정**을 추가한 다음, Xcode 프로젝트 생성 시 애플리케이션의 Bundle ID를 정확하게 입력합니다. 

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

먼저 SearchVC에서 MoviesTableVC로 향하는 Segue를 연결해두고, '검색'버튼을 눌렀을 때 Segue를 실행합니다. prepareForSegue 메소드에서는 MoviesTableVC의 **queryText** 필드에 텍스트 필드의 내용을 저장해줌으로써 다음 뷰로 검색어를 넘겨줍니다.

세번째는 [MoviesTableViewController.swift](https://github.com/gfsusan/NaverAPIExample/blob/master/NaverAPIExample/MoviesTableViewController.swift)입니다. 
``` Swift
class MoviesTableViewController: UITableViewController, XMLParserDelegate{
    let clientID        = "huN1_ueBcLHV9AnTNwpi"    // ClientID
    let clientSecret    = "kb3OGCZ9rC"              // ClientSecret
    
    var queryText:String?                  // SearchVC에서 받아 오는 검색어
    var movies:[Movie]      = []           // API를 통해 받아온 결과를 저장할 array
    
    var strXMLData: String?         = ""   // xml 데이터를 저장
    var currentElement: String?     = ""   // 현재 item의 element를 저장
    var currentString: String       = ""   // 현재 element의 내용을 저장
    var item: Movie?                = nil  // 검색하여 만들어지는 Movie 객체
}
```
우선, 다음과 같이 MoviesTableViewController에게 XMLParserDelegate 프로토콜을 적용합니다. 
다음으로 네이버 개발자 센터에서 발급받은 **클라이언트 아이디**와 **클라이언트 시크릿**을 변수에 저장합니다. 
![Xml Data Example](/tb000_media/1-3.png)
**strXMLData**에는 https://openapi.naver.com에 요청한 쿼리에 대한 응답인 xml 데이터가 저장됩니다. xml 데이터는 위와 같은 형식으로 이루어져 있습니다. 우리가 주의 깊게 볼 부분은 <item> 태그로 둘러싸여 있는 부분입니다. **title**, **link**, **subtitle**, **pubDate**, **director**, **actor**, **userRating** 등을 **element**라고 부르며, 각 element는 <title>과 같이 꺽쇄로 둘러싸여 있습니다. 이제 이 데이터를 Parse(분석, 또는 쪼갬)하여 Movie객체를 만들 것입니다. 따라서 currentElement는 현재 element를 알려주는 변수이고, currentString은 현재 element에 해당하는 데이터를 저장하게 될 변수입니다. **item**은 Movie의 객체로, 한 개의 item을 Parsing에 성공하면 하나의 객체가 완성되는 것입니다.

``` Swift

```
**10-12**: 요청 텍스트를 담아 url을 생성합니다. Line 10의 코드를 작성하는 이유는 **query** 문자열 안에 url에 허용되지 않는 문자가 들어있을 때 인코딩을 통해서 HTTP 요청을 보낼 때 문제가 생기지 않도록 하는 것입니다. 
**14-17**: URL Request를 생성합니다. URL 요청에는 앞서 발급받은 클라이언트 아이디와 클라이언트 시크릿을 함께 전송합니다. 
**  


### STEP 2. 비동기 작업
<script src="https://gist.github.com/gfsusan/05b778b113610d8dc62982ea3b2ab296.js"></script>

### STEP 3. UIWebView 사용


