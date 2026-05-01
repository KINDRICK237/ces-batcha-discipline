package cm.cesb.dao;

import cm.cesb.model.Presence;
import cm.cesb.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class PresenceDAO {

    // ── Enregistrer les présences ───────────────────────────────────
    public void enregistrer(Presence p) throws SQLException {

        String sql = "INSERT INTO presences "
                   + "(eleve_id, date_presence, statut, minutes_retard, "
                   + "motif, justifie, decision_disciplinaire, "
                   + "note_admin, enregistre_par) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE "
                   + "statut = VALUES(statut), "
                   + "minutes_retard = VALUES(minutes_retard), "
                   + "motif = VALUES(motif), "
                   + "justifie = VALUES(justifie), "
                   + "decision_disciplinaire = VALUES(decision_disciplinaire), "
                   + "note_admin = VALUES(note_admin), "
                   + "enregistre_par = VALUES(enregistre_par)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, p.getEleveId());
            ps.setDate(2, Date.valueOf(p.getDatePresence()));
            ps.setString(3, p.getStatut());
            ps.setInt(4, p.getMinutesRetard());
            ps.setString(5, p.getMotif());
            ps.setBoolean(6, p.isJustifie());
            ps.setString(7, p.getDecisionDisciplinaire());
            ps.setString(8, p.getNoteAdmin());
            ps.setInt(9, p.getEnregistrePar());

            ps.executeUpdate();
        }
    }

    // ── Lister les présences par classe et date ────────────────────
    public List<Presence> listerParClasseEtDate(int classeId,
            LocalDate date) throws SQLException {

        List<Presence> presences = new ArrayList<>();

        String sql = "SELECT e.id AS eleve_id, "
                   + "e.nom AS eleve_nom, "
                   + "e.prenom AS eleve_prenom, "
                   + "e.matricule AS eleve_matricule, "
                   + "c.nom AS eleve_classe, "
                   + "p.id AS presence_id, "
                   + "p.statut, p.minutes_retard, p.motif, "
                   + "p.justifie, p.decision_disciplinaire, "
                   + "p.note_admin, p.date_presence, "
                   + "p.date_enregistrement "
                   + "FROM eleves e "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "LEFT JOIN presences p ON e.id = p.eleve_id "
                   + "AND p.date_presence = ? "
                   + "WHERE e.classe_id = ? "
                   + "AND e.statut = 'ACTIF' "
                   + "ORDER BY e.nom, e.prenom";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(date));
            ps.setInt(2, classeId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    presences.add(construirePresence(rs));
                }
            }
        }
        return presences;
    }

    // ── Lister les présences d'un élève ───────────────────────────
    public List<Presence> listerParEleve(int eleveId) throws SQLException {

        List<Presence> presences = new ArrayList<>();

        String sql = "SELECT e.id AS eleve_id, "
                   + "e.nom AS eleve_nom, "
                   + "e.prenom AS eleve_prenom, "
                   + "e.matricule AS eleve_matricule, "
                   + "c.nom AS eleve_classe, "
                   + "p.id AS presence_id, "
                   + "p.statut, p.minutes_retard, p.motif, "
                   + "p.justifie, p.decision_disciplinaire, "
                   + "p.note_admin, p.date_presence, "
                   + "p.date_enregistrement "
                   + "FROM presences p "
                   + "JOIN eleves e ON p.eleve_id = e.id "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "WHERE p.eleve_id = ? "
                   + "ORDER BY p.date_presence DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eleveId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    presences.add(construirePresence(rs));
                }
            }
        }
        return presences;
    }

    // ── Stats globales par période et classe ───────────────────────
    public int[] statsParPeriodeEtClasse(int classeId,
            LocalDate debut, LocalDate fin) throws SQLException {

        // Retourne [presents, absents, retards, totalMinutes]
        int[] stats = {0, 0, 0, 0};

        String sql = "SELECT "
                   + "SUM(CASE WHEN p.statut='PRESENT' THEN 1 ELSE 0 END) AS presents, "
                   + "SUM(CASE WHEN p.statut='ABSENT'  THEN 1 ELSE 0 END) AS absents, "
                   + "SUM(CASE WHEN p.statut='RETARD'  THEN 1 ELSE 0 END) AS retards, "
                   + "COALESCE(SUM(p.minutes_retard), 0) AS total_minutes "
                   + "FROM presences p "
                   + "JOIN eleves e ON p.eleve_id = e.id "
                   + "WHERE e.classe_id = ? "
                   + "AND p.date_presence BETWEEN ? AND ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, classeId);
            ps.setDate(2, Date.valueOf(debut));
            ps.setDate(3, Date.valueOf(fin));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats[0] = rs.getInt("presents");
                    stats[1] = rs.getInt("absents");
                    stats[2] = rs.getInt("retards");
                    stats[3] = rs.getInt("total_minutes");
                }
            }
        }
        return stats;
    }

    // ── Stats globales toutes classes par période ──────────────────
    public int[] statsGlobalesParPeriode(LocalDate debut,
            LocalDate fin) throws SQLException {

        int[] stats = {0, 0, 0, 0};

        String sql = "SELECT "
                   + "SUM(CASE WHEN statut='PRESENT' THEN 1 ELSE 0 END) AS presents, "
                   + "SUM(CASE WHEN statut='ABSENT'  THEN 1 ELSE 0 END) AS absents, "
                   + "SUM(CASE WHEN statut='RETARD'  THEN 1 ELSE 0 END) AS retards, "
                   + "COALESCE(SUM(minutes_retard), 0) AS total_minutes "
                   + "FROM presences "
                   + "WHERE date_presence BETWEEN ? AND ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(debut));
            ps.setDate(2, Date.valueOf(fin));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats[0] = rs.getInt("presents");
                    stats[1] = rs.getInt("absents");
                    stats[2] = rs.getInt("retards");
                    stats[3] = rs.getInt("total_minutes");
                }
            }
        }
        return stats;
    }

    // ── Compter présents aujourd'hui ───────────────────────────────
    public int compterPresentsAujourdhui() throws SQLException {
        String sql = "SELECT COUNT(*) FROM presences "
                   + "WHERE date_presence = CURDATE() AND statut = 'PRESENT'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ── Compter absents aujourd'hui ────────────────────────────────
    public int compterAbsentsAujourdhui() throws SQLException {
        String sql = "SELECT COUNT(*) FROM presences "
                   + "WHERE date_presence = CURDATE() AND statut = 'ABSENT'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ── Compter retards aujourd'hui ────────────────────────────────
    public int compterRetardsAujourdhui() throws SQLException {
        String sql = "SELECT COUNT(*) FROM presences "
                   + "WHERE date_presence = CURDATE() AND statut = 'RETARD'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ── Construire un objet Presence depuis ResultSet ──────────────
    private Presence construirePresence(ResultSet rs) throws SQLException {

        Presence p = new Presence();
        p.setEleveId(rs.getInt("eleve_id"));
        p.setEleveNom(rs.getString("eleve_nom"));
        p.setElevePrenom(rs.getString("eleve_prenom"));
        p.setEleveMatricule(rs.getString("eleve_matricule"));
        p.setEleveClasse(rs.getString("eleve_classe"));
        p.setId(rs.getInt("presence_id"));
        p.setStatut(rs.getString("statut"));
        p.setMinutesRetard(rs.getInt("minutes_retard"));
        p.setMotif(rs.getString("motif"));
        p.setJustifie(rs.getBoolean("justifie"));
        p.setDecisionDisciplinaire(rs.getString("decision_disciplinaire"));
        p.setNoteAdmin(rs.getString("note_admin"));

        Date datePresence = rs.getDate("date_presence");
        if (datePresence != null) {
            p.setDatePresence(datePresence.toLocalDate());
        }

        Timestamp dateEnreg = rs.getTimestamp("date_enregistrement");
        if (dateEnreg != null) {
            p.setDateEnregistrement(dateEnreg.toLocalDateTime());
        }

        return p;
    }
}