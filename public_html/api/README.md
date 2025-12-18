# API 문서

맑은프레임워크 기반 RESTful API 엔드포인트

## 라우팅 구조

이 API는 맑은프레임워크의 RestAPI 클래스를 사용하여 RESTful 라우팅을 구현합니다.

- **web.xml**: `/api/*` 요청을 `/api/index.jsp`로 라우팅
- **index.jsp**: 라우팅 그룹 등록 및 포워딩
- **각 API 파일**: Path parameter를 사용한 RESTful 엔드포인트 구현

### 라우팅 흐름

```
/api/apply → index.jsp → apply.jsp → api.post("/", ...)
/api/board/list → index.jsp → board.jsp → api.get("/list", ...)
/api/board/view/123 → index.jsp → board.jsp → api.get("/view/:id", ...)
```

---

## JWT 인증

이 API는 JWT(JSON Web Token) 기반 인증을 사용합니다.

### 인증 흐름

1. **로그인** → JWT 토큰 발급
2. **API 호출** → `Authorization: Bearer <token>` 헤더 전송
3. **서버 검증** → 토큰 유효성 확인 후 사용자 정보 추출

### 퍼블릭 API (인증 불필요)

- `POST /api/auth/login` - 로그인
- `POST /api/auth/register` - 회원가입
- `POST /api/apply` - 신청 폼
- `GET /api/board/list` - 게시판 목록
- `GET /api/board/view/:id` - 게시글 상세

### 인증 필요 API

- `POST /api/board/write` - 게시글 작성
- `PUT /api/board/update/:id` - 게시글 수정 (작성자만)
- `DELETE /api/board/delete/:id` - 게시글 삭제 (작성자만)

---

## 인증 API

### POST /api/auth/login

로그인하여 JWT 토큰을 발급받습니다.

**요청 파라미터:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| email | String | ✅ | 이메일 주소 |
| password | String | ✅ | 비밀번호 |

**성공 응답:**
```json
{
  "success": true,
  "message": "로그인되었습니다.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user_id": 1,
    "user_name": "홍길동",
    "user_level": 1
  }
}
```

**실패 응답:**
```json
{
  "success": false,
  "error": "INVALID_CREDENTIALS",
  "message": "이메일 또는 비밀번호가 일치하지 않습니다."
}
```

**예제:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -d "email=user@example.com" \
  -d "password=1234"
```

**JavaScript 예제:**
```javascript
fetch('/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
  },
  body: 'email=user@example.com&password=1234'
})
.then(response => response.json())
.then(data => {
  // 토큰을 로컬스토리지에 저장
  localStorage.setItem('token', data.data.token);
  console.log('로그인 성공:', data);
});
```

---

### POST /api/auth/register

회원가입을 처리합니다.

**요청 파라미터:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| email | String | ✅ | 이메일 주소 (중복 불가) |
| password | String | ✅ | 비밀번호 (4자 이상) |
| name | String | ✅ | 사용자 이름 |

**성공 응답:**
```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다.",
  "data": {
    "user_id": 123
  }
}
```

**실패 응답:**
```json
{
  "success": false,
  "error": "EMAIL_EXISTS",
  "message": "이미 사용중인 이메일입니다."
}
```

**예제:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -d "email=newuser@example.com" \
  -d "password=1234" \
  -d "name=홍길동"
```

---

## 인증이 필요한 API 호출

JWT 토큰을 `Authorization` 헤더에 포함하여 전송합니다.

**curl 예제:**
```bash
# 1. 로그인하여 토큰 받기
TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -d "email=user@example.com&password=1234" \
  | jq -r '.data.token')

# 2. 토큰을 사용하여 게시글 작성
curl -X POST http://localhost:8080/api/board/write \
  -H "Authorization: Bearer $TOKEN" \
  -d "title=제목" \
  -d "content=내용"
```

**JavaScript 예제:**
```javascript
// 로컬스토리지에서 토큰 가져오기
const token = localStorage.getItem('token');

// 인증이 필요한 API 호출
fetch('/api/board/write', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/x-www-form-urlencoded',
  },
  body: 'title=제목&content=내용'
})
.then(response => response.json())
.then(data => console.log(data));
```

---

## 신청 폼 API

### POST /api/apply

신청 정보를 등록합니다.

**요청 파라미터:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| name | String | ✅ | 신청자 이름 |
| email | String | ✅ | 이메일 (형식 검증) |
| phone | String | ✅ | 전화번호 |
| company | String | ❌ | 회사명 |
| position | String | ❌ | 직책 |
| content | String | ✅ | 신청 내용 |

**성공 응답:**
```json
{
  "success": true,
  "message": "신청이 완료되었습니다.",
  "data": {
    "apply_id": 123
  }
}
```

**실패 응답:**
```json
{
  "success": false,
  "error": "VALIDATION_FAILED",
  "message": "이름을 입력하세요."
}
```

**예제:**
```bash
curl -X POST http://localhost:8080/api/apply \
  -d "name=홍길동" \
  -d "email=hong@example.com" \
  -d "phone=010-1234-5678" \
  -d "content=문의합니다"
```

---

## 게시판 API

### GET /api/board/list

게시글 목록을 조회합니다.

