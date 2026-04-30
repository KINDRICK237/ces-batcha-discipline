package cm.cesb.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String HOST =
        System.getenv("DB_HOST") != null
        ? System.getenv("DB_HOST") : "sql3.freesqldatabase.com";

    private static final String PORT =
        System.getenv("DB_PORT") != null
        ? System.getenv("DB_PORT") : "3306";

    private static final String DATABASE =
        System.getenv("DB_NAME") != null
        ? System.getenv("DB_NAME") : "sql3824750";

    private static final String USER =
        System.getenv("DB_USER") != null
        ? System.getenv("DB_USER") : "sql3824750";

    private static final String PASSWORD =
        System.getenv("DB_PASSWORD") != null
        ? System.getenv("DB_PASSWORD") : "k8f4LVynQF";

    private static final String URL =
        "jdbc:mysql://" + HOST + ":" + PORT + "/" + DATABASE
        + "?useSSL=true"
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