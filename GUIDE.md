# 맑은프레임워크 AI 코딩 가이드

> **이 문서는 AI가 맑은프레임워크 코드를 작성할 때 참조하는 완전한 가이드입니다.**

---

## 📋 빠른 체크리스트 (코드 작성 후 확인)

코드를 작성한 후 반드시 확인하세요:

- [ ] **명명 규칙**: `UserDao user`, `DataSet info/list` (userDao ❌, ds ❌)
- [ ] **Postback**: `if(m.isPost())` 후 `return` 필수
- [ ] **수정 페이지**: 데이터 조회를 먼저 수행 (POST/GET 모두)
- [ ] **JSP/HTML 분리**: JSP에 HTML 없음 (완전 분리)
- [ ] **예외 처리**: try-catch 없음 (boolean 체크)
- [ ] **파라미터**: GET은 `m.rs()`, POST는 `f.get()`
- [ ] **SQL Injection**: `query("WHERE id = ?", new Object[]{id})`
- [ ] **XSS 방지**: 템플릿 `{{변수}}` 사용 (자동 escape)
- [ ] **날짜 처리**: `VARCHAR(14)` + `m.time()`
- [ ] **Page 순서**: `setBody()` 먼저, 그 다음 `setVar()`
- [ ] **DataSet**: `next()` 호출 필수
- [ ] **AJAX**: JSON 응답 (`j.success()` / `j.error()`)
- [ ] **표준 에러 코드**: `NOT_FOUND`, `UNAUTHORIZED` 등
- [ ] **유효성 검증**: `f.validate()` 사용 (POST 처리 시)
- [ ] **로그인 체크**: `if(!isLogin)` 사용 (userId ❌)
- [ ] **공통 변수**: `userId`, `userName`, `isLogin`은 init.jsp에서 설정

**파일 업로드 시 추가 체크**:
- [ ] 확장자 검증: `f.addElement("file", null, "allow:'jpg|png|gif'")`
- [ ] 파일 필수: `f.addElement("file", null, "required:'Y'")`

---

## 목차

