package cm.cesb.dao;

import cm.cesb.model.Utilisateur;
import cm.cesb.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UtilisateurDAO {

    // ── Trouver par email ──────────────────────────────────────────
    public Utilisateur trouverParEmail(String email) throws SQLException {

        String sql = "SELECT id, nom, prenom, email, mot_de_passe, "
                   + "role, actif, date_creation, derniere_connexion "
                   + "FROM utilisateurs WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return construireUtilisateur(rs);
                }
            }
        }
        return null;
    }

    // ── Trouver par ID ─────────────────────────────────────────────
    public Utilisateur trouverParId(int id) throws SQLException {

        String sql = "SELECT id, nom, prenom, email, mot_de_passe, "
                   + "role, actif, date_creation, derniere_connexion "
                   + "FROM utilisateurs WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return construireUtilisateur(rs);
                }
            }
        }
        return null;
    }

    // ── Lister tous les utilisateurs ──────────────────────────────
    public List<Utilisateur> listerTous() throws SQLException {

        List<Utilisateur> utilisateurs = new ArrayList<>();

        String sql = "SELECT id, nom, prenom, email, mot_de_passe, "
                   + "role, actif, date_creation, derniere_connexion "
                   + "FROM utilisateurs "
                   + "ORDER BY role, nom, prenom";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                utilisateurs.add(construireUtilisateur(rs));
            }
        }
        return utilisateurs;
    }

    // ── Ajouter un utilisateur ─────────────────────────────────────
    public void ajouter(Utilisateur u) throws SQLException {

        String sql = "INSERT INTO utilisateurs "
                   + "(nom, prenom, email, mot_de_passe, role, actif) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, u.getNom());
            ps.setString(2, u.getPrenom());
            ps.setString(3, u.getEmail());
            ps.setString(4, u.getMotDePasse());
            ps.setString(5, u.getRole());
            ps.setBoolean(6, u.isActif());

            ps.executeUpdate();
        }
    }

    // ── Modifier un utilisateur ────────────────────────────────────
    public void modifier(Utilisateur u) throws SQLException {

        String sql = "UPDATE utilisateurs SET "
                   + "nom = ?, prenom = ?, email = ?, "
                   + "mot_de_passe = ?, role = ? "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, u.getNom());
            ps.setString(2, u.getPrenom());
            ps.setString(3, u.getEmail());
            ps.setString(4, u.getMotDePasse());
            ps.setString(5, u.getRole());
            ps.setInt(6, u.getId());

            ps.executeUpdate();
        }
    }

    // ── Changer le statut actif/inactif ───────────────────────────
    public void changerStatut(int id, boolean actif) throws SQLException {

        String sql = "UPDATE utilisateurs SET actif = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, actif);
            ps.setInt(2, id);

            ps.executeUpdate();
        }
    }

    // ── Supprimer un utilisateur ───────────────────────────────────
    public void supprimer(int id) throws SQLException {

        String sql = "DELETE FROM utilisateurs WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Mettre à jour la dernière connexion ───────────────────────
    public void majDerniereConnexion(int id) throws SQLException {

        String sql = "UPDATE utilisateurs "
                   + "SET derniere_connexion = NOW() "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Construire un objet Utilisateur depuis ResultSet ──────────
    private Utilisateur construireUtilisateur(ResultSet rs)
            throws SQLException {

        Utilisateur u = new Utilisateur();
        u.setId(rs.getInt("id"));
        u.setNom(rs.getString("nom"));
        u.setPrenom(rs.getString("prenom"));
        u.setEmail(rs.getString("email"));
        u.setMotDePasse(rs.getString("mot_de_passe"));
        u.setRole(rs.getString("role"));
        u.setActif(rs.getBoolean("actif"));

        Timestamp dateCreation = rs.getTimestamp("date_creation");
        if (dateCreation != null) {
            u.setDateCreation(dateCreation.toLocalDateTime());
        }

        Timestamp derniereConnexion = rs.getTimestamp("derniere_connexion");
        if (derniereConnexion != null) {
            u.setDerniereConnexion(derniereConnexion.toLocalDateTime());
        }

        return u;
    }
}