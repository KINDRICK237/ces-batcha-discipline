package cm.cesb.model;

import java.time.LocalDate;

public class Eleve {

    private int id;
    private String matricule;
    private String nom;
    private String prenom;
    private LocalDate dateNaissance;
    private String genre;
    private int classeId;
    private String classeNom;
    private String telephoneParent;
    private String nomParent;
    private String adresse;
    private String statut;
    private LocalDate dateInscription;

    // ── Constructeurs ──────────────────────────────────────────────

    public Eleve() {}

    // ── Méthodes utilitaires ───────────────────────────────────────

    public String getNomComplet() {
        return prenom + " " + nom;
    }

    public boolean isActif() {
        return "ACTIF".equals(this.statut);
    }

    // ── Getters et Setters ─────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getMatricule() { return matricule; }
    public void setMatricule(String matricule) { this.matricule = matricule; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public LocalDate getDateNaissance() { return dateNaissance; }
    public void setDateNaissance(LocalDate dateNaissance) {
        this.dateNaissance = dateNaissance;
    }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public int getClasseId() { return classeId; }
    public void setClasseId(int classeId) { this.classeId = classeId; }

    public String getClasseNom() { return classeNom; }
    public void setClasseNom(String classeNom) { this.classeNom = classeNom; }

    public String getTelephoneParent() { return telephoneParent; }
    public void setTelephoneParent(String telephoneParent) {
        this.telephoneParent = telephoneParent;
    }

    public String getNomParent() { return nomParent; }
    public void setNomParent(String nomParent) { this.nomParent = nomParent; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public LocalDate getDateInscription() { return dateInscription; }
    public void setDateInscription(LocalDate dateInscription) {
        this.dateInscription = dateInscription;
    }
}