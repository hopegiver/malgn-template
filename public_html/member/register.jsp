<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 유효성 검증 규칙 설정
f.addElement("email", null, "required:'Y', type:'email'");
f.addElement("passwd", null, "required:'Y', minlength:6");
f.addElement("passwd_confirm", null, "required:'Y', minlength:6");
f.addElement("name", null, "required:'Y', minlength:2");
f.addElement("phone", null, "required:'Y'");

// POST 처리 (회원가입)
if(m.isPost() && f.validate()) {
    String email = f.get("email");
    String passwd = f.get("passwd");
    String passwdConfirm = f.get("passwd_confirm");
    String name = f.get("name");
    String phone = f.get("phone");

    // 비밀번호 확인
    if(!passwd.equals(passwdConfirm)) {
        m.jsError("비밀번호가 일치하지 않습니다.");
        return;
    }

    UserDao user = new UserDao();

    // 이메일 중복 체크
    if(user.isDuplicateEmail(email)) {
        m.jsError("이미 등록된 이메일입니다.");
        return;
    }

    // 회원 정보 저장
    user.item("email", email);
    user.item("passwd", Malgn.sha256(passwd));
    user.item("name", name);
    user.item("phone", phone);
    user.item("reg_date", m.time());
    user.item("status", 1);

    if(user.insert()) {
        m.jsAlert("회원가입이 완료되었습니다.");
        m.jsReplace("/member/login.jsp");
    } else {
        m.jsError("회원가입 실패: " + user.getErrMsg());
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("auth");
p.setBody("member.register");
p.setVar("title", "회원가입");
p.setVar("form_script", f.getScript());

p.display();

%>
