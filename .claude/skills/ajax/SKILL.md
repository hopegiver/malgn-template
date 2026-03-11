---
description: AJAX 엔드포인트 생성
user_invocable: true
---

# AJAX 엔드포인트 생성

$ARGUMENTS 형식: {폴더명}/{파일명} 또는 테이블명 (예: board/like_toggle, tb_board)

## 절차

1. MCP `get_context("ajax")`로 AJAX 관련 규칙+패턴을 조회한다.
2. MCP `get_class("Json")`으로 Json 클래스 메소드를 확인한다.
3. 엔드포인트 JSP를 생성한다.

## AJAX 응답 패턴

```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

Json j = new Json();

if(m.isPost()) {
    // 처리 로직
    if(성공) {
        j.success("메시지", data);
    } else {
        j.error("ERROR_CODE", "메시지");
    }
    return;
}

j.error("INVALID_REQUEST", "잘못된 요청입니다.");

%>
```

## Json 클래스 주요 메소드

### 응답
- `j.success()` — `{"success":true,"message":"success"}`
- `j.success("메시지")` — 메시지 포함
- `j.success("메시지", dataSet)` — DataSet 자동 변환 (단일=Map, 복수=Array)
- `j.success("메시지", dataMap)` — Map 데이터 포함
- `j.error("ERROR_CODE", "메시지")` — 에러 응답
- `j.error("ERROR_CODE", "메시지", details)` — 상세 정보 포함

### 파싱
- `j.setJson(jsonString)` — JSON 문자열 파싱
- `j.getString("//path/key")` — 경로로 값 접근 (`//`로 시작)
- `j.getInt("//path/key")` — 정수 값
- `j.getDataSet("//path")` — JSON 배열 → DataSet 변환

### 정적 메소드
- `Json.encode(map)` — Map/List → JSON 문자열
- `Json.decode(jsonString)` — JSON 문자열 → DataSet

## AJAX 고유 규칙

- AJAX에서 `m.jsReplace()`, `m.jsAlert()`, `m.redirect()` 사용 금지
- `j.success()` / `j.error()` 로 JSON 응답
- DataSet 전달 시 단일 레코드는 `next()` 호출 후 전달
- 표준 에러 코드: NOT_FOUND, UNAUTHORIZED, FORBIDDEN, INVALID_PARAMETER, VALIDATION_FAILED, DUPLICATE_ENTRY, DATABASE_ERROR

## HTML에서 AJAX 호출

```html
<form method="post" action="endpoint.jsp" data-ajax="true" data-success="handleSuccess">
```

## 완료 후

MCP `validate_code(code, "jsp")`로 검증한다.