**요청 파라미터:**

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| page | Integer | ❌ | 1 | 페이지 번호 |
| page_size | Integer | ❌ | 10 | 페이지당 항목 수 |
| keyword | String | ❌ | - | 검색어 (제목, 내용) |

**성공 응답:**
```json
{
  "success": true,
  "message": "목록 조회 성공",
  "data": {
    "pagination": {
      "total": 25,
      "page": 1,
      "page_size": 10,
      "total_pages": 3
    },
    "items": [
      {
        "id": 1,
        "title": "게시글 제목",
        "user_name": "홍길동",
        "hit": 42,
        "reg_date": "20250101120000",
        "reg_date_format": "2025-01-01 12:00"
      }
    ]
  }
}
```

**예제:**
```bash
# 기본 조회
curl http://localhost:8080/api/board/list

# 페이징 + 검색
curl "http://localhost:8080/api/board/list?page=2&page_size=20&keyword=안녕"
```

---

### GET /api/board/view/:id

게시글 상세 정보를 조회합니다. 조회 시 조회수가 자동으로 증가합니다.

**Path Parameter:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | Integer | ✅ | 게시글 ID (URL 경로에 포함) |

**성공 응답:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": {
    "board": {
      "id": 1,
      "title": "게시글 제목",
      "content": "게시글 내용",
      "user_id": 5,
      "user_name": "홍길동",
      "hit": 43,
      "reg_date": "20250101120000",
      "reg_date_format": "2025-01-01 12:00",
      "mod_date": "20250102130000",
      "mod_date_format": "2025-01-02 13:00",
      "is_author": false
    }
  }
}
```

**실패 응답:**
```json
{
  "success": false,
  "error": "NOT_FOUND",
  "message": "게시글을 찾을 수 없습니다."
}
```

**예제:**
```bash
curl http://localhost:8080/api/board/view/1
```

---

### POST /api/board/write

게시글을 작성합니다. (로그인 필요)

**요청 파라미터:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| title | String | ✅ | 게시글 제목 |
| content | String | ✅ | 게시글 내용 |

**성공 응답:**
```json
{
  "success": true,
  "message": "게시글이 등록되었습니다.",
  "data": {
    "board_id": 123
  }
}
```

**예제:**
```bash
curl -X POST http://localhost:8080/api/board/write \
  -d "title=제목" \
  -d "content=내용"
```

---

### PUT /api/board/update/:id

게시글을 수정합니다. (작성자 본인만 가능)

**Path Parameter:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | Integer | ✅ | 게시글 ID (URL 경로에 포함) |

**요청 파라미터:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| title | String | ✅ | 게시글 제목 |
| content | String | ✅ | 게시글 내용 |

**성공 응답:**
```json
{
  "success": true,
  "message": "게시글이 수정되었습니다."
}
```

**예제:**
```bash
curl -X PUT http://localhost:8080/api/board/update/1 \
  -d "title=수정된 제목" \
  -d "content=수정된 내용"
```

---

### DELETE /api/board/delete/:id

게시글을 삭제합니다. (작성자 본인만 가능)

**Path Parameter:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | Integer | ✅ | 게시글 ID (URL 경로에 포함) |

**성공 응답:**
```json
{
  "success": true,
  "message": "게시글이 삭제되었습니다."
}
```

**예제:**
```bash
curl -X DELETE http://localhost:8080/api/board/delete/1
```

---

## 공통 에러 코드

| 에러 코드 | 설명 |
|-----------|------|
| METHOD_NOT_ALLOWED | 허용되지 않은 HTTP 메소드 |
| INVALID_PARAMETER | 필수 파라미터 누락 또는 잘못된 값 |
| VALIDATION_FAILED | 입력값 유효성 검증 실패 |
| NOT_FOUND | 요청한 리소스를 찾을 수 없음 |
| INSERT_FAILED | 데이터 등록 실패 |
| UNAUTHORIZED | 인증 필요 |
| FORBIDDEN | 권한 없음 |

---

## 응답 형식

모든 API는 JSON 형식으로 응답합니다.

**성공:**
```json
{
  "success": true,
  "message": "성공 메시지",
  "data": { ... }
}
```

**실패:**
```json
{
  "success": false,
  "error": "ERROR_CODE",
  "message": "에러 메시지"
}
```

---

## 인증

일부 API는 로그인이 필요합니다 (세션 기반 인증):
- **게시글 작성** (`POST /api/board/write`)
- **게시글 수정** (`PUT /api/board/update/:id`)
- **게시글 삭제** (`DELETE /api/board/delete/:id`)

수정 및 삭제는 작성자 본인만 가능합니다.

---

## Path Parameter vs Query String

### Path Parameter (권장)
```
GET /api/board/view/123
PUT /api/board/update/123
DELETE /api/board/delete/123
```

### Query String (검색, 필터링)
```
GET /api/board/list?page=1&page_size=10&keyword=검색어
```

---

## CORS

프론트엔드에서 사용하려면 서버에 CORS 설정이 필요할 수 있습니다.

**web.xml 또는 필터 추가:**
```xml
<filter>
  <filter-name>CorsFilter</filter-name>
  <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>
</filter>
```
