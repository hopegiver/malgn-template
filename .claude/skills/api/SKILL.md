---
description: REST API 엔드포인트 생성
user_invocable: true
---

# REST API 엔드포인트 생성

테이블명: $ARGUMENTS

## 작업 절차

1. `schema.sql`에서 해당 테이블의 컬럼 구조를 확인한다.
2. MCP `get_context("api", "$ARGUMENTS")`로 규칙+패턴+클래스를 일괄 조회한다.
3. `public_html/api/init.jsp`를 읽어 API 초기화 구조를 확인한다.
4. `public_html/api/index.jsp`를 읽어 라우터 구조를 확인한다.
5. MCP `get_pattern("jsp-restapi")`로 REST API 패턴을 조회한다.
6. 기존 `public_html/api/` 폴더의 API 파일을 참고하여 동일한 스타일로 작성한다.

## 생성할 파일

테이블명에서 `tb_` 접두사를 제거하여 파일명으로 사용한다. (예: tb_notice → notice)

- `public_html/api/{name}.jsp` — CRUD REST API

## RestAPI 클래스 핵심 패턴

### 라우팅 (Express.js 스타일)
```jsp
<%@ include file="/api/init.jsp" %><%

// GET /api/user - 목록
api.get("/", () -> {
    UserDao user = new UserDao();
    DataSet list = user.find();
    j.success("조회되었습니다.", list);
});

// GET /api/user/:id - 단일 조회 (path parameter)
api.get("/:id", () -> {
    int id = api.paramInt("id");
    UserDao user = new UserDao();
    DataSet info = user.get(id);
    if(info.next()) {
        j.success(info);
    } else {
        j.error("NOT_FOUND", "찾을 수 없습니다.");
    }
});

// POST /api/user - 생성
api.post("/", () -> { ... });

// PUT /api/user/:id - 전체 수정
api.put("/:id", () -> { ... });

// PATCH /api/user/:id - 부분 수정
api.patch("/:id", () -> { ... });

// DELETE /api/user/:id - 삭제
api.delete("/:id", () -> { ... });

%>
```

### Path Parameter
- `api.param("name")` — 문자열 반환
- `api.paramInt("name")` — 정수 반환 (실패 시 0)
- 고정 경로가 path parameter보다 우선 매칭 (`/list` > `/:id`)
- 중첩 리소스: `api.get("/:id/comments", () -> { ... })`

### 인증 (JWT)
- `api.auth()` — JWT 토큰 검증 (init.jsp에서 호출, false면 return)
- `api.generateToken(60)` — JWT 토큰 생성 (분 단위)
- `api.setData("key", value)` — 토큰에 저장할 데이터 설정
- `api.getDataInt("user_id")` / `api.getData("user_name")` — 토큰에서 데이터 조회
- `api.publicRoute("/api/auth/login", "/api/public/*")` — 인증 불필요 경로

### CORS
- `api.cors()` — 모든 도메인 허용
- `api.cors(new String[]{...})` — 화이트리스트
- `api.handlePreflight()` — OPTIONS preflight 처리

### 응답
- `j.success()` / `j.success("메시지")` / `j.success("메시지", data)`
- `j.error("ERROR_CODE", "메시지")` / `j.error("ERROR_CODE", "메시지", details)`
- `j.put("key", value)` + `j.print()` — 커스텀 응답
- `j.put()` 후 `j.success()` 호출 시 put 데이터가 data에 자동 포함
- `api.error(401, "메시지")` — HTTP 상태 코드 + 에러

### 에러 코드
- `NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`, `VALIDATION_ERROR`
- `CONFLICT`, `DATABASE_ERROR`, `SERVER_ERROR`, `INVALID_CREDENTIALS`

## 필수 구현 사항

- `j.success()` / `j.error("ERROR_CODE", "메시지")` 응답
- 관리자 API: `userLevel` 체크
- 수정/삭제 시 작성자 본인 확인
- `f.get()`으로 POST 데이터 처리
- 바인딩 파라미터 사용 (SQL Injection 방지)
- 날짜 처리: `m.time()` 사용 (DB 함수 금지)

## 완료 후

1. `public_html/api/index.jsp`에 `router.use("/api/{name}", "/api/{name}.jsp")` 추가한다.
2. 생성된 코드를 MCP `validate_code(code, "jsp")`로 검증한다.
3. 위반 사항이 있으면 수정한다.
4. 필요한 DAO가 없으면 생성하고 `ant compile`로 컴파일한다.
