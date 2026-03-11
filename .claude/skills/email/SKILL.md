---
description: 이메일 발송 기능 생성
user_invocable: true
---

# 이메일 발송 기능 생성

$ARGUMENTS: 기능 설명 (예: 문의하기 폼, 회원가입 환영 메일, 뉴스레터)

## 절차

1. MCP `get_context("page")`로 규칙+패턴을 조회한다.
2. MCP `get_class("Gmail")`으로 Gmail 클래스 메소드를 확인한다.
3. 필요한 파일을 생성한다.

## Gmail 클래스 핵심 사용법

### 기본 발송
```jsp
// config.xml 설정 사용 (가장 간단)
Gmail mail = new Gmail();
mail.send("recipient@example.com", "제목", "내용");

// 또는 Malgn 메소드
m.mail("recipient@example.com", "제목", "내용");
```

### SMTP 서버별 생성
```jsp
// Gmail
Gmail mail = new Gmail("your-email@gmail.com", "앱비밀번호");

// 네이버
Gmail mail = new Gmail("smtp.naver.com", "아이디", "비밀번호");
mail.setMailFrom("아이디@naver.com");

// AWS SES
Gmail mail = new Gmail("email-smtp.ap-northeast-2.amazonaws.com", "SMTP사용자", "SMTP비밀번호");
mail.setMailFrom("verified@yourdomain.com");
```

### 파일 첨부
```jsp
mail.send("recipient@example.com", "제목", "내용", new String[] { filePath1, filePath2 });
```

### 여러 수신자
```jsp
String[] recipients = { "user1@example.com", "user2@example.com" };
mail.send(recipients, "제목", "내용");
```

### HTML 이메일 (템플릿 활용)
```jsp
p.setBody("mail.welcome");
p.setVar("name", name);
String htmlBody = p.fetch();
mail.send(email, "제목", htmlBody);
```

### 비동기 발송 (대량)
```jsp
// 백그라운드 스레드 (논블로킹, 즉시 반환)
m.mailer("recipient@example.com", "제목", "내용");

// 파일 첨부 비동기
m.mailer("recipient@example.com", "제목", "내용", filePath);
```

## m.mail() vs m.mailer()
- `m.mail()` — 동기, 발송 완료까지 대기, 소량 발송용
- `m.mailer()` — 비동기, 즉시 반환, 대량 발송용 (최대 50 스레드)

## 생성할 파일

- `public_html/{폴더명}/{파일명}.jsp` — JSP (로직 + 이메일 발송)
- `public_html/html/{폴더명}/{파일명}.html` — HTML (입력 폼)
- `public_html/html/mail/{템플릿명}.html` — HTML (이메일 템플릿, 필요 시)

## 완료 후

1. MCP `validate_code(code, "jsp")`로 검증한다.
2. config.xml에 메일 서버 설정이 있는지 확인을 안내한다.
