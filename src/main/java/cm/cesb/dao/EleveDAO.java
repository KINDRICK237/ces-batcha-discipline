package cm.cesb.dao;

import cm.cesb.model.Eleve;
import cm.cesb.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class EleveDAO {

    // ── Lister tous les élèves ─────────────────────────────────────
    public List<Eleve> listerTous() throws SQLException {

        List<Eleve> eleves = new ArrayList<>();

        String sql = "SELECT e.*, c.nom AS classe_nom "
                   + "FROM eleves e "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "ORDER BY e.nom, e.prenom";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                eleves.add(construireEleve(rs));
            }
        }
        return eleves;
    }

    // ── Lister les élèves par classe ───────────────────────────────
    public List<Eleve> listerParClasse(int classeId) throws SQLException {

        List<Eleve> eleves = new ArrayList<>();

        String sql = "SELECT e.*, c.nom AS classe_nom "
                   + "FROM eleves e "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "WHERE e.classe_id = ? "
                   + "ORDER BY e.nom, e.prenom";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, classeId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    eleves.add(construireEleve(rs));
                }
            }
        }
        return eleves;
    }

    // ── Trouver un élève par ID ────────────────────────────────────
    public Eleve trouverParId(int id) throws SQLException {

        String sql = "SELECT e.*, c.nom AS classe_nom "
                   + "FROM eleves e "
                   + "JOIN classes c ON e.classe_id = c.id "
                   + "WHERE e.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return construireEleve(rs);
                }
            }
        }
        return null;
    }

    // ── Ajouter un élève ──────────────────────────────────────────
    public void ajouter(Eleve e) throws SQLException {

        String sql = "INSERT INTO eleves "
                   + "(matricule, nom, prenom, date_naissance, genre, "
                   + "classe_id, telephone_parent, nom_parent, adresse, statut) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIF')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, e.getMatricule());
            ps.setString(2, e.getNom());
            ps.setString(3, e.getPrenom());
            ps.setDate(4, e.getDateNaissance() != null
                    ? Date.valueOf(e.getDateNaissance()) : null);
            ps.setString(5, e.getGenre());
            ps.setInt(6, e.getClasseId());
            ps.setString(7, e.getTelephoneParent());
            ps.setString(8, e.getNomParent());
            ps.setString(9, e.getAdresse());

            ps.executeUpdate();
        }
    }

    // ── Modifier un élève ─────────────────────────────────────────
    public void modifier(Eleve e) throws SQLException {

        String sql = "UPDATE eleves SET "
                   + "nom = ?, prenom = ?, date_naissance = ?, "
                   + "genre = ?, classe_id = ?, telephone_parent = ?, "
                   + "nom_parent = ?, adresse = ?, statut = ? "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, e.getNom());
            ps.setString(2, e.getPrenom());
            ps.setDate(3, e.getDateNaissance() != null
                    ? Date.valueOf(e.getDateNaissance()) : null);
            ps.setString(4, e.getGenre());
            ps.setInt(5, e.getClasseId());
            ps.setString(6, e.getTelephoneParent());
            ps.setString(7, e.getNomParent());
            ps.setString(8, e.getAdresse());
            ps.setString(9, e.getStatut());
            ps.setInt(10, e.getId());

            ps.executeUpdate();
        }
    }

    // ── Supprimer un élève ────────────────────────────────────────
    public void supprimer(int id) throws SQLException {

        String sql = "DELETE FROM eleves WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Compter tous les élèves ───────────────────────────────────
    public int compterTous() throws SQLException {

        String sql = "SELECT COUNT(*) FROM eleves WHERE statut = 'ACTIF'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── Construire un objet Eleve depuis ResultSet ─────────────────
    private Eleve construireEleve(ResultSet rs) throws SQLException {

        Eleve e = new Eleve();
        e.setId(rs.getInt("id"));
        e.setMatricule(rs.getString("matricule"));
        e.setNom(rs.getString("nom"));
        e.setPrenom(rs.getString("prenom"));
        e.setGenre(rs.getString("genre"));
        e.setClasseId(rs.getInt("classe_id"));
        e.setClasseNom(rs.getString("classe_nom"));
        e.setTelephoneParent(rs.getString("telephone_parent"));
        e.setNomParent(rs.getString("nom_parent"));
        e.setAdresse(rs.getString("adresse"));
        e.setStatut(rs.getString("statut"));

        Date dateNaissance = rs.getDate("date_naissance");
        if (dateNaissance != null) {
            e.setDateNaissance(dateNaissance.toLocalDate());
        }

        Date dateInscription = rs.getDate("date_inscription");
        if (dateInscription != null) {
            e.setDateInscription(dateInscription.toLocalDate());
        }

        return e;
    }
}