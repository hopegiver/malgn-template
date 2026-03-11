---
description: CRUD 파일 생성
user_invocable: true
---

# CRUD 파일 생성

테이블명: $ARGUMENTS

## 작업 절차

1. `schema.sql`에서 해당 테이블의 컬럼 구조를 확인한다.
2. MCP `get_context("crud", "$ARGUMENTS")`로 규칙+패턴+클래스를 일괄 조회한다.
3. MCP `get_pattern("dao-custom")`으로 DAO 패턴을 조회한다.
4. MCP로 JSP 패턴을 조회한다:
   - `get_pattern("jsp-list")` — 목록
   - `get_pattern("jsp-insert")` — 등록
   - `get_pattern("jsp-modify")` — 수정
   - `get_pattern("jsp-delete")` — 삭제
   - `get_pattern("jsp-view")` — 상세
5. MCP로 HTML 패턴을 조회한다:
   - `get_pattern("html-list")` — 목록 테이블
   - `get_pattern("html-form")` — 등록/수정 폼
   - `get_pattern("html-view")` — 상세 화면

## 생성할 파일

테이블명에서 `tb_` 접두사를 제거하여 폴더명/파일명으로 사용한다. (예: tb_notice → notice)

### DAO (테이블 구조 기반)
- `src/dao/{ClassName}Dao.java` — DataObject 상속, `this.table` 설정

### JSP (로직만, HTML 없음)
- `public_html/{name}/{name}_list.jsp` — 목록 (페이징+검색)
- `public_html/{name}/{name}_write.jsp` — 등록 (Postback)
- `public_html/{name}/{name}_modify.jsp` — 수정 (Postback, 조회 먼저)
- `public_html/{name}/{name}_delete.jsp` — 삭제 (POST only)
- `public_html/{name}/{name}_view.jsp` — 상세 조회

### HTML 템플릿 (테이블 컬럼 기반으로 필드 구성)
- `public_html/html/{name}/{name}_list.html` — 목록 테이블
- `public_html/html/{name}/{name}_write.html` — 등록 폼
- `public_html/html/{name}/{name}_modify.html` — 수정 폼
- `public_html/html/{name}/{name}_view.html` — 상세 화면

## CRUD 고유 규칙
- 수정 페이지: 데이터 조회를 POST/GET 모두 먼저 수행, `addElement` 두 번째 파라미터에 기존값 설정
- `p.display()` 앞에 빈 줄 금지
- 폼 이름: `form1` 고정, `{{form_script}}`로 클라이언트 검증 출력
- 유효성 속성: `required:'Y'`, `type:'email|number|phone'`, `minlength`, `maxlength`, `min`, `max`, `pattern`, `match:'필드명'`, `allowhtml:'Y'`
- 데이터 가져오기: `f.get()`, `f.getInt()`, `f.getLong()`, `f.getDouble()`, `f.getBoolean()`, `f.getArray()`

## 완료 후

1. 생성된 모든 JSP 코드를 MCP `validate_code(code, "jsp")`로 검증한다.
2. 생성된 모든 HTML을 MCP `validate_code(code, "html")`로 검증한다.
3. DAO를 MCP `validate_code(code, "dao")`로 검증한다.
4. 위반 사항이 있으면 수정한다.
5. `ant compile`로 DAO를 컴파일한다.
6. 생성된 파일 목록을 사용자에게 보여준다.
