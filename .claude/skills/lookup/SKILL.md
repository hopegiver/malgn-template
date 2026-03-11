---
description: 맑은프레임워크 클래스/메소드/문서 조회
user_invocable: true
---

# 맑은프레임워크 조회

$ARGUMENTS: 조회할 클래스명, 메소드명, 또는 검색 키워드

## 절차

인자의 형태에 따라 적절한 MCP 도구를 사용한다:

### 클래스 조회 (예: DataObject, Malgn, Page, Form, Auth, Json, ListManager)
- MCP `get_class("$ARGUMENTS")`로 해당 클래스의 메소드 상세를 조회한다.

### 규칙 조회 (예: naming, postback, security)
- MCP `get_rules("$ARGUMENTS")`로 해당 카테고리의 규칙을 조회한다.

### 패턴 조회 (예: jsp-list, html-form, dao-custom)
- MCP `get_pattern("$ARGUMENTS")`로 코드 패턴 템플릿을 조회한다.

### 문서 검색 (키워드)
- MCP `search_docs("$ARGUMENTS")`로 프레임워크 문서를 검색한다.

### 특정 문서 조회
- MCP `get_doc("$ARGUMENTS")`로 특정 문서를 조회한다.

## 결과 출력

조회 결과를 사용자에게 보기 좋게 정리하여 출력한다.
- 클래스: 메소드 목록과 사용 예시
- 규칙: 규칙 내용과 올바른/잘못된 코드 예시
- 패턴: 코드 템플릿과 사용 방법
