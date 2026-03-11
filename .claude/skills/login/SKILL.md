---
description: 로그인/회원 인증 기능 생성
user_invocable: true
---

# 로그인/회원 인증 기능 생성

$ARGUMENTS: 생성할 기능 (예: login, signup, logout, mypage)

## 절차

1. `schema.sql`에서 회원 테이블(tb_user 등)의 구조를 확인한다.
2. MCP `get_context("auth")`로 인증 관련 규칙+패턴을 조회한다.
3. MCP `get_class("Auth")`로 Auth 클래스 메소드를 확인한다.
4. MCP `get_class("Malgn")`으로 sha256 등 유틸리티 메소드를 확인한다.

## 인증 관련 init.jsp 자동 초기화 변수

- `auth` — Auth 객체
- `isLogin` — boolean 로그인 여부
- `userId` — int 사용자 ID
- `userName` — String 사용자 이름

## 주요 패턴

### 로그인 체크 (메시지 없이 리다이렉트)
```jsp
if(!isLogin) {
    m.redirect("/member/login.jsp");
    return;
}
```

### 로그인 처리
```jsp
auth.put("user_id", info.i("id"));
auth.put("user_name", info.s("name"));
auth.save();
```

### 로그아웃
```jsp
auth.delete();
m.jsAlert("로그아웃되었습니다.");
m.jsReplace("/");
```

### 비밀번호 암호화
```jsp
user.item("passwd", Malgn.sha256(f.get("passwd")));
```

### Auth 설정 옵션 (init.jsp에서 설정)
```jsp
auth.setKeyName("MY_AUTH");       // 세션/쿠키 키 이름 (기본: AUTHID)
auth.setSecure(true);             // HTTPS 전용
auth.setHttpOnly(true);           // XSS 방지
auth.setSameSite("Strict");       // CSRF 방지
auth.setValidTime(3600);          // 인증 유효 시간 (초)
auth.setMaxAge(86400);            // 쿠키 유효 기간 (초)
```

### Auth 주요 메소드
- `auth.isValid()` — 인증 검증 (init.jsp에서)
- `auth.put(key, value)` / `auth.save()` — 로그인 시
- `auth.getInt(key)` / `auth.getString(key)` — 값 조회
- `auth.delete()` — 로그아웃
- `auth.loginForm()` — 로그인 페이지로 리다이렉트

## 생성할 파일

- `public_html/member/{기능}.jsp` — JSP (로직)
- `public_html/html/member/{기능}.html` — HTML (템플릿)

## 완료 후

1. MCP `validate_code(code, "jsp")`로 검증한다.
2. MCP `validate_code(code, "html")`로 검증한다.
