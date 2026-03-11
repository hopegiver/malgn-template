---
description: 다국어(i18n) 지원 구현
user_invocable: true
---

# 다국어(i18n) 지원 구현

$ARGUMENTS: 지원할 언어 목록 (예: ko,en,ja)

## 절차

1. MCP `get_class("Message")`로 Message 클래스 메소드를 확인한다.
2. 메시지 파일 구조를 생성한다.
3. 언어 전환 기능을 구현한다.

## Message 클래스 핵심 사용법

### 기본 사용
```jsp
Message msg = new Message();           // 기본 로케일
Message msg = new Message("en");       // 영어
msg.setLocale("ko");                   // 로케일 변경

String text = msg.get("welcome");      // 메시지 조회
String text = msg.get("key", "기본값"); // 기본값 지정
```

### 동적 메시지
```jsp
// {0}, {1} 치환
msg.format("user.greeting", "홍길동");  // "안녕하세요, 홍길동님!"

// {{name}} 치환
msg.get("email.template", new String[]{"name=>홍길동", "product=>노트북"});
```

### 캐시 관리
```jsp
msg.reload("en");    // 특정 로케일 리로드
msg.reloadAll();     // 전체 리로드
```

## 메시지 파일 구조

```
/WEB-INF/message/
  ├── message.properties        (기본 언어)
  ├── message_en.properties     (영어)
  ├── message_ko.properties     (한국어)
  └── message_ja.properties     (일본어)
```

### 파일 형식
```properties
# 공통
welcome=환영합니다
login=로그인
common.save=저장
common.cancel=취소
error.required=필수 항목입니다
user.greeting=안녕하세요, {0}님!
```

## 생성할 파일

- `/WEB-INF/message/message.properties` — 기본 메시지
- `/WEB-INF/message/message_{lang}.properties` — 언어별 메시지
- 언어 전환 컴포넌트 (선택)

## 핵심 규칙

- 메시지 파일은 반드시 UTF-8 인코딩
- 키는 계층적 구조 사용 (`user.profile.title`)
- 모든 언어 파일에 동일한 키 유지
- `message.properties`는 항상 유지 (폴백용)
- Message 객체는 재사용 (루프 안에서 매번 생성 금지)
