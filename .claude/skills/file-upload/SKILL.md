---
description: 파일 업로드/다운로드 기능 생성
user_invocable: true
---

# 파일 업로드/다운로드 기능 생성

$ARGUMENTS: 대상 기능명 또는 테이블명

## 절차

1. MCP `get_context("upload")`로 파일 업로드 관련 규칙을 조회한다.
2. MCP `get_class("Form")`으로 파일 업로드 관련 메소드를 확인한다.
3. MCP `get_pattern("jsp-insert")`로 Postback 패턴을 참조한다.

## 파일 업로드 패턴

### JSP (유효성 검증)
```jsp
// 확장자 검증 (allow + deny 조합 권장)
f.addElement("photo", null, "allow:'jpg|jpeg|png|gif', deny:'exe|jsp|php'");
f.addElement("document", null, "allow:'pdf|doc|docx|xls|xlsx'");

// 파일 필수
f.addElement("file", null, "required:'Y'");

// POST 처리
if(m.isPost() && f.validate()) {
    File uploadedFile = f.saveFile("file");
    if(uploadedFile != null) {
        String fileName = f.getFileName("file");
        long fileSize = uploadedFile.length();
        int newId = dao.getInsertId();
    }
}
```

### 여러 파일 업로드
```jsp
// HTML: <input type="file" name="files" multiple>
File[] files = f.saveFiles("files");
String[] fileNames = f.getFileNames("files");
```

### HTML (enctype 필수)
```html
<form name="form1" method="post" enctype="multipart/form-data">
    <input type="file" name="file">
</form>
{{form_script}}
```

## 파일 다운로드 패턴

```jsp
// 기본 다운로드
m.download(filePath, fileName);

// 대역폭 제한 (KB/s)
m.download(filePath, fileName, 100);

// 브라우저에 표시 (미리보기)
m.output(filePath, "application/pdf");
m.output(filePath, "image/jpeg");
```

## 이미지 썸네일

```jsp
Thumbnail thumb = new Thumbnail();
// 가로 200px, 높이 자동 (비율 유지)
thumb.createThumbnail(sourcePath, thumbPath, 200, 0);
// 정사각형 크롭
thumb.createThumbnail(sourcePath, thumbPath, 200, 200);
```

## 유틸리티

- `Malgn.getFileExt("file.pdf")` → `"pdf"`
- `Malgn.getMimeType("image.png")` → `"image/png"`
- `Malgn.getFileSize(1048576)` → `"1MB"`
- `Malgn.readFile(path)` / `Malgn.writeFile(path, content)`
- `Malgn.copyFile(src, dest)` / `Malgn.delFile(path)`

## 보안 필수사항

- 확장자 검증: `allow` + `deny` 속성 사용
- 위험 확장자 차단: `exe|jsp|php|asp|sh|bat`
- 파일 크기 검증: `file.length() > maxSize` 체크
- 경로 조작 방지: DB에서 파일 경로 조회 (사용자 입력 직접 사용 금지)
- 권한 체크: 다운로드/삭제 시 소유자 또는 관리자 확인

## 완료 후

MCP `validate_code(code, "jsp")`로 검증한다.
