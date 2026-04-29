package cm.cesb.servlet;

import cm.cesb.dao.ClasseDAO;
import cm.cesb.dao.EleveDAO;
import cm.cesb.dao.PresenceDAO;
import cm.cesb.model.Classe;
import cm.cesb.model.Eleve;
import cm.cesb.model.Presence;
import cm.cesb.model.Utilisateur;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/exportExcel")
public class ExportExcelServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final EleveDAO    eleveDAO    = new EleveDAO();
    private final PresenceDAO presenceDAO = new PresenceDAO();
    private final ClasseDAO   classeDAO   = new ClasseDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("login");
            return;
        }

        String type = request.getParameter("type");

        try {
            if ("eleve".equals(type)) {
                exporterRapportEleve(request, response);
            } else if ("classe".equals(type)) {
                exporterRapportClasse(request, response);
            } else if ("global".equals(type)) {
                exporterRapportGlobal(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERREUR Excel : " + e.getMessage());
        }
    }

    // ── Export rapport élève ───────────────────────────────────────
    private void exporterRapportEleve(HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        int eleveId = Integer.parseInt(
                request.getParameter("eleveId").trim());
        Eleve eleve = eleveDAO.trouverParId(eleveId);
        List<Presence> presences = presenceDAO.listerParEleve(eleveId);

        // Stats
        int nbPresents = 0, nbAbsents = 0, nbRetards = 0, totalMin = 0;
        for (Presence p : presences) {
            if ("PRESENT".equals(p.getStatut())) nbPresents++;
            else if ("ABSENT".equals(p.getStatut())) nbAbsents++;
            else if ("RETARD".equals(p.getStatut())) {
                nbRetards++;
                totalMin += p.getMinutesRetard();
            }
        }
        int total = presences.size();
        double taux = total > 0
            ? Math.round((nbPresents * 100.0 / total) * 10.0) / 10.0 : 0;

        response.setContentType(
                "application/vnd.openxmlformats-officedocument"
                + ".spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"rapport_"
            + eleve.getMatricule() + ".xlsx\"");

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Rapport Eleve");

        // Styles
        CellStyle styleEntete = creerStyleEntete(workbook);
        CellStyle styleTitre  = creerStyleTitre(workbook);
        CellStyle styleLabel  = creerStyleLabel(workbook);
        CellStyle styleValeur = creerStyleValeur(workbook);
        CellStyle styleVert   = creerStyleCouleur(workbook,
                new byte[]{(byte)46,(byte)125,(byte)50});
        CellStyle styleRouge  = creerStyleCouleur(workbook,
                new byte[]{(byte)229,(byte)57,(byte)53});
        CellStyle styleOrange = creerStyleCouleur(workbook,
                new byte[]{(byte)245,(byte)124,(byte)0});

        int ligne = 0;

        // ── En-tête établissement ──────────────────────────────────
        Row rowEtab = sheet.createRow(ligne++);
        Cell cellEtab = rowEtab.createCell(0);
        cellEtab.setCellValue("CES DE BATCHA — SUIVI DISCIPLINAIRE");
        cellEtab.setCellStyle(styleTitre);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

        Row rowAnnee = sheet.createRow(ligne++);
        Cell cellAnnee = rowAnnee.createCell(0);
        cellAnnee.setCellValue("Annee scolaire 2024-2025");
        sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 6));
        ligne++;

        // ── Titre ──────────────────────────────────────────────────
        Row rowTitre = sheet.createRow(ligne++);
        Cell cellTitre = rowTitre.createCell(0);
        cellTitre.setCellValue("RAPPORT D'ASSIDUITE — ELEVE");
        cellTitre.setCellStyle(styleTitre);
        sheet.addMergedRegion(new CellRangeAddress(
                ligne-1, ligne-1, 0, 6));
        ligne++;

        // ── Infos élève ────────────────────────────────────────────
        ajouterLigneInfo(sheet, ligne++, styleLabel, styleValeur,
                "Matricule", eleve.getMatricule());
        ajouterLigneInfo(sheet, ligne++, styleLabel, styleValeur,
                "Nom complet", eleve.getNomComplet());
        ajouterLigneInfo(sheet, ligne++, styleLabel, styleValeur,
                "Classe", eleve.getClasseNom());
        ajouterLigneInfo(sheet, ligne++, styleLabel, styleValeur,
                "Genre", "M".equals(eleve.getGenre())
                ? "Masculin" : "Feminin");
        ajouterLigneInfo(sheet, ligne++, styleLabel, styleValeur,
                "Statut", eleve.getStatut());
        ligne++;

        // ── Statistiques ───────────────────────────────────────────
        Row rowStatLabel = sheet.createRow(ligne++);
        String[] statsLabels = {"Total jours", "Presences",
                "Absences", "Retards", "Min. retard", "Taux"};
        for (int i = 0; i < statsLabels.length; i++) {
            Cell c = rowStatLabel.createCell(i);
            c.setCellValue(statsLabels[i]);
            c.setCellStyle(styleEntete);
        }

        Row rowStatVal = sheet.createRow(ligne++);
        rowStatVal.createCell(0).setCellValue(total);
        Cell cPres = rowStatVal.createCell(1);
        cPres.setCellValue(nbPresents);
        cPres.setCellStyle(styleVert);
        Cell cAbs = rowStatVal.createCell(2);
        cAbs.setCellValue(nbAbsents);
        cAbs.setCellStyle(styleRouge);
        Cell cRet = rowStatVal.createCell(3);
        cRet.setCellValue(nbRetards);
        cRet.setCellStyle(styleOrange);
        rowStatVal.createCell(4).setCellValue(totalMin + " min");
        rowStatVal.createCell(5).setCellValue(taux + "%");
        ligne++;

        // ── Historique ─────────────────────────────────────────────
        Row rowHistoLabel = sheet.createRow(ligne++);
        String[] histoLabels = {"Date", "Statut", "Min. retard",
                "Motif", "Justifie", "Decision", "Note"};
        for (int i = 0; i < histoLabels.length; i++) {
            Cell c = rowHistoLabel.createCell(i);
            c.setCellValue(histoLabels[i]);
            c.setCellStyle(styleEntete);
        }

        for (Presence p : presences) {
            Row row = sheet.createRow(ligne++);
            row.createCell(0).setCellValue(
                p.getDatePresence() != null
                ? p.getDatePresence().toString() : "-");
            row.createCell(1).setCellValue(
                p.getStatut() != null ? p.getStatut() : "-");
            row.createCell(2).setCellValue(p.getMinutesRetard());
            row.createCell(3).setCellValue(
                p.getMotif() != null ? p.getMotif() : "-");
            row.createCell(4).setCellValue(
                p.isJustifie() ? "Oui" : "Non");
            row.createCell(5).setCellValue(
                p.getDecisionDisciplinaire() != null
                && !"AUCUNE".equals(p.getDecisionDisciplinaire())
                ? p.getDecisionDisciplinaire().replace("_", " ")
                : "-");
            row.createCell(6).setCellValue(
                p.getNoteAdmin() != null ? p.getNoteAdmin() : "-");
        }

        // Largeur des colonnes
        for (int i = 0; i < 7; i++) {
            sheet.autoSizeColumn(i);
        }

        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // ── Export rapport classe ──────────────────────────────────────
    private void exporterRapportClasse(HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        int classeId = Integer.parseInt(
                request.getParameter("classeId").trim());
        Classe classe = classeDAO.trouverParId(classeId);
        List<Eleve> eleves = eleveDAO.listerParClasse(classeId);

        response.setContentType(
                "application/vnd.openxmlformats-officedocument"
                + ".spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"rapport_classe_"
            + classe.getNom().replace(" ", "_") + ".xlsx\"");

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Rapport Classe");

        CellStyle styleEntete = creerStyleEntete(workbook);
        CellStyle styleTitre  = creerStyleTitre(workbook);

        int ligne = 0;

        Row rowEtab = sheet.createRow(ligne++);
        Cell cellEtab = rowEtab.createCell(0);
        cellEtab.setCellValue("CES DE BATCHA — RAPPORT CLASSE : "
                + classe.getNom());
        cellEtab.setCellStyle(styleTitre);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 7));
        ligne++;

        // En-têtes tableau
        Row rowEntete = sheet.createRow(ligne++);
        String[] labels = {"#", "Matricule", "Nom complet",
                "Genre", "Presences", "Absences", "Retards", "Taux"};
        for (int i = 0; i < labels.length; i++) {
            Cell c = rowEntete.createCell(i);
            c.setCellValue(labels[i]);
            c.setCellStyle(styleEntete);
        }

        int rang = 1;
        for (Eleve e : eleves) {
            List<Presence> pres = presenceDAO.listerParEleve(e.getId());
            int p = 0, a = 0, r = 0;
            for (Presence pr : pres) {
                if ("PRESENT".equals(pr.getStatut())) p++;
                else if ("ABSENT".equals(pr.getStatut())) a++;
                else if ("RETARD".equals(pr.getStatut())) r++;
            }
            int tot = p + a + r;
            double taux = tot > 0
                ? Math.round((p * 100.0 / tot) * 10.0) / 10.0 : 0;

            Row row = sheet.createRow(ligne++);
            row.createCell(0).setCellValue(rang++);
            row.createCell(1).setCellValue(e.getMatricule());
            row.createCell(2).setCellValue(e.getNomComplet());
            row.createCell(3).setCellValue(
                    "M".equals(e.getGenre()) ? "M" : "F");
            row.createCell(4).setCellValue(p);
            row.createCell(5).setCellValue(a);
            row.createCell(6).setCellValue(r);
            row.createCell(7).setCellValue(taux + "%");
        }

        for (int i = 0; i < 8; i++) sheet.autoSizeColumn(i);

        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // ── Export rapport global ──────────────────────────────────────
    private void exporterRapportGlobal(HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String periode = request.getParameter("periode");
        if (periode == null) periode = "hebdomadaire";

        List<Classe> classes = classeDAO.listerTous();

        response.setContentType(
                "application/vnd.openxmlformats-officedocument"
                + ".spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"rapport_global_"
            + periode + ".xlsx\"");

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Rapport Global");

        CellStyle styleEntete = creerStyleEntete(workbook);
        CellStyle styleTitre  = creerStyleTitre(workbook);

        int ligne = 0;

        Row rowTitre = sheet.createRow(ligne++);
        Cell cellTitre = rowTitre.createCell(0);
        cellTitre.setCellValue("CES DE BATCHA — RAPPORT GLOBAL "
                + periode.toUpperCase());
        cellTitre.setCellStyle(styleTitre);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));
        ligne++;

        Row rowEntete = sheet.createRow(ligne++);
        String[] labels = {"#", "Classe", "Niveau",
                "Presences", "Absences", "Retards", "Taux"};
        for (int i = 0; i < labels.length; i++) {
            Cell c = rowEntete.createCell(i);
            c.setCellValue(labels[i]);
            c.setCellStyle(styleEntete);
        }

        int rang = 1;
        for (Classe c : classes) {
            List<Eleve> eleves = eleveDAO.listerParClasse(c.getId());
            int totalP = 0, totalA = 0, totalR = 0;
            for (Eleve e : eleves) {
                List<Presence> pres =
                        presenceDAO.listerParEleve(e.getId());
                for (Presence pr : pres) {
                    if ("PRESENT".equals(pr.getStatut())) totalP++;
                    else if ("ABSENT".equals(pr.getStatut())) totalA++;
                    else if ("RETARD".equals(pr.getStatut())) totalR++;
                }
            }
            int tot = totalP + totalA + totalR;
            double taux = tot > 0
                ? Math.round((totalP * 100.0 / tot) * 10.0) / 10.0 : 0;

            Row row = sheet.createRow(ligne++);
            row.createCell(0).setCellValue(rang++);
            row.createCell(1).setCellValue(c.getNom());
            row.createCell(2).setCellValue(c.getNiveau());
            row.createCell(3).setCellValue(totalP);
            row.createCell(4).setCellValue(totalA);
            row.createCell(5).setCellValue(totalR);
            row.createCell(6).setCellValue(taux + "%");
        }

        for (int i = 0; i < 7; i++) sheet.autoSizeColumn(i);

        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // ── Styles ────────────────────────────────────────────────────
    private CellStyle creerStyleEntete(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        return style;
    }

    private CellStyle creerStyleTitre(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 13);
        font.setColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    private CellStyle creerStyleLabel(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    private CellStyle creerStyleValeur(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        return style;
    }

    private CellStyle creerStyleCouleur(Workbook wb, byte[] rgb) {
        CellStyle style = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        style.setFont(font);
        return style;
    }

    private void ajouterLigneInfo(Sheet sheet, int numLigne,
            CellStyle styleLabel, CellStyle styleValeur,
            String label, String valeur) {
        Row row = sheet.createRow(numLigne);
        Cell cellLabel = row.createCell(0);
        cellLabel.setCellValue(label);
        cellLabel.setCellStyle(styleLabel);
        Cell cellValeur = row.createCell(1);
        cellValeur.setCellValue(valeur);
        cellValeur.setCellStyle(styleValeur);
    }
}