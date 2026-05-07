package cm.cesb.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String HOST =
        System.getenv("DB_HOST") != null
        ? System.getenv("DB_HOST")
        : "switchyard.proxy.rlwy.net";

    private static final String PORT =
        System.getenv("DB_PORT") != null
        ? System.getenv("DB_PORT") : "25971";

    private static final String DATABASE =
        System.getenv("DB_NAME") != null
        ? System.getenv("DB_NAME") : "railway";

    private static final String USER =
        System.getenv("DB_USER") != null
        ? System.getenv("DB_USER") : "root";

    private static final String PASSWORD =
        System.getenv("DB_PASSWORD") != null
        ? System.getenv("DB_PASSWORD")
        : "ToUMmVKCkohdKYagaNWyTsmlhudnMsEf";

    private static final String URL =
        "jdbc:mysql://" + HOST + ":" + PORT + "/" + DATABASE
        + "?useSSL=false"
        + "&serverTimezone=UTC"
        + "&characterEncoding=UTF-8"
        + "&allowPublicKeyRetrieval=true"
        + "&connectTimeout=30000"
        + "&socketTimeout=30000";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "Driver MySQL introuvable : " + e.getMessage()
            );
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private DBConnection() {}
}