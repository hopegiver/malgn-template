---
description: OAuth 소셜 로그인 구현
user_invocable: true
---

# OAuth 소셜 로그인 구현

$ARGUMENTS: 플랫폼명 (google, naver, kakao, facebook) 또는 "all"

## 절차

1. `schema.sql`에서 회원 테이블에 `oauth_provider`, `oauth_id` 컬럼이 있는지 확인한다.
2. MCP `get_context("auth")`로 인증 관련 규칙+패턴을 조회한다.
3. MCP `get_class("OAuthClient")`로 OAuthClient 클래스 메소드를 확인한다.
4. 필요한 파일들을 생성한다.

## OAuthClient 핵심 사용법

### 객체 생성 및 설정
```jsp
OAuthClient oauth = new OAuthClient(request, session);

// 클라이언트 설정 (Config에서 읽기 권장)
oauth.setClient("google", Config.get("oauth.google.clientId"), Config.get("oauth.google.clientSecret"));
```

### 인증 요청 (리다이렉트)
```jsp
String authUrl = oauth.getAuthUrl();
response.sendRedirect(authUrl);
```

### 콜백 처리
```jsp
String code = m.rs("code");
String state = m.rs("state");

// CSRF 검증 필수
if(!oauth.isValidState(state)) {
    m.jsError("잘못된 요청입니다");
    return;
}

// 프로필 가져오기
HashMap<String, Object> profile = oauth.getProfile(code);
if(profile == null) {
    m.jsError("로그인에 실패했습니다: " + oauth.errMsg);
    return;
}

String oauthId = (String)profile.get("id");
String email = (String)profile.get("email");
String name = (String)profile.get("name");
```

## config.xml OAuth 설정

```xml
<config>
    <oauth>
        <vendor>
            <vendorName>google</vendorName>
            <authorize>https://accounts.google.com/o/oauth2/v2/auth</authorize>
            <token>https://oauth2.googleapis.com/token</token>
            <profile>https://www.googleapis.com/oauth2/v2/userinfo</profile>
            <scope>email profile</scope>
        </vendor>
    </oauth>
</config>
```

## 생성할 파일

- `public_html/member/oauth_request.jsp` — 인증 요청 (vendor별 분기 + redirect)
- `public_html/member/oauth_callback.jsp` — 콜백 처리 (프로필 조회 + 회원가입/로그인)

## 핵심 규칙

- 클라이언트 시크릿은 `Config.get()`으로 조회 (하드코딩 금지)
- `oauth.isValidState(state)` CSRF 검증 필수
- 신규 회원: `oauth_provider`, `oauth_id` 저장 후 자동 가입
- 기존 회원: `oauth_provider + oauth_id`로 조회하여 로그인
- `auth.login()`으로 세션 처리

## 완료 후

1. MCP `validate_code(code, "jsp")`로 검증한다.
2. config.xml에 OAuth vendor 설정 추가를 안내한다.
3. 각 플랫폼 개발자 콘솔에서 클라이언트 ID/Secret 발급 및 콜백 URL 등록을 안내한다.
