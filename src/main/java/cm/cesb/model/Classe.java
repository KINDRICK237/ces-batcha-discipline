package cm.cesb.model;

public class Classe {

    private int id;
    private String nom;
    private String niveau;
    private String anneeScolaire;
    private int enseignantPrincipalId;

    // ── Constructeurs ──────────────────────────────────────────────

    public Classe() {}

    public Classe(int id, String nom, String niveau, String anneeScolaire) {
        this.id            = id;
        this.nom           = nom;
        this.niveau        = niveau;
        this.anneeScolaire = anneeScolaire;
    }

    // ── Getters et Setters ─────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getNiveau() { return niveau; }
    public void setNiveau(String niveau) { this.niveau = niveau; }

    public String getAnneeScolaire() { return anneeScolaire; }
    public void setAnneeScolaire(String anneeScolaire) {
        this.anneeScolaire = anneeScolaire;
    }

    public int getEnseignantPrincipalId() { return enseignantPrincipalId; }
    public void setEnseignantPrincipalId(int enseignantPrincipalId) {
        this.enseignantPrincipalId = enseignantPrincipalId;
    }
}