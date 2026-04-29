package cm.cesb.dao;

import cm.cesb.model.Alerte;
import cm.cesb.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AlerteDAO {

    // ── Vérifier et créer les alertes automatiquement ─────────────
    public void verifierEtCreerAlertes(int eleveId) throws SQLException {

        // Seuils configurables
        int SEUIL_ABSENCES = 3;
        int SEUIL_RETARDS  = 5;
        int SEUIL_SANCTIONS = 2;

        // Compter les absences de l'élève
        int nbAbsences = compterAbsences(eleveId);
        if (nbAbsences >= SEUIL_ABSENCES) {
            if (!alerteExiste(eleveId, "ABSENCES_EXCESSIVES")) {
                creerAlerte(eleveId, "ABSENCES_EXCESSIVES",
                    "L'élève a " + nbAbsences
                    + " absence(s) enregistrée(s). "
                    + "Seuil maximum : " + SEUIL_ABSENCES);
            }
        }

        // Compter les retards
        int nbRetards = compterRetards(eleveId);
        if (nbRetards >= SEUIL_RETARDS) {
            if (!alerteExiste(eleveId, "RETARDS_REPETITIFS")) {
                creerAlerte(eleveId, "RETARDS_REPETITIFS",
                    "L'élève a " + nbRetards
                    + " retard(s) enregistré(s). "
                    + "Seuil maximum : " + SEUIL_RETARDS);
            }
        }

        // Compter les sanctions
        int nbSanctions = compterSanctions(eleveId);
        if (nbSanctions >= SEUIL_SANCTIONS) {
            if (!alerteExiste(eleveId, "SANCTIONS_MULTIPLES")) {
                creerAlerte(eleveId, "SANCTIONS_MULTIPLES",
                    "L'élève a reçu " + nbSanctions
                    + " sanction(s). "
                    + "Seuil maximum : " + SEUIL_SANCTIONS);
            }
        }
    }

    // ── Créer une alerte ───────────────────────────────────────────
    public void creerAlerte(int eleveId, String type,
            String message) throws SQLException {

        String sql = "INSERT INTO alertes "
                   + "(eleve_id, type_alerte, message) "
                   + "VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eleveId);
            ps.setString(2, type);
            ps.setString(3, message);
            ps.executeUpdate();
        }
    }

    // ── Vérifier si une alerte existe déjà ────────────────────────
    public boolean alerteExiste(int eleveId,
            String type) throws SQLException {

        String sql = "SELECT COUNT(*) FROM alertes "
                   + "WHERE eleve_id = ? "
                   + "AND type_alerte = ? "
                   + "AND lue = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eleveId);
            ps.setString(2, type);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    // ── Lister toutes les alertes non lues ────────────────────────
    public List<Alerte> listerNonLues() throws SQLException {

        List<Alerte> alertes = new ArrayList<>();

        String sql = "SELECT a.*, e.nom AS eleve_nom, "
                   + "e.prenom AS eleve_prenom, "
                   + "e.matricule AS eleve_matricule, "
                   + "c.nom AS eleve_classe "
                   + "FROM alertes a "
                   + "JOIN eleves e ON a.eleve_id = e.id "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "WHERE a.lue = 0 "
                   + "ORDER BY a.date_alerte DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                alertes.add(construireAlerte(rs));
            }
        }
        return alertes;
    }

    // ── Lister toutes les alertes ──────────────────────────────────
    public List<Alerte> listerToutes() throws SQLException {

        List<Alerte> alertes = new ArrayList<>();

        String sql = "SELECT a.*, e.nom AS eleve_nom, "
                   + "e.prenom AS eleve_prenom, "
                   + "e.matricule AS eleve_matricule, "
                   + "c.nom AS eleve_classe "
                   + "FROM alertes a "
                   + "JOIN eleves e ON a.eleve_id = e.id "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "ORDER BY a.lue ASC, a.date_alerte DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                alertes.add(construireAlerte(rs));
            }
        }
        return alertes;
    }

    // ── Marquer une alerte comme lue ──────────────────────────────
    public void marquerCommeLue(int id) throws SQLException {

        String sql = "UPDATE alertes SET lue = 1 WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Marquer toutes les alertes comme lues ─────────────────────
    public void marquerToutesCommeLues() throws SQLException {

        String sql = "UPDATE alertes SET lue = 1 WHERE lue = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);) {

            ps.executeUpdate();
        }
    }

    // ── Compter les alertes non lues ──────────────────────────────
    public int compterNonLues() throws SQLException {

        String sql = "SELECT COUNT(*) FROM alertes WHERE lue = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ── Compter les absences d'un élève ───────────────────────────
    private int compterAbsences(int eleveId) throws SQLException {

        String sql = "SELECT COUNT(*) FROM presences "
                   + "WHERE eleve_id = ? AND statut = 'ABSENT'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eleveId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── Compter les retards d'un élève ────────────────────────────
    private int compterRetards(int eleveId) throws SQLException {

        String sql = "SELECT COUNT(*) FROM presences "
                   + "WHERE eleve_id = ? AND statut = 'RETARD'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eleveId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── Compter les sanctions d'un élève ──────────────────────────
    private int compterSanctions(int eleveId) throws SQLException {

        String sql = "SELECT COUNT(*) FROM presences "
                   + "WHERE eleve_id = ? "
                   + "AND decision_disciplinaire != 'AUCUNE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eleveId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── Construire un objet Alerte depuis ResultSet ────────────────
    private Alerte construireAlerte(ResultSet rs) throws SQLException {

        Alerte a = new Alerte();
        a.setId(rs.getInt("id"));
        a.setEleveId(rs.getInt("eleve_id"));
        a.setEleveNom(rs.getString("eleve_nom"));
        a.setElevePrenom(rs.getString("eleve_prenom"));
        a.setEleveMatricule(rs.getString("eleve_matricule"));
        a.setEleveClasse(rs.getString("eleve_classe"));
        a.setTypeAlerte(rs.getString("type_alerte"));
        a.setMessage(rs.getString("message"));
        a.setLue(rs.getBoolean("lue"));

        Timestamp dateAlerte = rs.getTimestamp("date_alerte");
        if (dateAlerte != null) {
            a.setDateAlerte(dateAlerte.toLocalDateTime());
        }

        return a;
    }
}