<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 로그인 체크
if(!isLogin) {
    m.jsError("로그인이 필요합니다.");
    m.jsReplace("/member/login.jsp");
    return;
}

int id = m.ri("id");
boolean isModify = (id > 0);

BoardDao board = new BoardDao();
DataSet info = null;

// 수정 모드: 데이터 조회
if(isModify) {
    info = board.find("id = ?", new Object[]{id});

    if(!info.next()) {
        m.jsError("게시글을 찾을 수 없습니다.");
        m.jsReplace("board_list.jsp");
        return;
    }

    // 작성자 본인 확인
    if(info.i("user_id") != userId) {
        m.jsError("수정 권한이 없습니다.");
        m.jsReplace("board_list.jsp");
        return;
    }
}

// 유효성 검증 규칙 설정
if(isModify) {
    f.addElement("title", info.s("title"), "required:'Y', minlength:2");
    f.addElement("content", info.s("content"), "required:'Y', minlength:10");
} else {
    f.addElement("title", null, "required:'Y', minlength:2");
    f.addElement("content", null, "required:'Y', minlength:10");
}

// POST 처리
if(m.isPost() && f.validate()) {
    board.item("title", f.get("title"));
    board.item("content", f.get("content"));

    if(isModify) {
        // 수정
        board.item("mod_date", m.time());

        if(board.update("id = ?", new Object[]{id})) {
            m.jsAlert("게시글이 수정되었습니다.");
            m.jsReplace("board_view.jsp?id=" + id);
        } else {
            m.jsError("수정 실패: " + board.getErrMsg());
        }
    } else {
        // 등록
        board.item("user_id", userId);
        board.item("hit", 0);
        board.item("reg_date", m.time());
        board.item("status", 1);

        if(board.insert()) {
            m.jsAlert("게시글이 등록되었습니다.");
            m.jsReplace("board_view.jsp?id=" + board.id);
        } else {
            m.jsError("등록 실패: " + board.getErrMsg());
        }
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("main");
p.setBody("board.board_form");
p.setVar("title", isModify ? "게시글 수정" : "게시글 작성");
p.setVar("is_modify", isModify);
p.setVar("board_id", id);
p.setVar("form_script", f.getScript());

p.display();

%>
