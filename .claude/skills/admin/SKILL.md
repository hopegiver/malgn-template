---
description: 관리자 페이지 생성
user_invocable: true
---

# 관리자 페이지 생성

$ARGUMENTS: 테이블명 또는 기능 설명 (예: tb_user 회원관리, tb_board 게시판관리)

## 절차

1. `schema.sql`에서 대상 테이블의 컬럼 구조를 확인한다.
2. MCP `get_context("crud", "$ARGUMENTS")`로 규칙+패턴+클래스를 일괄 조회한다.
3. MCP `get_pattern("jsp-list")`, `get_pattern("jsp-modify")`, `get_pattern("jsp-delete")`로 패턴을 조회한다.
4. MCP `get_pattern("html-list")`, `get_pattern("html-form")`, `get_pattern("html-view")`로 HTML 패턴을 조회한다.

## 관리자 전용 규칙

### 권한 체크 (모든 관리자 JSP 상단 필수)
```jsp
// init.jsp include 직후
if(!isLogin || auth.getInt("user_level") < 9) {
    m.jsError("관리자만 접근할 수 있습니다.");
    return;
}
```

### API에서 관리자 체크
```jsp
if(userLevel < 9) {
    api.error(403, "관리자 권한이 필요합니다.");
    return;
}
```

## 생성할 파일

테이블명에서 `tb_` 접두사를 제거하여 파일명으로 사용한다. 관리자 폴더는 `admin/`을 사용한다.

### JSP (로직만, HTML 없음)
- `public_html/admin/{name}_list.jsp` — 관리 목록 (페이징+검색+필터)
- `public_html/admin/{name}_view.jsp` — 상세 조회
- `public_html/admin/{name}_modify.jsp` — 수정 (Postback)
- `public_html/admin/{name}_delete.jsp` — 삭제 (POST only)

### HTML 템플릿
- `public_html/html/admin/{name}_list.html` — 관리 목록 (상태 필터, 일괄 처리 포함)
- `public_html/html/admin/{name}_view.html` — 상세 화면 (상태 변경 버튼 포함)
- `public_html/html/admin/{name}_modify.html` — 수정 폼

## 관리자 목록 추가 기능

- 상태 필터: `lm.addSearch("status", m.rs("status"), "=")` (드롭다운 선택)
- 날짜 범위 검색: `addSearch`로 처리 (빈 값 자동 무시, 바인딩 안전)
  ```jsp
  lm.addSearch("reg_date", m.rs("sdate"), ">=");
  lm.addSearch("reg_date", m.rs("edate") + "235959", "<=");
  ```
- 전체 건수 표시: `lm.getTotalNum()`
- 레이아웃: 관리자 전용 레이아웃 사용 `p.setLayout("admin")` (없으면 `p.setLayout("main")` 사용)

## 완료 후

1. 생성된 모든 JSP를 MCP `validate_code(code, "jsp")`로 검증한다.
2. 생성된 HTML을 MCP `validate_code(code, "html")`로 검증한다.
3. 위반 사항이 있으면 수정한다.
4. 필요한 DAO가 없으면 생성하고 `ant compile`로 컴파일한다.
5. 생성된 파일 목록을 사용자에게 보여준다.
