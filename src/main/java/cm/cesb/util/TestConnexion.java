package cm.cesb.util;

import java.sql.Connection;
import java.sql.SQLException;

public class TestConnexion {

    public static void main(String[] args) {

        System.out.println("Test de connexion a MySQL...");

        try (Connection conn = DBConnection.getConnection()) {

            if (conn != null) {
                System.out.println("Connexion reussie !");
                System.out.println("Base : " + conn.getCatalog());
            }

        } catch (SQLException e) {
            System.out.println("Connexion echouee !");
            System.out.println("Erreur : " + e.getMessage());
        }
    }
}