1. [맑은프레임워크란?](#1-맑은프레임워크란)
2. [기본 구조](#2-기본-구조)
3. [필수 규칙](#3-필수-규칙)
4. [자주 사용하는 패턴](#4-자주-사용하는-패턴)
5. [보안 가이드](#5-보안-가이드)
6. [템플릿 문법](#6-템플릿-문법)
7. [자주 하는 실수](#7-자주-하는-실수)
8. [디버깅](#8-디버깅)
9. [부록](#9-부록)

---

## 1. 맑은프레임워크란?

**JSP 기반의 간결하고 실용적인 웹 프레임워크**

### 핵심 철학

- **단순함(Simplicity)**: 복잡한 것보다 단순하고 명확한 코드
- **관심사 분리**: JSP는 로직, HTML은 출력만
- **예외 내부 처리**: try-catch 불필요, boolean 리턴으로 성공/실패 판단
- **투명한 동작**: 자동화하되, 개발자가 이해하고 제어 가능

### 핵심 객체 (init.jsp에서 초기화)

```jsp
Malgn m = new Malgn(request, response, out);  // 유틸리티
Form f = new Form();                           // 폼 처리
Page p = new Page();                           // 템플릿 렌더링
```

---

## 2. 기본 구조

### 파일 구조

```
프로젝트/
├── src/                      # Java 소스 (DAO)
│   └── dao/
│       └── UserDao.java
│
└── public_html/              # 웹 루트
    ├── init.jsp             # 공통 초기화
    ├── index.jsp            # 루트 리다이렉트 (→ /main/index.jsp)
    ├── main/                # JSP 파일 (비즈니스 로직)
    │   ├── index.jsp        # 실제 메인 페이지
    │   ├── user_list.jsp
    │   ├── user_insert.jsp
    │   └── user_modify.jsp
    ├── html/                # HTML 템플릿 (출력)
    │   ├── layout/
    │   └── main/
    │       ├── user_list.html
    │       └── user_form.html
    └── WEB-INF/
        ├── classes/         # 컴파일된 클래스
        ├── lib/
        │   └── malgn.jar
        └── config.xml
```

### 루트 리다이렉트 패턴

루트 (`/index.jsp`)는 리다이렉트만 수행하고, 실제 메인 페이지는 기능별 폴더에 위치시킵니다.

**루트 index.jsp** (`/index.jsp`):
```jsp
<%@ page contentType="text/html; charset=utf-8" %><%
response.sendRedirect("/main/index.jsp");
%>
```

**실제 메인 페이지** (`/main/index.jsp`):
```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

p.setLayout("main");
p.setBody("main.index");
p.setVar("title", "메인 페이지");

p.display();

%>
```

**장점**:
- 루트 파일이 깔끔하게 유지됨
- 모든 기능 JSP가 폴더별로 정리됨
- URL 구조가 명확해짐 (`/main/`, `/board/`, `/member/` 등)

### DAO 클래스 작성

**기본 DAO 클래스**:

```java
// /src/dao/UserDao.java
package dao;

import malgnsoft.db.*;

public class UserDao extends DataObject {
    public UserDao() {
        this.table = "tb_user";  // 테이블명
        this.PK = "id";          // Primary Key (선택, 기본값: id)
    }
}
```

**컴파일**:

```bash
# Ant 사용 (권장)
ant compile

# 또는 수동 컴파일
javac -cp public_html/WEB-INF/lib/malgn.jar \
      -d public_html/WEB-INF/classes \
      src/dao/UserDao.java
```

**JSP에서 사용**:

```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

UserDao user = new UserDao();
DataSet list = user.find();

%>
```

### JSP 파일 작성 규칙

**모든 JSP 파일은 다음 형식으로 시작해야 합니다:**

```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%
```

**주의사항**:
- `<%@ page contentType="text/html; charset=utf-8" %>` 지시자는 반드시 JSP 파일의 첫 줄에 위치해야 합니다
- `<%@ page import="dao.*" %>` 는 **init.jsp에 포함**되어 있으므로 개별 JSP에서 작성하지 않습니다
- init.jsp가 모든 필요한 import를 처리합니다 (`dao.*`, `malgnsoft.db.*`, `malgnsoft.util.*` 등)
- contentType을 지정하지 않으면 인코딩 문제가 발생할 수 있습니다

**init.jsp의 import 구문**:
```jsp
<%@ page import="java.util.*,java.io.*,malgnsoft.db.*,malgnsoft.util.*,malgnsoft.json.*,dao.*" %>
```

**고급 DAO 예제** (커스텀 메소드):

```java
package dao;

import malgnsoft.db.*;

public class UserDao extends DataObject {
    public UserDao() {
        this.table = "tb_user";
    }

    // 활성 사용자 조회
    public DataSet findActive() {
        return this.find("status = 1");
    }

    // 이메일로 사용자 찾기
    public DataSet findByEmail(String email) {
        return this.find("email = ?", new Object[]{email});
    }

    // 레벨별 사용자 수
    public int countByLevel(int level) {
        DataSet rs = this.query(
            "SELECT COUNT(*) as cnt FROM " + this.table + " WHERE level = ?",
            new Object[]{level}
        );
        return rs.next() ? rs.i("cnt") : 0;
    }
}
```

---

## 3. 필수 규칙

### 3.1 명명 규칙 (절대 규칙)

#### Dao 변수명

```java
// ✅ 올바름: 테이블명에서 tb_ 제거 후 소문자
UserDao user = new UserDao();          // tb_user
OrderDao order = new OrderDao();       // tb_order
ProductDao product = new ProductDao(); // tb_product

// ❌ 절대 금지
UserDao userDao = new UserDao();
UserDao ud = new UserDao();
```

**유일한 예외**: DataObject
```java
DataObject dao = new DataObject();  // 이것만 dao 허용
```

#### DataSet 변수명

```java
// ✅ 단일 레코드
DataSet info = user.find("id = 1");
DataSet data = user.get(1);

// ✅ 복수 레코드
DataSet list = user.find();
DataSet userList = user.find();
DataSet productList = product.find();

// ❌ 금지
DataSet ds = user.find();
DataSet result = user.find();
```

---

### 3.2 Postback 패턴 (등록/수정)

**등록과 수정은 같은 JSP 파일 내에서 처리합니다.**

#### 등록 페이지 기본 패턴

```jsp
<%@ include file="/init.jsp" %><%

// 1. 유효성 검증 규칙 설정
f.addElement("name", null, "required:'Y', minlength:2");
f.addElement("email", null, "required:'Y', type:'email'");

// 2. POST 처리
if(m.isPost() && f.validate()) {
    UserDao user = new UserDao();
    user.item("name", f.get("name"));
    user.item("email", f.get("email"));
    user.item("reg_date", m.time());

    if(user.insert()) {
        m.jsAlert("등록되었습니다.");
        m.jsReplace("list.jsp");
    } else {
        m.jsError("등록 실패: " + user.getErrMsg());
    }
    return;  // ⚠️ 필수!
}

// 3. GET 처리 (폼 표시)
p.setLayout("default");
p.setBody("main.user_form");
p.setVar("is_insert", true);
p.setVar("form_script", f.getScript());  // 클라이언트 검증 스크립트
p.display();

%>
```

#### 수정 페이지 특별 규칙

**반드시 데이터 조회를 먼저 수행!**

```jsp
<%@ include file="/init.jsp" %><%

int id = m.ri("id");

// 1. 먼저 조회 (POST/GET 모두)
UserDao user = new UserDao();
DataSet info = user.find("id = ?", new Object[]{id});

if(!info.next()) {
    m.jsError("데이터를 찾을 수 없습니다.");
    return;
}

// 2. 검증 규칙 설정 (기존 값 전달)
f.addElement("name", info.s("name"), "required:'Y', minlength:2");
f.addElement("email", info.s("email"), "required:'Y', type:'email'");

// 3. POST 처리
if(m.isPost() && f.validate()) {
    user.item("name", f.get("name"));
    user.item("email", f.get("email"));
    user.item("mod_date", m.time());

    if(user.update("id = ?", new Object[]{id})) {
        m.jsAlert("수정되었습니다.");
        m.jsReplace("list.jsp");
    } else {
        m.jsError("수정 실패: " + user.getErrMsg());
    }
    return;
}

// 4. GET 처리 (폼 표시)
p.setLayout("default");
p.setBody("main.user_form");
p.setVar("is_modify", true);
p.setVar("form_script", f.getScript());  // 자동으로 값 설정됨
p.display();

%>
```

**이유**: POST 요청 시에도 URL의 id 파라미터를 재확인하여 권한이 없는 데이터 수정 방지

---

### 3.3 JSP와 HTML 완전 분리

#### ❌ 절대 금지: JSP에 HTML 혼재

```jsp
<div class="user">
<%
UserDao user = new UserDao();
DataSet list = user.find();
while(list.next()) {
%>
    <p><%=list.s("name")%></p>
<% } %>
</div>
```

#### ✅ 올바름: 완전 분리

**JSP** (`/main/user_list.jsp` - 로직만):
```jsp
<%@ include file="/init.jsp" %><%

UserDao user = new UserDao();
DataSet list = user.find();

p.setLayout("default");
p.setBody("main.user_list");
p.setLoop("list", list);
p.display();

%>
```

**HTML** (`/html/main/user_list.html` - 출력만):
```html
<div class="user">
<!--@loop(list)-->
    <p>{{list.name}}</p>
<!--/loop(list)-->
</div>
```

---

### 3.4 예외 처리 (try-catch 금지)

#### ❌ 절대 금지: try-catch 사용

```jsp
try {
    user.insert();
    m.p("성공");
} catch(Exception e) {
    m.p("실패");
}
```

#### ✅ 올바름: boolean 리턴값 체크

```jsp
if(user.insert()) {
    m.p("성공");
} else {
    m.p("실패: " + user.getErrMsg());
}
```

**동작 방식**:
- 모든 프레임워크 메소드는 예외를 내부에서 처리
- 성공 시 `true`, 실패 시 `false` 반환
- 에러 메시지는 `getErrMsg()`로 확인
- 모든 예외는 자동으로 로그 파일에 기록

---

### 3.5 GET/POST 파라미터 처리 구분

#### GET 파라미터 (XSS 필터 자동)

```jsp
// ✅ 검색어, 페이지, ID 등
String keyword = m.rs("keyword");  // XSS 필터 적용
int page = m.ri("page");           // 정수 변환
int id = m.ri("id");

// 검색 조건에 사용
user.addSearch("name,email", keyword, "LIKE");
```

#### POST 데이터 (원본 보존)

```jsp
// ❌ 불필요한 변수화 (모든 파라미터를 변수로 만들 필요 없음)
if(m.isPost()) {
    String name = f.get("name");
    String email = f.get("email");
    String phone = f.get("phone");

    user.item("name", name);
    user.item("email", email);
    user.item("phone", phone);
}

// ✅ 올바름 (필요한 경우만 변수화)
if(m.isPost()) {
    // 비교나 검증이 필요한 경우만 변수화
    String passwd = f.get("passwd");
    if(!passwd.equals(f.get("passwd_confirm"))) {
        m.jsError("비밀번호가 일치하지 않습니다.");
        return;
    }

    // 메소드 호출에 필요한 경우만 변수화
    String email = f.get("email");
    if(user.isDuplicateEmail(email)) {
        m.jsError("이미 등록된 이메일입니다.");
        return;
    }

    // 단순 저장은 직접 사용
    user.item("email", email);
    user.item("passwd", Malgn.sha256(passwd));
    user.item("name", f.get("name"));
    user.item("phone", f.get("phone"));
}
```

**이유**:
- **m.rs()**: GET 파라미터는 URL에 노출되므로 XSS 공격 위험 → 자동 필터링
- **f.get()**: POST 데이터는 DB에 저장할 원본 데이터 → 필터링 없음
- 출력 시에는 템플릿에서 자동으로 escape 처리
- **변수는 필요한 경우만**: 비교, 검증, 여러 번 사용 시에만 변수화

---

### 3.6 SQL Injection 방지

#### ❌ 절대 금지: 직접 문자열 연결

```jsp
String email = request.getParameter("email");
user.query("WHERE email = '" + email + "'");
```

#### ✅ 올바름: PreparedStatement 방식

```jsp
String email = m.rs("email");
user.query("WHERE email = ?", new Object[]{email});
user.find("status = ? AND level >= ?", new Object[]{1, 5});
```

---

### 3.7 표준 응답 형식 (API/AJAX)

#### 성공 응답

```jsp
Json j = new Json();
j.success("메시지", data);
// → {"success":true, "message":"메시지", "data":{...}}
```

#### 에러 응답

```jsp
j.error("ERROR_CODE", "메시지");
// → {"success":false, "error":"ERROR_CODE", "message":"메시지"}
```

#### 표준 에러 코드

```
NOT_FOUND          - 데이터 없음
UNAUTHORIZED       - 인증 필요
FORBIDDEN          - 권한 없음
INVALID_PARAMETER  - 파라미터 오류
VALIDATION_FAILED  - 유효성 검증 실패
DUPLICATE_ENTRY    - 중복 데이터
DATABASE_ERROR     - DB 오류
```

---

### 3.8 Page 메소드 호출 순서

```jsp
// ✅ 올바른 순서
p.setLayout("default");         // 1. 레이아웃 (선택)
p.setBody("main.content");      // 2. 본문 (필수)
p.setVar("title", "제목");       // 3. 변수 설정
p.setLoop("list", dataSet);     // 4. 반복 데이터
p.display();                    // 5. 출력 (필수)

// ❌ 잘못된 순서
p.setVar("title", "제목");       // 템플릿보다 먼저 설정 금지
p.setBody("main.content");
```

**이유**: 템플릿 파일을 먼저 지정해야 변수와 루프를 올바르게 바인딩할 수 있음

---

### 3.9 DataSet 사용 (next() 필수)

#### ❌ 잘못된 예

```jsp
DataSet info = user.get(1);
String name = info.s("name");  // 에러!
```

#### ✅ 올바른 예 (단일 레코드)

```jsp
DataSet info = user.get(1);
if(info.next()) {
    String name = info.s("name");
    String email = info.s("email");
} else {
    m.p("데이터를 찾을 수 없습니다.");
}
```

#### ✅ 올바른 예 (여러 레코드)

```jsp
DataSet list = user.find();

while(list.next()) {
    String name = list.s("name");
    m.p(name);
}
```

**이유**: DataSet은 내부적으로 커서를 가지며, 초기 커서 위치는 -1 (데이터 이전)

#### setLoop 사용 시 커서 초기화 불필요

`p.setLoop()`는 **자동으로 커서를 처음으로 이동**시킵니다. 따라서 `moveRow(0)` 호출이 불필요합니다.

```jsp
// ❌ 불필요한 코드
DataSet list = user.find();
while(list.next()) {
    // 데이터 가공
    list.put("formatted_date", m.time("yyyy-MM-dd", list.s("reg_date")));
}
list.moveRow(0);  // 불필요!
p.setLoop("list", list);

// ✅ 올바른 코드 (moveRow 호출 없음)
DataSet list = user.find();
while(list.next()) {
    // 데이터 가공
    list.put("formatted_date", m.time("yyyy-MM-dd", list.s("reg_date")));
}
p.setLoop("list", list);  // 자동으로 커서를 처음으로 이동
```

**참고**: `moveRow()` 메소드 자체가 존재하지 않으며, `setLoop()`가 내부적으로 커서를 초기화합니다

---

### 3.10 AJAX 응답 처리

#### ❌ 금지: jsReplace/redirect

```jsp
if(m.isPost()) {
    user.insert();
    m.jsReplace("list.jsp");  // AJAX에서 작동 안 함
}
```

#### ✅ 올바름 1: out.print()

```jsp
if(m.isPost()) {
    user.insert();
    out.print("success");
    return;
}
```

#### ✅ 올바름 2: Json 사용 (권장)

```jsp
Json j = new Json();

if(m.isPost()) {
    UserDao user = new UserDao();
    user.item("name", f.get("name"));

    if(user.insert()) {
        j.success("등록되었습니다.", user.id);
    } else {
        j.error("REGISTER_FAILED", user.getErrMsg());
    }
    return;
}
```

#### ✅ 올바름 3: RestAPI 클래스 (권장)

```jsp
Json j = new Json();
RestAPI api = new RestAPI(request, response);

api.post(() -> {
    UserDao user = new UserDao();
    user.item("name", f.get("name"));

    if(user.insert()) {
        j.success("등록되었습니다.", user.id);
    } else {
        j.error("REGISTER_FAILED", user.getErrMsg());
    }
});
```

---

### 3.11 파일 업로드 검증

파일 업로드 시 Form 클래스의 `addElement()`로 검증합니다:

```jsp
// ✅ 확장자 검증 (이미지만 허용)
f.addElement("photo", null, "allow:'jpg|jpeg|png|gif'");

// ✅ 확장자 검증 (문서만 허용)
f.addElement("document", null, "allow:'pdf|doc|docx|xls|xlsx'");

// ✅ 파일 필수
f.addElement("file", null, "required:'Y'");

// ✅ 검증 포함 POST 처리
if(m.isPost() && f.validate()) {
    File uploadedFile = f.saveFile("file");
    if(uploadedFile != null) {
        // 파일 저장 성공
        String fileName = f.getFileName("file");
        m.p("업로드 완료: " + fileName);
    }
}
```

**주의**: `enctype="multipart/form-data"` 필수
```html
<form method="post" enctype="multipart/form-data">
    <input type="file" name="file">
</form>
```

---

### 3.12 날짜/시간 처리 (크로스 DB 호환)

#### VARCHAR(14) + m.time() 사용

```sql
-- ✅ 올바름
CREATE TABLE tb_user (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    reg_date VARCHAR(14),   -- yyyyMMddHHmmss
    birth_date VARCHAR(8)   -- yyyyMMdd
);
```

```jsp
// ✅ 현재 시각
user.item("reg_date", m.time());  // 20250124153045

// ✅ 날짜 범위 검색 (문자열 비교)
user.addWhere("reg_date >= '20250101000000'");
user.addWhere("reg_date <= '20250131235959'");

// ✅ 출력 시 포맷 변환
String formatted = m.time("yyyy-MM-dd HH:mm:ss", info.s("reg_date"));
// → 2025-01-24 15:30:45

// ❌ 금지: DB 함수 사용 (벤더 종속)
user.item("reg_date", "NOW()", "function");  // MySQL 종속
```

**이유**: 데이터베이스 벤더(MySQL, Oracle, MSSQL, PostgreSQL) 간 이식성 확보

---

### 3.13 인증 처리

#### init.jsp에서 초기화

로그인 여부를 명확히 표현하기 위해 **boolean 변수 `isLogin`**을 사용합니다.

```jsp
int userId = 0;
String userName = "";
boolean isLogin = false;

Auth auth = new Auth(request, response);
if(auth.isValid()) {
    userId = auth.getInt("user_id");
    userName = auth.getString("user_name");
    isLogin = true;
}

p.setVar("userId", userId);
p.setVar("userName", userName);
p.setVar("isLogin", isLogin);
```

**템플릿에서 사용**:
```html
<!-- ❌ 나쁜 예: userId를 직접 조건으로 사용 -->
<!--@if(userId)-->
    <span>환영합니다</span>
<!--/if(userId)-->

<!-- ✅ 좋은 예: 명확한 boolean 변수 사용 -->
<!--@if(isLogin)-->
    <span>{{userName}}님 환영합니다</span>
<!--/if(isLogin)-->

<!--@nif(isLogin)-->
    <a href="/member/login.jsp">로그인</a>
<!--/nif(isLogin)-->
```

**장점**:
- 코드의 의도가 명확함 (`isLogin`이 `userId > 0`보다 직관적)
- 템플릿에서 가독성 향상
- 로그인 로직 변경 시 init.jsp만 수정하면 됨

#### 로그인 처리 예제

```jsp
<%@ include file="/init.jsp" %><%

f.addElement("id", null, "required:'Y'");
f.addElement("passwd", null, "required:'Y'");

if(m.isPost() && f.validate()) {
    String id = f.get("id");
    String passwd = f.get("passwd");

    // 사용자 확인
    UserDao user = new UserDao();
    DataSet info = user.find(
        "user_id = ? AND passwd = ?",
        new Object[]{id, Malgn.sha256(passwd)}
    );

    if(info.next()) {
        // 로그인 성공 - Auth에 정보 저장
        auth.put("user_id", info.i("id"));
        auth.put("user_name", info.s("name"));
        auth.put("user_level", info.i("level"));
        auth.save();

        m.jsAlert("로그인 성공");
        m.jsReplace("/main/index.jsp");
    } else {
        m.jsError("아이디 또는 비밀번호가 올바르지 않습니다.");
    }
    return;
}

p.setBody("main.login");
p.setVar("form_script", f.getScript());
p.display();

%>
```

#### 로그아웃 처리

```jsp
<%@ include file="/init.jsp" %><%

auth.delete();  // 인증 정보 삭제

m.jsAlert("로그아웃되었습니다.");
m.jsReplace("/main/login.jsp");

%>
```

#### 개별 페이지에서 확인

```jsp
<%@ include file="/init.jsp" %><%

// ✅ 로그인 체크 (boolean 변수 사용)
if(!isLogin) {
    m.jsError("로그인이 필요합니다.");
    m.jsReplace("/member/login.jsp");
    return;
}

// 관리자 체크 (userId 사용 - 권한 레벨 확인 시)
int userLevel = auth.getInt("user_level");
if(userLevel < 9) {
    m.jsError("관리자 권한이 필요합니다.");
    return;
}

// 정상 로직 처리
UserDao user = new UserDao();
DataSet list = user.find();

%>
```

**로그인 체크 규칙**:
- **로그인 여부 확인**: `if(!isLogin)` 사용 (boolean)
- **권한 레벨 확인**: `userId`, `userLevel` 등 사용 (int)
- **작성자 본인 확인**: `if(info.i("user_id") != userId)` 사용

---

## 4. 자주 사용하는 패턴

### 4.1 목록 조회 (페이징 있음)

```jsp
<%@ include file="/init.jsp" %><%

// 검색 폼 필드 설정 (검색값 자동 유지)
f.addElement("keyword", null, null);
f.addElement("status", null, null);

// ListManager를 사용한 페이징 목록
ListManager lm = new ListManager();
lm.setRequest(request);
lm.setListNum(20);  // 페이지당 20개
lm.setTable("tb_user");

// 검색 조건 (null이나 빈 값이면 자동으로 무시됨)
lm.addSearch("name,email", f.get("keyword"), "LIKE");
lm.addSearch("status", f.getInt("status"));

lm.setOrderBy("id DESC");

DataSet list = lm.getDataSet();
int total = lm.getTotalNum();
String pager = lm.getPaging();

p.setLayout("default");
p.setBody("main.user_list");
p.setLoop("list", list);
p.setVar("total", total);
p.setVar("pager", pager);
p.setVar("form_script", f.getScript());
p.display();

%>
```

**HTML 템플릿**:
```html
<h1>사용자 목록 (전체: {{total}}명)</h1>

<!-- 검색 폼 (검색값 자동 유지) -->
<form name="form1" method="get">
    <input type="text" name="keyword" placeholder="이름/이메일 검색">
    <select name="status">
        <option value="">전체</option>
        <option value="1">활성</option>
        <option value="0">비활성</option>
    </select>
    <button type="submit">검색</button>
</form>
{{form_script}}

<!-- 목록 -->
<table>
    <!--@loop(list)-->
    <tr>
        <td>{{list.id}}</td>
        <td>{{list.name}}</td>
        <td>{{list.email}}</td>
    </tr>
    <!--/loop(list)-->
</table>

<!-- 페이징 -->
{{pager}}
```

**페이징 없는 간단한 목록**:
```jsp
UserDao user = new UserDao();
user.addWhere("status = 1");
user.setOrderBy("id DESC");
DataSet list = user.find();

p.setLoop("list", list);
p.display();
```

**addSearch 메소드의 자동 null/공백 처리**:

`addSearch()` 메소드는 값이 `null`이거나 빈 문자열이면 **자동으로 무시**합니다. 따라서 별도의 조건문이 필요 없습니다.

```jsp
// ❌ 불필요한 코드 (조건문 필요 없음)
String keyword = f.get("keyword");
if(keyword != null && !keyword.isEmpty()) {
    lm.addSearch("title,content", keyword, "LIKE");
}

// ✅ 올바른 코드 (간결하고 명확)
lm.addSearch("title,content", f.get("keyword"), "LIKE");
lm.addSearch("status", f.getInt("status"));
lm.addSearch("level", f.getInt("level"));
```

**동작 방식**:
- 값이 `null` 또는 빈 문자열(`""`) → 해당 검색 조건 무시
- 값이 `0` (숫자) → 해당 검색 조건 무시
- 유효한 값만 WHERE 절에 추가됨

**장점**:
- 코드가 간결해짐
- 조건문 중복 제거
- 검색 조건 추가/제거가 용이

---

### 4.2 상세 조회

```jsp
<%@ include file="/init.jsp" %><%

int id = m.ri("id");

UserDao user = new UserDao();
DataSet info = user.get(id);  // find("id = ?", new Object[]{id})와 동일

if(!info.next()) {
    m.jsError("데이터를 찾을 수 없습니다.");
    return;
}

p.setLayout("default");
p.setBody("main.user_view");
p.setVar(info);  // DataSet의 모든 필드를 자동으로 변수화
p.display();

%>
```

**HTML 템플릿**:
```html
<h1>사용자 정보</h1>
<table>
    <tr>
        <th>ID</th>
        <td>{{id}}</td>
    </tr>
    <tr>
        <th>이름</th>
        <td>{{name}}</td>
    </tr>
    <tr>
        <th>이메일</th>
        <td>{{email}}</td>
    </tr>
    <tr>
        <th>등록일</th>
        <td>{{reg_date}}</td>
    </tr>
</table>
```

**p.setVar(DataSet) 장점**:
- DataSet의 모든 필드를 자동으로 템플릿 변수로 설정
- 필드별로 `p.setVar()` 반복 호출 불필요
- 코드가 간결하고 유지보수 용이

---

### 4.3 등록

```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 유효성 검증 규칙 설정
f.addElement("name", null, "required:'Y', minlength:2");
f.addElement("email", null, "required:'Y', type:'email'");
f.addElement("phone", null, "required:'Y'");

// POST 처리
if(m.isPost() && f.validate()) {
    UserDao user = new UserDao();

    user.item("name", f.get("name"));
    user.item("email", f.get("email"));
    user.item("phone", f.get("phone"));
    user.item("reg_date", m.time());
    user.item("status", 1);

    if(user.insert()) {
        m.jsAlert("등록되었습니다.");
        m.jsReplace("list.jsp");
    } else {
        m.jsError("등록 실패: " + user.getErrMsg());
    }
    return;  // 필수!
}

// GET 처리 (폼 표시)
p.setLayout("default");
p.setBody("main.user_form");
p.setVar("is_insert", true);
p.setVar("form_script", f.getScript());
p.display();

%>
```

---

### 4.4 수정

**중요**: 수정 페이지는 반드시 데이터를 먼저 조회합니다 (POST/GET 모두).

```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

int id = m.ri("id");

// 1. 먼저 조회 (POST/GET 모두)
UserDao user = new UserDao();
DataSet info = user.find("id = ?", new Object[]{id});

if(!info.next()) {
    m.jsError("데이터를 찾을 수 없습니다.");
    return;
}

// 2. 검증 규칙 설정 (기존 값 전달)
f.addElement("name", info.s("name"), "required:'Y', minlength:2");
f.addElement("email", info.s("email"), "required:'Y', type:'email'");
f.addElement("phone", info.s("phone"), "required:'Y'");

// 3. POST 처리
if(m.isPost() && f.validate()) {
    user.item("name", f.get("name"));
    user.item("email", f.get("email"));
    user.item("phone", f.get("phone"));
    user.item("mod_date", m.time());

    if(user.update("id = ?", new Object[]{id})) {
        m.jsAlert("수정되었습니다.");
        m.jsReplace("list.jsp");
    } else {
        m.jsError("수정 실패: " + user.getErrMsg());
    }
    return;
}

// 4. GET 처리 (폼 표시)
p.setLayout("default");
p.setBody("main.user_form");
p.setVar("is_modify", true);
p.setVar("form_script", f.getScript());  // 자동으로 값 설정됨
p.display();

%>
```

**주의사항**:
- POST 요청 시에도 URL의 id를 재확인하여 권한 없는 수정 방지
- `f.addElement()`에 기존 값을 전달하면 폼에 자동으로 표시됨
- `user.update("id = ?", new Object[]{id})` 조건절 필수

---

### 4.5 삭제

```jsp
<%@ include file="/init.jsp" %><%

if(m.isPost()) {
    int id = m.ri("id");

    UserDao user = new UserDao();

    if(user.delete("id = ?", new Object[]{id})) {
        m.jsAlert("삭제되었습니다.");
        m.jsReplace("list.jsp");
    } else {
        m.jsError("삭제 실패: " + user.getErrMsg());
    }
    return;
}

%>
```

---

### 4.6 REST API

```jsp
<%@ include file="/init.jsp" %><%

Json j = new Json();
RestAPI api = new RestAPI(request, response);

// GET: 목록 조회
api.get("/", () -> {
    UserDao user = new UserDao();
    DataSet list = user.find();
    j.put("users", list);
    j.success();
});

// POST: 등록
api.post("/", () -> {
    UserDao user = new UserDao();
    user.item("name", f.get("name"));

    if(user.insert()) {
        j.success("등록되었습니다.", user.id);
    } else {
        j.error("REGISTER_FAILED", user.getErrMsg());
    }
});

// PUT: 수정
api.put("/:id", () -> {
    int id = api.paramInt("id");
    UserDao user = new UserDao();
    user.item("name", f.get("name"));

    if(user.update("id = ?", new Object[]{id})) {
        j.success("수정되었습니다.");
    } else {
        j.error("UPDATE_FAILED", user.getErrMsg());
    }
});

// DELETE: 삭제
api.delete("/:id", () -> {
    int id = api.paramInt("id");
    UserDao user = new UserDao();

    if(user.delete("id = ?", new Object[]{id})) {
        j.success("삭제되었습니다.");
    } else {
        j.error("DELETE_FAILED", user.getErrMsg());
    }
});

%>
```

---

## 5. 보안 가이드

### 5.1 XSS 방지

#### 입력

```jsp
// GET: 자동 필터링
String keyword = m.rs("keyword");

// POST: 원본 유지
String content = f.get("content");
```

#### 출력

```html
<!-- ✅ 템플릿: 자동 escape -->
<div>{{user.name}}</div>
<p>{{content}}</p>
```

**주의**: JSP에서 HTML을 직접 출력하지 마세요 (안티패턴).
모든 출력은 템플릿을 통해 처리하면 자동으로 XSS 방어됩니다.

---

### 5.2 보안 체크리스트

코드 작성 시 반드시 확인:

- [ ] SQL Injection 방지: `query("WHERE id = ?", new Object[]{id})` 사용
- [ ] XSS 방지: GET 파라미터는 `m.rs()` 사용
- [ ] 출력 이스케이프: 템플릿 `{{변수}}` 자동 처리
- [ ] 파일 업로드 검증: `f.addElement("file", null, "allow:'jpg|png|gif'")` 사용
- [ ] 인증 체크: `if(userId == 0) return;`
- [ ] 표준 응답: `j.success()` / `j.error()`
- [ ] 유효성 검증: `f.validate()` 사용

---

## 6. 템플릿 문법

### 6.1 변수 치환

```html
{{변수명}}
{{user.name}}
{{list.email}}
```

### 6.2 조건문

```html
<!--@if(is_admin)-->
<button>관리자 기능</button>
<!--/if(is_admin)-->

<!--@nif(is_logged)-->
<a href="/login.jsp">로그인</a>
<!--/nif(is_logged)-->
```

### 6.3 반복문

```html
<!--@loop(list)-->
<tr>
    <td>{{list.id}}</td>
    <td>{{list.name}}</td>
</tr>
<!--/loop(list)-->
```

### 6.4 레이아웃

레이아웃 파일은 반드시 `layout_`로 시작하고 `<!--@include(BODY)-->`를 사용합니다.

```html
<!-- /html/layout/layout_main.html -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
    <header>
        <h1>사이트 로고</h1>
    </header>

    <main>
        <!--@include(BODY)-->
    </main>

    <footer>
        <p>&copy; 2025 Company</p>
    </footer>
</body>
</html>
```

**JSP에서 사용**:
```jsp
p.setLayout("main");  // layout_main.html 사용
p.setBody("main.index");
p.setVar("title", "페이지 제목");
p.display();
```

---

## 7. 자주 하는 실수

### ❌ 실수 1: DataSet에서 next() 호출 누락

```jsp
DataSet info = user.get(1);
String name = info.s("name");  // ❌ 에러!
```

```jsp
// ✅ 올바름
DataSet info = user.get(1);
if(info.next()) {
    String name = info.s("name");
}
```

---

### ❌ 실수 2: POST 처리 후 return 누락

```jsp
if(m.isPost()) {
    user.insert();
    m.jsAlert("완료");
    // return이 없음! ❌
}
p.display();  // POST 후에도 실행됨
```

```jsp
// ✅ 올바름
if(m.isPost()) {
    user.insert();
    m.jsAlert("완료");
    return;  // 필수!
}
p.display();
```

---

### ❌ 실수 3: Page 메소드 순서 오류

```jsp
p.setVar("title", "제목");  // ❌ 템플릿보다 먼저
p.setBody("main.content");
```

```jsp
// ✅ 올바름
p.setBody("main.content");  // 템플릿 먼저
p.setVar("title", "제목");
```

---

### ❌ 실수 4: AJAX에서 jsReplace 사용

```jsp
// AJAX 요청인데
if(m.isPost()) {
    dao.insert();
    m.jsReplace("list.jsp");  // ❌ 작동 안 함
}
```

```jsp
// ✅ 올바름
if(m.isPost()) {
    dao.insert();
    j.success("완료");  // JSON 응답
}
```

---

### ❌ 실수 5: 명명 규칙 위반

```jsp
UserDao userDao = new UserDao();  // ❌
DataSet ds = user.find();         // ❌
```

```jsp
// ✅ 올바름
UserDao user = new UserDao();
DataSet list = user.find();
```

---

### ❌ 실수 6: GET/POST 파라미터 혼용

```jsp
// ❌ GET을 f.get()으로 (XSS 위험)
String keyword = f.get("keyword");

// ❌ POST를 m.rs()로 (원본 손실)
if(m.isPost()) {
    String content = m.rs("content");  // HTML 손상
}
```

```jsp
// ✅ 올바름
String keyword = m.rs("keyword");  // GET

if(m.isPost()) {
    String content = f.get("content");  // POST
}
```

---

## 8. 디버깅

### 8.1 개발 중 화면 출력

```jsp
user.setDebug(out);  // SQL 쿼리를 화면에 출력
DataSet list = user.find();
// → 실행된 SQL, 파라미터, 실행 시간이 화면에 출력
```

### 8.2 운영 중 로그 기록

```jsp
user.setDebug();  // SQL 쿼리를 로그 파일에 기록
DataSet list = user.find();
// → /logs/error.log에 기록
```

### 8.3 변수 내용 확인

```jsp
m.p(dataSet);   // DataSet 출력
m.p(hashMap);   // HashMap 출력
m.p(arrayList); // ArrayList 출력
```

### 8.4 지원 클래스

- `DataObject` (모든 DAO)
- `ListManager`
- `ExcelX`
- `Http`
- `Xml`
- 기타 대부분의 유틸리티 클래스

---

## 9. 부록

### 9.1 위반 시 결과

규칙을 위반하면:
- **보안 취약점** (SQL Injection, XSS)
- **런타임 에러** (NullPointerException, ClassCastException)
- **예측 불가능한 동작** (데이터 손실, 잘못된 출력)
- **유지보수 악화** (코드 가독성 저하)

---

### 9.2 요약: 가장 중요한 규칙

1. **명명 규칙**: `UserDao user`, `DataSet info/list`
2. **Postback 패턴**: 등록/수정은 같은 JSP에서 `if(m.isPost())`로 처리 + `return` 필수
3. **JSP와 HTML 분리**: JSP는 로직만, HTML은 출력만
4. **보안**: PreparedStatement 사용, GET은 `m.rs()`, POST는 `f.get()`
5. **try-catch 금지**: boolean 리턴으로 성공/실패 판단
6. **로그인 체크**: `if(!isLogin)` 사용, 공통 변수는 init.jsp에서 설정

---

### 9.3 상세 매뉴얼 참조

이 가이드에 없는 상세한 내용이 필요하면 아래 문서를 참조하세요:

#### 📖 기본 가이드

| 문서 | 내용 | 파일 |
|------|------|------|
| 프레임워크 소개 | 프레임워크 개요 및 특징 | `docs/introduction.md` |
| 설치 및 환경설정 | 설치 방법, config.xml 설정 | `docs/installation.md` |
| 시작하기 | 첫 프로젝트 만들기, init.jsp | `docs/getting-started.md` |
| 코딩 원칙 | 철학, 설계 원칙, 안티패턴 | `docs/coding-principles.md` |

#### 🔧 핵심 기능

| 문서 | 내용 | 파일 |
|------|------|------|
| 맑은템플릿 | 템플릿 문법, 레이아웃, 변수 치환 | `docs/template.md` |
| 데이터베이스 연동 | DB 설정, CRUD, 트랜잭션 | `docs/database.md` |
| DataObject 클래스 | DAO 패턴, 쿼리 빌더 | `docs/dataobject.md` |
| 데이터 입력 및 유효성 체크 | Form 클래스, 검증 규칙 | `docs/form-validation.md` |
| 파일 업로드 및 다운로드 | FileManager, 파일 처리 | `docs/file-upload-download.md` |
| 목록 및 검색 | ListManager, 페이징 | `docs/list-search.md` |
| DataSet 활용 | DataSet 메소드, 데이터 처리 | `docs/dataset.md` |

#### 📊 데이터 처리

| 문서 | 내용 | 파일 |
|------|------|------|
| JSON 처리 | Json 클래스, 파싱/생성 | `docs/json.md` |
| XML 처리 | Xml 클래스, XPath | `docs/xml.md` |
| Excel 처리 | ExcelX, 읽기/쓰기 | `docs/excel.md` |

#### 🔒 보안 및 인증

| 문서 | 내용 | 파일 |
|------|------|------|
| 인증 처리 | Auth 클래스, 세션 관리 | `docs/authentication.md` |
| 암호화 | Cipher, 해시, 암호화/복호화 | `docs/encryption.md` |
| OAuth 소셜 로그인 | 구글, 네이버, 카카오 로그인 | `docs/oauth.md` |

#### 🌐 REST API 개발

| 문서 | 내용 | 파일 |
|------|------|------|
| REST API 개발 | RestAPI 클래스, HTTP 메소드 | `docs/restapi.md` |
| 고급 라우팅 | 동적 라우팅, 파라미터 | `docs/restapi-advanced.md` |
| JWT 인증 | JWT 토큰, 인증/인가 | `docs/restapi-jwt.md` |
| CORS 설정 | CORS 헤더, 크로스 도메인 | `docs/restapi-cors.md` |
| 응답 표준 | JSON 응답 형식, 에러 코드 | `docs/restapi-response.md` |

#### ⚙️ 고급 기능

| 문서 | 내용 | 파일 |
|------|------|------|
| HTTP 클라이언트 | Http 클래스, 외부 API 호출 | `docs/http-client.md` |
| 이메일 발송 | Mail 클래스, SMTP | `docs/email.md` |
| 달력 및 날짜 선택 | Calendar, 날짜 처리 | `docs/calendar.md` |
| 유틸리티 메소드 | Malgn 클래스 메소드 | `docs/utility-methods.md` |
| 다국어 지원 | I18n, 언어 파일 | `docs/i18n.md` |
| OpenAI 통합 | ChatGPT API 연동 | `docs/openai.md` |
| 파일 전송 및 압축 | 파일 압축, FTP | `docs/file-transfer.md` |
| 환경설정 및 캐시 | config.xml, 캐시 관리 | `docs/configuration.md` |

---

### 9.4 AI 사용 팁

#### 자주 사용하는 문서

| 하고 싶은 것 | 읽어야 할 문서 |
|-------------|---------------|
| 파일 업로드 구현 | `docs/file-upload-download.md` |
| REST API 만들기 | `docs/restapi.md` |
| JWT 인증 추가 | `docs/restapi-jwt.md` |
| 엑셀 다운로드 | `docs/excel.md` |
| 이메일 발송 | `docs/email.md` |
| 복잡한 검색 조건 | `docs/list-search.md` |
| 외부 API 호출 | `docs/http-client.md` |
| 소셜 로그인 | `docs/oauth.md` |

---

**이 가이드가 맑은프레임워크의 모든 핵심을 담고 있습니다. 반드시 준수하세요.**