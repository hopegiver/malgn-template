# 맑은프레임워크 웹사이트 템플릿

**맑은프레임워크**를 사용한 웹사이트 개발 템플릿 프로젝트입니다.

Bootstrap 5 기반의 반응형 디자인으로 회원 시스템, 게시판, 신청 폼 등 일반적인 웹사이트에 필요한 기본 기능을 제공합니다.

---

## ⚠️ AI 개발 시 필수 사항

**AI를 사용하여 이 프로젝트를 개발하는 경우, 반드시 다음 순서로 진행하세요:**

### 1. 맑은프레임워크 공식 문서 클론 (필수)

먼저 `docs/` 폴더에 맑은프레임워크 공식 문서를 클론하세요:

```bash
# 프로젝트 루트에서 실행
git clone https://github.com/malgnsoft/malgnsoft.github.io.git docs
```

**중요**: 이 문서에는 맑은프레임워크의 모든 API와 사용법이 상세히 설명되어 있습니다. AI가 올바른 코드를 작성하려면 반드시 이 문서를 참조해야 합니다.

### 2. AI에게 필수 문서 읽히기

AI 개발 시 다음 문서들을 순서대로 읽히세요:

1. **`GUIDE.md`** - 이 프로젝트의 AI 코딩 가이드 (필독)
2. **`docs/`** - 맑은프레임워크 공식 문서 (API 참조)
3. **`schema.sql`** - 데이터베이스 구조 참고 (프로젝트별로 변경 필요)

### 3. 코딩 규칙 준수

- `GUIDE.md`에 명시된 체크리스트를 준수하여 코드를 작성하세요
- 맑은프레임워크의 코딩 패턴과 규칙을 이해한 후 개발을 시작하세요

**중요**: 맑은프레임워크는 고유한 코딩 패턴과 규칙을 가지고 있어, 이를 이해하지 못하면 프레임워크와 맞지 않는 코드가 생성될 수 있습니다.

**참고**: `schema.sql`은 샘플/참고용이며, 실제 프로젝트마다 필요에 따라 변경하여 사용합니다.

---

## 프로젝트 개요

### 주요 기능

- **회원 시스템**: 회원가입, 로그인, 로그아웃 (SHA-256 암호화)
- **게시판**: CRUD, 검색, 페이징, 작성자 권한 확인
- **신청 폼**: 문의/신청 접수 기능 (AJAX 처리)
- **반응형 디자인**: Bootstrap 5 기반 모바일 지원

### 기술 스택

- **프레임워크**: 맑은프레임워크
- **UI**: Bootstrap 5
- **서버**: JSP/Servlet (Java)
- **데이터베이스**: MySQL (또는 호환 DB)
- **템플릿 엔진**: 맑은프레임워크 내장 템플릿 엔진

---

## 프로젝트 구조

```
malgn-template/
├── GUIDE.md                   # ⭐ AI 코딩 가이드 (필독)
├── schema.sql                 # 데이터베이스 스키마 (샘플/참고용)
├── build.xml                  # Ant 빌드 설정
├── docs/                      # 📚 맑은프레임워크 공식 문서 (클론 필요)
│
├── src/
│   └── dao/                   # DAO 클래스 (Java)
│       ├── UserDao.java
│       ├── BoardDao.java
│       └── ApplyDao.java
│
└── public_html/
    ├── init.jsp               # 공통 초기화 (인증, 객체 초기화)
    ├── index.jsp              # 루트 리다이렉트
    │
    ├── member/                # 회원 관련 JSP
    │   ├── login.jsp
    │   ├── logout.jsp
    │   └── register.jsp
    │
    ├── main/                  # 메인 기능 JSP
    │   ├── index.jsp
    │   └── apply.jsp
    │
    ├── board/                 # 게시판 JSP
    │   ├── board_list.jsp
    │   ├── board_view.jsp
    │   ├── board_write.jsp
    │   ├── board_modify.jsp
    │   └── board_delete.jsp
    │
    ├── html/                  # HTML 템플릿 (JSP와 분리)
    │   ├── layout/
    │   │   └── layout_main.html
    │   ├── main/
    │   ├── board/
    │   └── member/
    │
    ├── css/
    │   └── style.css          # 커스텀 스타일
    │
    ├── js/
    │   └── common.js          # 공통 JavaScript
    │
    └── WEB-INF/
        ├── config.xml         # 프레임워크 설정
        ├── lib/
        │   └── malgn.jar      # 맑은프레임워크 라이브러리
        └── classes/           # 컴파일된 DAO 클래스
```

---

## 맑은프레임워크 코딩 규칙 준수

이 프로젝트는 맑은프레임워크의 모든 코딩 규칙을 엄격히 준수합니다.

자세한 내용은 **`GUIDE.md`** 문서를 참조하세요.

### 주요 규칙 요약

- ✅ 명명 규칙: `UserDao user`, `DataSet info/list`
- ✅ JSP import 금지 (외부 라이브러리는 DAO에서)
- ✅ Postback 패턴: `if(m.isPost())` 후 `return` 필수
- ✅ JSP/HTML 완전 분리
- ✅ 예외 처리: try-catch 없음 (boolean 체크)
- ✅ GET 파라미터: `m.rs()` (XSS 자동 필터)
- ✅ POST 데이터: `f.get()` (원본 보존)
- ✅ SQL Injection 방지: PreparedStatement 패턴
- ✅ XSS 방지: 템플릿 자동 escape
- ✅ 날짜 처리: VARCHAR(14) + `m.time()`
- ✅ Null 체크 불필요 (프레임워크가 빈 문자열 반환)
- ✅ DataSet 활용: `info.put()` 직접 사용
- ✅ 불필요한 변수 선언 금지

---

## 보안

### 구현된 보안 기능

- **비밀번호 암호화**: SHA-256 해시 (Malgn.sha256)
- **SQL Injection 방지**: PreparedStatement 자동 사용
- **XSS 방지**: 템플릿 엔진의 자동 escape
- **인증 체크**: `if(!isLogin)` 패턴
- **권한 체크**: 작성자 본인 확인
- **CSRF 방지**: POST 방식만 허용 (삭제 등)

---

## 라이선스

맑은프레임워크의 라이선스를 따릅니다.

---

## 참고 문서

- **`GUIDE.md`** - AI 코딩 가이드 (필독)
- **`docs/`** - 맑은프레임워크 공식 문서 (클론 필요)
- **`schema.sql`** - 데이터베이스 스키마 샘플
