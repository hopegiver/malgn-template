---
description: 코드 리뷰
user_invocable: true
---

# 코드 리뷰

$ARGUMENTS 가 있으면 해당 경로를, 없으면 현재 git 변경 파일 전체를 리뷰한다.

## 절차

1. 대상 파일 목록 수집:
   - 인자가 있으면 해당 파일/폴더
   - 없으면 `git diff --name-only HEAD`로 변경된 파일 목록
2. 각 파일을 읽고 확장자별로 분류한다 (jsp, html, java).
3. MCP `get_rules("checklist")`로 체크리스트를 조회한다.
4. 모든 JSP/HTML/Java 파일을 MCP `validate_code(code, file_type)`로 검증한다. (병렬 실행)
5. 체크리스트 항목별로 코드를 검토하고 위반 여부를 판단한다.

## 리뷰 항목

- 맑은프레임워크 규칙 위반 (MCP validate_code 결과)
- 명명 규칙 (DAO 변수명: `tb_` 제거 후 소문자, DataSet: 단일=`info` 복수=`list`)
- 보안 (SQL 바인딩 `?` 파라미터, XSS 방지, 인증 체크)
- GET/POST 파라미터 구분 (GET: `m.rs()`/`m.ri()`, POST: `f.get()` — 혼용 금지)
- Postback 패턴 준수 (수정 페이지: 데이터 조회 먼저 → addElement에 기존값 설정)
- POST 처리 후 return 필수 (`if(m.isPost())` 블록)
- AJAX 요청에서 `m.jsReplace()`/`m.redirect()` 사용 금지 → `j.success()`/`j.error()` 사용
- 불필요한 코드 (null 체크, try-catch, `<%= %>` 표현식)
- Page 메소드 호출 순서 (setLayout → setBody → setVar → setLoop → display)
- JSP/HTML 분리 (JSP에 HTML 혼재 여부)
- DataSet 사용 전 `next()` 호출 여부
- 불필요한 ListManager 사용 (페이징 불필요 시 DataObject 직접 사용)
- 날짜/시간 처리 (DB 함수 금지, `m.time()` 사용, VARCHAR(14) 타입)
- 반복문에서 `dao.clear()` 호출 여부
- `p.display()` 앞 빈 줄, `%>` 뒤 공백/빈 줄
- 외부 라이브러리 직접 사용 금지 (DAO로 캡슐화)

## 위반 발견 시

위반의 ruleId로 MCP `get_rules(rule_id)`를 조회하여 올바른 사용법을 확인하고 수정 방안을 제시한다.

## 출력 형식

파일별로 결과를 정리한다:
- 통과: 파일명 + "OK"
- 위반: 파일명 + 위반 내용 + 수정 제안

마지막에 전체 요약 (통과/위반 파일 수, 주요 위반 사항)을 출력한다.
