# 맑은프레임워크 핵심 규칙

이 프로젝트는 맑은프레임워크(JSP) 기반이다. MCP 도구 활용법은 CLAUDE.md "작업 워크플로우" 참조.

## init.jsp 자동 초기화 변수

| 변수 | 클래스 | 역할 |
|------|--------|------|
| `m` | `Malgn` | 요청 파라미터, 리다이렉트, 시간, 암호화 |
| `f` | `Form` | POST 파라미터, 유효성 검증, 파일 업로드 |
| `p` | `Page` | 레이아웃/HTML 템플릿 렌더링 |
| `j` | `Json` | JSON 응답 (AJAX/API) |
| `auth` | `Auth` | 세션 인증 (쿠키 기반) |
| `isLogin` | `boolean` | 로그인 여부 |
| `userId` | `int` | 사용자 ID |
| `userName` | `String` | 사용자 이름 |

api/init.jsp 추가: `api` (`RestAPI`), `userLevel` (`int`)

## 절대 규칙
- JSP 시작: `<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%`
- JSP에 `<%@ page import %>` 금지, HTML 직접 작성 금지, `<%= %>` 금지, try-catch 금지
- JSP는 로직만, HTML은 `/html/` 폴더 템플릿으로 완전 분리
- DAO 변수명: `tb_` 제거 후 소문자 (`UserDao user`), DataSet: 단일=`info`, 복수=`list`
- GET: `m.rs()`/`m.ri()`, POST: `f.get()`/`f.getInt()` — `request.getParameter()` 금지
- null 체크 불필요 (프레임워크가 빈 문자열 반환)
- SQL 바인딩 필수: `find("id = ?", new Object[]{id})`
- POST 처리 후 `return` 필수
- Page 순서: setLayout → setBody → setVar → setLoop → display (`p.display()` 앞 빈줄 금지)

## Postback 패턴 (등록/수정)
- addElement로 유효성 규칙 설정 → `if(m.isPost() && f.validate())` → 처리 → return → 폼 표시 (else 없이)
- 수정: 데이터 조회를 POST/GET 위에서 먼저 → addElement 두 번째 파라미터에 기존값
- 삭제: POST only, GET 시 에러 반환
- 상세 코드는 MCP `get_pattern("jsp-insert")`, `get_pattern("jsp-modify")` 참조

## 메시지/리다이렉트
- 일반 폼 성공 (메시지O): `m.jsAlert()` + `m.jsReplace()` 쌍으로 사용 (단독 금지)
- 일반 폼 성공 (메시지X): `m.redirect()`
- AJAX/JS 폼: `j.success()` / `j.error("CODE", "msg")` — `m.jsAlert`/`m.jsReplace`/`m.redirect` 금지
- 에러: `m.jsError()`, DB에러: `m.jsError(dao.getErrMsg())`
- 관리자 체크: `if(!isLogin || auth.getInt("user_level") < 9)` → `m.jsError()`

## ListManager (목록 페이징)
- `setRequest` → `setListNum` → `setTable` → `setFields` → `addWhere` → `addSearch` → `setOrderBy` → `getDataSet`
- `addWhere("AND status = 1")` — AND로 시작, `addSearch(필드, 키워드, "like")` — 빈값 자동 무시
- `getTotalNum()`, `getPaging()` — getDataSet 호출 후 사용
- 페이징 불필요 시 `DataObject.find()` 직접 사용
- 상세 코드는 MCP `get_pattern("jsp-list")` 참조

## HTML 템플릿 문법
- 변수: `{{변수명}}`, DataSet: `{{루프명.컬럼명}}`
- 루프: `<!--@loop(list)-->...<!--/loop(list)-->` (JSP: `p.setLoop`)
- 조건: `<!--@if(var)-->...<!--/if(var)-->`, `<!--@nif(var)-->...<!--/nif(var)-->`
- 포함: `<!--@include(파일)-->`, JSP실행: `<!--@execute(파일)-->`, 본문: `<!--@include(BODY)-->`
- 비교연산자 불가 → JSP에서 boolean 변수로 변환
- 레이아웃: `/html/layout/layout_{이름}.html` → `p.setLayout("{이름}")`
