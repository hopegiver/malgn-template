# 맑은프레임워크 웹사이트 템플릿

Bootstrap 5를 사용한 맑은프레임워크 기반 웹사이트 템플릿입니다.

## 주요 기능

- **소개 페이지**: 프레임워크 소개 및 주요 기능 안내
- **회원 시스템**: 회원가입, 로그인, 로그아웃
- **신청 폼**: 문의/신청 접수 기능
- **게시판**: 글 작성, 수정, 삭제, 조회, 검색 기능
- **반응형 디자인**: Bootstrap 5 기반 모바일 지원

## 프로젝트 구조

```
프로젝트/
├── schema.sql              # 데이터베이스 스키마
├── src/
│   └── dao/               # DAO 클래스
│       ├── UserDao.java          # 회원 DAO
│       ├── BoardDao.java         # 게시판 DAO
│       └── ApplyDao.java         # 신청 DAO
│
└── public_html/
    ├── init.jsp           # 공통 초기화
    ├── index.jsp          # 루트 리다이렉트 (→ /main/index.jsp)
    ├── member/            # 회원 관련 JSP
    │   ├── login.jsp
    │   ├── logout.jsp
    │   └── register.jsp
    ├── main/              # 주요 기능 JSP
    │   ├── index.jsp      # 실제 메인 페이지
    │   └── apply.jsp
    ├── board/             # 게시판 JSP
    │   ├── board_list.jsp
    │   ├── board_view.jsp
    │   ├── board_form.jsp
    │   └── board_delete.jsp
    ├── html/              # HTML 템플릿
    │   ├── layout/
    │   │   ├── layout_main.html   # 메인 레이아웃
    │   │   └── layout_auth.html   # 인증 레이아웃
    │   ├── main/          # 메인 HTML
    │   ├── board/         # 게시판 HTML
    │   └── member/        # 회원 HTML
    ├── css/
    │   └── style.css      # 커스텀 스타일
    ├── js/
    │   └── common.js      # 공통 JavaScript
    └── WEB-INF/
        └── config.xml     # 프레임워크 설정
```

## 설치 방법

### 1. 데이터베이스 설정

```sql
-- schema.sql 파일을 실행하여 테이블 생성
mysql -u [username] -p [database] < schema.sql
```

### 2. DAO 클래스 컴파일

```bash
# Ant를 사용하는 경우
ant compile

# 또는 수동 컴파일
javac -cp public_html/WEB-INF/lib/malgn.jar \
      -d public_html/WEB-INF/classes \
      src/dao/*.java
```

### 3. 데이터베이스 연결 설정

`public_html/WEB-INF/config.xml` 파일에서 JNDI 설정을 확인하세요.

```xml
<jndi>jdbc/malgn</jndi>
```

### 4. 서버 실행

톰캣 또는 다른 서블릿 컨테이너에 배포 후 실행합니다.

## 데이터베이스 테이블

### tb_user (회원)
- id: 회원 ID (PK)
- email: 이메일 (유니크)
- passwd: 비밀번호 (SHA-256 해시)
- name: 이름
- phone: 전화번호
- reg_date: 가입일 (VARCHAR 14)
- status: 상태 (1: 활성)

### tb_board (게시판)
- id: 게시글 ID (PK)
- user_id: 작성자 ID (FK)
- title: 제목
- content: 내용
- hit: 조회수
- reg_date: 작성일 (VARCHAR 14)
- status: 상태 (1: 활성)

### tb_apply (신청)
- id: 신청 ID (PK)
- name: 신청자 이름
- email: 이메일
- phone: 전화번호
- company: 회사명
- position: 직책
- content: 신청 내용
- status: 처리 상태 (pending, approved, rejected)
- reg_date: 신청일 (VARCHAR 14)

## 페이지 목록

### 공개 페이지
- `/` - 루트 (→ /main/index.jsp 리다이렉트)
- `/main/index.jsp` - 메인 소개 페이지
- `/member/login.jsp` - 로그인
- `/member/register.jsp` - 회원가입
- `/main/apply.jsp` - 신청 폼
- `/board/board_list.jsp` - 게시판 목록
- `/board/board_view.jsp?id=n` - 게시글 상세보기

### 인증 필요 페이지
- `/member/logout.jsp` - 로그아웃
- `/board/board_form.jsp` - 게시글 작성
- `/board/board_form.jsp?id=n` - 게시글 수정
- `/board/board_delete.jsp` - 게시글 삭제

## 맑은프레임워크 규칙 준수

이 프로젝트는 맑은프레임워크의 모든 코딩 규칙을 준수합니다:

- ✅ 명명 규칙: `UserDao user`, `DataSet list`
- ✅ Postback 패턴: `if(m.isPost())` 후 `return` 필수
- ✅ JSP/HTML 완전 분리
- ✅ try-catch 없음 (boolean 체크)
- ✅ GET은 `m.rs()`, POST는 `f.get()`
- ✅ SQL Injection 방지: PreparedStatement 사용
- ✅ XSS 방지: 템플릿 자동 escape
- ✅ 날짜 처리: VARCHAR(14) + `m.time()`
- ✅ 유효성 검증: `f.validate()` 사용
- ✅ 루트 리다이렉트: `/index.jsp` → `/main/index.jsp`

## 커스터마이징

### 디자인 변경
- `/css/style.css` 파일을 수정하여 스타일 변경
- Bootstrap 5 변수를 오버라이드하여 테마 커스터마이징

### 기능 추가
1. DAO 클래스 작성 (`src/dao/`)
2. JSP 파일 작성 (`public_html/`)
3. HTML 템플릿 작성 (`public_html/html/`)
4. 필요시 `schema.sql`에 테이블 추가

## 보안 고려사항

- 비밀번호는 SHA-256으로 해시 처리
- SQL Injection 자동 방지 (PreparedStatement)
- XSS 자동 방지 (템플릿 escape)
- 로그인 여부 체크 (userId 확인)
- 작성자 본인 확인 (게시글 수정/삭제)

## 라이선스

맑은프레임워크의 라이선스를 따릅니다.

## 참고 문서

자세한 내용은 `GUIDE.md` 및 `docs/` 디렉토리의 문서를 참조하세요.
