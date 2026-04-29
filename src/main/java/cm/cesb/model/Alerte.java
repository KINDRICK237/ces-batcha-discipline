package cm.cesb.model;

import java.time.LocalDateTime;

public class Alerte {

    private int id;
    private int eleveId;
    private String eleveNom;
    private String elevePrenom;
    private String eleveMatricule;
    private String eleveClasse;
    private String typeAlerte;
    private String message;
    private boolean lue;
    private LocalDateTime dateAlerte;

    // ── Constructeurs ──────────────────────────────────────────────

    public Alerte() {}

    // ── Méthodes utilitaires ───────────────────────────────────────

    public String getNomComplet() {
        return elevePrenom + " " + eleveNom;
    }

    public String getEleveNomComplet() {
        return elevePrenom + " " + eleveNom;
    }

    public String getTypeAlerteLibelle() {
        if (typeAlerte == null) return "";
        switch (typeAlerte) {
            case "ABSENCES_EXCESSIVES": return "Absences excessives";
            case "RETARDS_REPETITIFS":  return "Retards répétitifs";
            case "SANCTIONS_MULTIPLES": return "Sanctions multiples";
            default: return typeAlerte;
        }
    }

    public String getCouleur() {
        if (typeAlerte == null) return "#78909c";
        switch (typeAlerte) {
            case "ABSENCES_EXCESSIVES": return "#e53935";
            case "RETARDS_REPETITIFS":  return "#f57c00";
            case "SANCTIONS_MULTIPLES": return "#7b1fa2";
            default: return "#78909c";
        }
    }

    public String getIcone() {
        if (typeAlerte == null) return "⚠️";
        switch (typeAlerte) {
            case "ABSENCES_EXCESSIVES": return "❌";
            case "RETARDS_REPETITIFS":  return "⏰";
            case "SANCTIONS_MULTIPLES": return "⚖️";
            default: return "⚠️";
        }
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

    public String getTypeAlerte() { return typeAlerte; }
    public void setTypeAlerte(String typeAlerte) {
        this.typeAlerte = typeAlerte;
    }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public boolean isLue() { return lue; }
    public void setLue(boolean lue) { this.lue = lue; }

    public LocalDateTime getDateAlerte() { return dateAlerte; }
    public void setDateAlerte(LocalDateTime dateAlerte) {
        this.dateAlerte = dateAlerte;
    }
}