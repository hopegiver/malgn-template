# 맑은프레임워크 핵심 규칙

이 프로젝트는 맑은프레임워크(JSP) 기반이다. MCP 도구 활용법은 CLAUDE.md "작업 워크플로우" 참조.

## 절대 규칙
- JSP 시작: `<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%`
- JSP에 `<%@ page import %>` 금지, HTML 직접 작성 금지, `<%= %>` 금지, try-catch 금지
- JSP는 로직만, HTML은 `/html/` 폴더 템플릿으로 완전 분리
- Page 순서: setLayout → setBody → setVar → setLoop → display
- DAO 변수명: `tb_` 제거 후 소문자 (`UserDao user`), DataSet: 단일=`info`, 복수=`list`
- GET: `m.rs()`/`m.ri()`, POST: `f.get()`/`f.getInt()` — `request.getParameter()` 금지
- null 체크 불필요 (프레임워크가 빈 문자열 반환)
- SQL 바인딩 필수: `find("id = ?", new Object[]{id})`
- POST 처리 후 `return` 필수
- `m`, `f`, `p`, `j`, `auth`, `isLogin`, `userId` 는 init.jsp에서 자동 초기화됨
