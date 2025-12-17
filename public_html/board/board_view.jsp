<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

int id = m.ri("id");

if(id == 0) {
    m.jsError("잘못된 접근입니다.");
    m.jsReplace("board_list.jsp");
    return;
}

BoardDao board = new BoardDao();

// 조회수 증가
board.increaseHit(id);

// 게시글 조회 (작성자 정보 포함)
DataSet info = board.query(
    "SELECT b.*, u.name as user_name " +
    "FROM tb_board b " +
    "LEFT JOIN tb_user u ON b.user_id = u.id " +
    "WHERE b.id = ?",
    new Object[]{id}
);

if(!info.next()) {
    m.jsError("게시글을 찾을 수 없습니다.");
    m.jsReplace("board_list.jsp");
    return;
}

// 날짜 포맷
String regDate = info.s("reg_date");
String regDateFormat = m.time("yyyy-MM-dd HH:mm", regDate);

// 수정일이 있으면 포맷
String modDate = info.s("mod_date");
String modDateFormat = "";
if(modDate != null && !modDate.isEmpty()) {
    modDateFormat = m.time("yyyy-MM-dd HH:mm", modDate);
}

// 작성자 본인 여부
boolean isAuthor = (info.i("user_id") == userId);

p.setLayout("main");
p.setBody("board.board_view");
p.setVar(info);
p.setVar("title", info.s("title"));
p.setVar("is_author", isAuthor);
p.setVar("reg_date_format", regDateFormat);
p.setVar("mod_date_format", modDateFormat);

p.display();

%>
