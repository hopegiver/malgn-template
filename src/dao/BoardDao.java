package dao;

import malgnsoft.db.*;

public class BoardDao extends DataObject {
    public BoardDao() {
        this.table = "tb_board";
        this.PK = "id";
    }

    public boolean increaseHit(int id) {
        this.item("hit", "", "hit + 1");
        return this.update("id = ?", new Object[]{id});
    }

    public DataSet findByUserId(int userId) {
        return this.find("user_id = ?", new Object[]{userId});
    }
}
