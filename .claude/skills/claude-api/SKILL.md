---
description: Build apps with the Claude API or Anthropic SDK.
trigger: code imports `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`, or user asks to use Claude API, Anthropic SDKs, or Agent SDK
---

# Claude API 연동

이 프로젝트는 맑은프레임워크(JSP) 기반이므로, Claude API 연동 시 DAO 레이어에서 처리한다.

## 규칙

- JSP에서 직접 외부 라이브러리 import 금지
- HTTP 클라이언트 호출은 반드시 DAO 클래스에서 처리
- API 키는 `config.xml` 또는 환경변수로 관리 (하드코딩 금지)
- 응답은 DAO 메소드에서 파싱하여 DataSet 또는 String으로 반환

## 절차

1. `src/dao/` 에 API 연동 DAO 클래스를 생성한다.
2. DAO에서 HttpURLConnection 또는 프레임워크 HTTP 클래스를 사용한다.
3. JSP에서는 DAO 메소드만 호출한다.
4. `ant compile`로 컴파일한다.
