package cm.cesb.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Presence {

    private int id;
    private int eleveId;
    private String eleveNom;
    private String elevePrenom;
    private String eleveMatricule;
    private String eleveClasse;
    private LocalDate datePresence;
    private String statut;
    private int minutesRetard;
    private String motif;
    private boolean justifie;
    private String decisionDisciplinaire;
    private String noteAdmin;
    private int enregistrePar;
    private LocalDateTime dateEnregistrement;

    // ── Constructeurs ──────────────────────────────────────────────

    public Presence() {}

    // ── Méthodes utilitaires ───────────────────────────────────────

    public String getEleveNomComplet() {
        return elevePrenom + " " + eleveNom;
    }

    public boolean isPresent() {
        return "PRESENT".equals(this.statut);
    }

    public boolean isAbsent() {
        return "ABSENT".equals(this.statut);
    }

    public boolean isRetard() {
        return "RETARD".equals(this.statut);
    }

    // ── Getters et Setters ─────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEleveId() { return eleveId; }
    public void setEleveId(int eleveId) { this.eleveId = eleveId; }

    public String getEleveNom() { return eleveNom; }
    public void setEleveNom(String eleveNom) { this.eleveNom = eleveNom; }

    public String getElevePrenom() { return elevePrenom; }
    public void setElevePrenom(String elevePrenom) {
        this.elevePrenom = elevePrenom;
    }

    public String getEleveMatricule() { return eleveMatricule; }
    public void setEleveMatricule(String eleveMatricule) {
        this.eleveMatricule = eleveMatricule;
    }

    public String getEleveClasse() { return eleveClasse; }
    public void setEleveClasse(String eleveClasse) {
        this.eleveClasse = eleveClasse;
    }

    public LocalDate getDatePresence() { return datePresence; }
    public void setDatePresence(LocalDate datePresence) {
        this.datePresence = datePresence;
    }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public int getMinutesRetard() { return minutesRetard; }
    public void setMinutesRetard(int minutesRetard) {
        this.minutesRetard = minutesRetard;
    }

    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }

    public boolean isJustifie() { return justifie; }
    public void setJustifie(boolean justifie) { this.justifie = justifie; }

    public String getDecisionDisciplinaire() { return decisionDisciplinaire; }
    public void setDecisionDisciplinaire(String decisionDisciplinaire) {
        this.decisionDisciplinaire = decisionDisciplinaire;
    }

    public String getNoteAdmin() { return noteAdmin; }
    public void setNoteAdmin(String noteAdmin) { this.noteAdmin = noteAdmin; }

    public int getEnregistrePar() { return enregistrePar; }
    public void setEnregistrePar(int enregistrePar) {
        this.enregistrePar = enregistrePar;
    }

    public LocalDateTime getDateEnregistrement() { return dateEnregistrement; }
    public void setDateEnregistrement(LocalDateTime dateEnregistrement) {
        this.dateEnregistrement = dateEnregistrement;
    }
}