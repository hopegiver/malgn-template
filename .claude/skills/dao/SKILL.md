---
description: DAO 클래스 생성 또는 수정
user_invocable: false
---

# DAO 클래스 작업

## 절차

1. `schema.sql`에서 대상 테이블의 컬럼 구조를 확인한다.
2. MCP `get_context("dao", "테이블명")`로 규칙+패턴+클래스를 조회한다.
3. MCP `get_pattern("dao-custom")`으로 DAO 표준 패턴을 조회한다.
4. MCP `get_class("DataObject")`로 상속 가능한 메소드를 확인한다.

## 필수 규칙

- `package dao;`
- `import malgnsoft.db.*;`
- `extends DataObject`
- 생성자에서 `this.table = "tb_xxx";` 설정
- PK가 `id`가 아닌 경우만 `this.PK = "xxx";` 설정
- 복잡한 쿼리(JOIN 등)는 DAO 메소드로 분리
- JSP에서 직접 복잡한 쿼리 작성 금지

## 변수 명명

```java
// JSP에서 사용 시
UserDao user = new UserDao();       // tb_user
NoticeDao notice = new NoticeDao(); // tb_notice
DataObject dao = new DataObject();  // DataObject만 dao 허용
```

## 고급 기능

### 트랜잭션
```java
// 단일 DAO
dao.startTrans();
dao.insert();
dao.endTrans();  // 커밋

// 여러 DAO 묶기
dao1.startTransWith(dao2, dao3);
// 작업들...
dao1.endTrans();
```

### 주요 메소드
- `getInsertId()` — INSERT 후 자동 생성된 ID
- `findCount("where")` — 레코드 개수
- `getOne("sql")` / `getOneInt("sql")` — 단일 값 조회
- `addJoin("tb c", "INNER", "조건")` / `addLeftJoin("tb c ON 조건")` — JOIN
- `setFields("id, name")` — 조회 필드 지정
- `replace()` — REPLACE INTO (존재 시 UPDATE)
- `setInsertIgnore(true)` — INSERT IGNORE
- `getSequence("prefix", 8)` — 순차 번호 생성
- `clear()` — item 데이터 초기화 (반복문 시 필수)
- `setJndi("jdbc/other_db")` — 다중 DB 연결
- `setDebug(out)` / `setDebug()` — 디버깅

## 완료 후

1. MCP `validate_code(code, "dao")`로 검증한다.
2. `ant compile`로 컴파일한다.
