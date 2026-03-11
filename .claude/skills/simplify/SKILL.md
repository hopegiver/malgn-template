---
description: Review changed code for reuse, quality, and efficiency, then fix any issues found.
---

# 코드 간소화

변경된 코드의 재사용성, 품질, 효율성을 검토하고 문제를 수정한다.

## 절차

1. `git diff --name-only HEAD`로 변경된 파일 목록을 수집한다.
2. 각 파일을 읽고 확장자별로 분류한다.
3. MCP `get_rules("checklist")`로 맑은프레임워크 체크리스트를 조회한다.
4. 다음 항목을 검토한다:

### 불필요한 코드 제거
- 불필요한 변수 선언 → `p.setVar()`에 직접 전달
- 불필요한 null 체크 → 프레임워크가 빈 문자열 반환
- try-catch → boolean 리턴값으로 대체
- `moveRow()` 호출 → `setLoop()`가 자동 초기화

### 효율성 개선
- 별도 변수 대신 `info.put()` / `list.put()` 사용
- `p.setVar(info)` 한 번에 전달
- 복잡한 쿼리는 DAO 메소드로 분리

### 맑은프레임워크 규칙 준수
- JSP/HTML 분리 확인
- Page 메소드 호출 순서
- 명명 규칙 (DAO 변수명, DataSet 변수명)

5. 각 JSP 파일을 MCP `validate_code(code, "jsp")`로 검증한다.
6. 발견된 문제를 수정한다.
