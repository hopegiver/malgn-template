---
description: 새 페이지 생성
user_invocable: true
---

# 새 페이지 생성

$ARGUMENTS 형식: {폴더명}/{파일명} (예: main/notice, board/faq)

## 절차

1. 사용자에게 페이지 유형을 확인한다:
   - 목록 페이지 (ListManager 사용)
   - 폼 페이지 (Postback 패턴)
   - 단순 페이지 (조회/표시만)
2. MCP `get_context("page")`로 규칙+패턴을 일괄 조회한다.
3. 해당 유형의 MCP `get_pattern(type)`을 조회한다:
   - 목록: `get_pattern("jsp-list")`, `get_pattern("html-list")`
   - 폼: `get_pattern("jsp-insert")`, `get_pattern("html-form")`
   - 단순: `get_pattern("jsp-view")`, `get_pattern("html-view")`
4. 두 파일을 생성한다:
   - `public_html/{폴더명}/{파일명}.jsp` — JSP (로직)
   - `public_html/html/{폴더명}/{파일명}.html` — HTML (템플릿)
5. 생성된 JSP를 MCP `validate_code(code, "jsp")`로 검증한다.
6. 생성된 HTML을 MCP `validate_code(code, "html")`로 검증한다.
7. 위반 사항이 있으면 수정한다.

## 페이지 고유 규칙
- `p.display()` 앞에 빈 줄 금지

## 템플릿 문법 (HTML에서 사용)
- 변수: `{{변수명}}`, DataSet: `{{루프명.컬럼명}}`
- 루프: `<!--@loop(list)-->...<!--/loop(list)-->`
- 조건: `<!--@if(var)-->...<!--/if(var)-->`, `<!--@nif(var)-->...<!--/nif(var)-->`
- 포함: `<!--@include(/layout/header.html)-->` (템플릿 루트 기준)
- JSP 실행: `<!--@execute(/main/component.jsp)-->`
- 레이아웃 본문: `<!--@include(BODY)-->` (layout 파일 내에서)
- 레이아웃 파일: `/html/layout/layout_{이름}.html` → `p.setLayout("{이름}")`
