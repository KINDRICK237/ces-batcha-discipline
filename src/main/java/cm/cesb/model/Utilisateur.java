package cm.cesb.model;

import java.time.LocalDateTime;

public class Utilisateur {

    private int id;
    private String nom;
    private String prenom;
    private String email;
    private String motDePasse;
    private String role;
    private boolean actif;
    private LocalDateTime dateCreation;
    private LocalDateTime derniereConnexion;

    // ── Constructeurs ──────────────────────────────────────────────

    public Utilisateur() {}

    public Utilisateur(int id, String nom, String prenom,
                       String email, String role, boolean actif) {
        this.id     = id;
        this.nom    = nom;
        this.prenom = prenom;
        this.email  = email;
        this.role   = role;
        this.actif  = actif;
    }

    // ── Méthodes utilitaires ───────────────────────────────────────

    public String getNomComplet() {
        return prenom + " " + nom;
    }

    public boolean isAdmin() {
        return "ADMIN".equals(this.role);
    }

    public boolean isEnseignant() {
        return "ENSEIGNANT".equals(this.role);
    }

    // ── Getters et Setters ─────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getMotDePasse() { return motDePasse; }
    public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }

    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }

    public LocalDateTime getDerniereConnexion() { return derniereConnexion; }
    public void setDerniereConnexion(LocalDateTime derniereConnexion) {
        this.derniereConnexion = derniereConnexion;
    }
}