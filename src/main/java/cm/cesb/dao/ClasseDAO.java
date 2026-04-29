package cm.cesb.dao;

import cm.cesb.model.Classe;
import cm.cesb.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClasseDAO {

    // ── Lister toutes les classes ──────────────────────────────────
    public List<Classe> listerTous() throws SQLException {

        List<Classe> classes = new ArrayList<>();

        String sql = "SELECT id, nom, niveau, annee_scolaire, "
                   + "enseignant_principal_id "
                   + "FROM classes "
                   + "ORDER BY niveau, nom";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                classes.add(construireClasse(rs));
            }
        }
        return classes;
    }

    // ── Trouver une classe par ID ──────────────────────────────────
    public Classe trouverParId(int id) throws SQLException {

        String sql = "SELECT id, nom, niveau, annee_scolaire, "
                   + "enseignant_principal_id "
                   + "FROM classes WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return construireClasse(rs);
                }
            }
        }
        return null;
    }

    // ── Ajouter une classe ─────────────────────────────────────────
    public void ajouter(Classe c) throws SQLException {

        String sql = "INSERT INTO classes "
                   + "(nom, niveau, annee_scolaire) "
                   + "VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, c.getNom());
            ps.setString(2, c.getNiveau());
            ps.setString(3, c.getAnneeScolaire());

            ps.executeUpdate();
        }
    }

    // ── Modifier une classe ────────────────────────────────────────
    public void modifier(Classe c) throws SQLException {

        String sql = "UPDATE classes SET "
                   + "nom = ?, niveau = ?, annee_scolaire = ? "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, c.getNom());
            ps.setString(2, c.getNiveau());
            ps.setString(3, c.getAnneeScolaire());
            ps.setInt(4, c.getId());

            ps.executeUpdate();
        }
    }

    // ── Supprimer une classe ───────────────────────────────────────
    public void supprimer(int id) throws SQLException {

        String sql = "DELETE FROM classes WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Construire un objet Classe depuis ResultSet ────────────────
    private Classe construireClasse(ResultSet rs) throws SQLException {

        Classe c = new Classe();
        c.setId(rs.getInt("id"));
        c.setNom(rs.getString("nom"));
        c.setNiveau(rs.getString("niveau"));
        c.setAnneeScolaire(rs.getString("annee_scolaire"));
        c.setEnseignantPrincipalId(rs.getInt("enseignant_principal_id"));

        return c;
    }
}