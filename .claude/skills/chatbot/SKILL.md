---
description: OpenAI 챗봇/AI 기능 구현
user_invocable: true
---

# OpenAI 챗봇/AI 기능 구현

$ARGUMENTS: 기능 설명 (예: 고객 상담 챗봇, 문서 요약, 번역)

## 절차

1. MCP `get_class("OpenAI")`로 OpenAI 클래스 메소드를 확인한다.
2. config.xml에 `openaiApiKey` 설정 확인을 안내한다.
3. API 엔드포인트와 프론트엔드를 생성한다.

## OpenAI 클래스 핵심 사용법

### 기본 설정
```jsp
OpenAI ai = new OpenAI();
ai.apiKey(Config.get("openaiApiKey"));
ai.modelName("gpt-4o-mini");     // 모델 선택
ai.temperature(0.7);              // 창의성 (0.0~2.0)
ai.maxToken(1000);                // 최대 토큰
```

### 클라이언트 제어 방식 (REST API용)
```jsp
String messagesJson = m.rs("messages");  // JSON 배열 문자열
String response = ai.chat(messagesJson);
if(ai.errMsg != null) j.error(ai.errMsg);
else j.success(response);
```

### 서버 자동 관리 방식 (세션 기반)
```jsp
// 히스토리 로드
String historyJson = (String)session.getAttribute("chatHistory");
if(historyJson != null) ai.setHistory(historyJson);
else ai.system("당신은 친절한 AI 도우미입니다.");

// AI 호출 (히스토리 자동 관리)
String response = ai.chatMemory(m.rs("message"));

// 히스토리 저장
session.setAttribute("chatHistory", ai.getHistory());
```

### 스트림 방식 (실시간 출력)
```jsp
String fullResponse = ai.streamChat(messagesJson, out);
// 또는 서버 관리 + 스트림
String response = ai.streamMemory(message, out);
```

### 주요 메소드
- `ai.chat(messagesJson)` — 단발 호출 (JSON 문자열)
- `ai.chatMemory(message)` — 히스토리 자동 관리
- `ai.streamChat(messagesJson, out)` — 스트림 출력
- `ai.streamMemory(message, out)` — 스트림 + 히스토리
- `ai.system("프롬프트")` — 시스템 메시지 설정/교체
- `ai.setHistory(json)` / `ai.getHistory()` — 히스토리 관리
- `ai.errMsg` — 에러 메시지 (null이면 성공)

## 생성할 파일

- `public_html/api/chat.jsp` — 챗봇 API 엔드포인트
- `public_html/html/{폴더명}/chat.html` — 챗 UI (필요 시)

## 핵심 규칙

- API 키는 `Config.get("openaiApiKey")` 사용 (하드코딩 금지)
- `ai.errMsg` null 체크 필수
- 민감한 개인정보는 AI에 전송 금지
- 긴 응답은 스트림 방식 권장
- 비용 최적화: 적절한 모델 + temperature + maxToken 설정

## 완료 후

1. MCP `validate_code(code, "jsp")`로 검증한다.
2. config.xml에 `openaiApiKey` 설정 안내한다.
