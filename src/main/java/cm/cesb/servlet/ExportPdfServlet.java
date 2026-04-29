package cm.cesb.servlet;

import cm.cesb.dao.ClasseDAO;
import cm.cesb.dao.EleveDAO;
import cm.cesb.dao.PresenceDAO;
import cm.cesb.model.Classe;
import cm.cesb.model.Eleve;
import cm.cesb.model.Presence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

@WebServlet("/exportPdf")
public class ExportPdfServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final EleveDAO    eleveDAO    = new EleveDAO();
    private final PresenceDAO presenceDAO = new PresenceDAO();
    private final ClasseDAO   classeDAO   = new ClasseDAO();

    private static final BaseColor BLEU_FONCE = new BaseColor(26, 60, 94);
    private static final BaseColor BLEU_CLAIR = new BaseColor(227, 242, 253);
    private static final BaseColor VERT       = new BaseColor(46, 125, 50);
    private static final BaseColor ROUGE      = new BaseColor(229, 57, 53);
    private static final BaseColor ORANGE     = new BaseColor(245, 124, 0);
    private static final BaseColor GRIS_CLAIR = new BaseColor(245, 247, 250);

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null
                || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("login");
            return;
        }

        String type = request.getParameter("type");

        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            if ("eleve".equals(type)) {
                exporterRapportEleve(request, response, baos);
            } else if ("classe".equals(type)) {
                exporterRapportClasse(request, response, baos);
            } else if ("global".equals(type)) {
                exporterRapportGlobal(request, response, baos);
            }

            byte[] pdfBytes = baos.toByteArray();

            if (pdfBytes.length == 0) {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println(
                    "<h3>ERREUR : PDF vide genere !</h3>"
                    + "<p>Type : " + type + "</p>"
                    + "<p>eleveId : "
                    + request.getParameter("eleveId") + "</p>"
                    + "<p>classeId : "
                    + request.getParameter("classeId") + "</p>");
                return;
            }

            response.setContentLength(pdfBytes.length);
            response.getOutputStream().write(pdfBytes);
            response.getOutputStream().flush();

        } catch (Exception e) {
            e.printStackTrace();
            response.reset();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println(
                "<h2>ERREUR PDF :</h2>"
                + "<p><b>" + e.getClass().getName() + "</b></p>"
                + "<p>" + e.getMessage() + "</p>"
                + "<pre>");
            for (StackTraceElement ste : e.getStackTrace()) {
                response.getWriter().println(ste.toString());
            }
            response.getWriter().println("</pre>");
        }
    }

    // ── Export rapport élève ───────────────────────────────────────
    private void exporterRapportEleve(HttpServletRequest request,
            HttpServletResponse response,
            ByteArrayOutputStream baos) throws Exception {

        int eleveId = Integer.parseInt(
                request.getParameter("eleveId").trim());
        Eleve eleve = eleveDAO.trouverParId(eleveId);
        List<Presence> presences =
                presenceDAO.listerParEleve(eleveId);

        int nbPresents = 0, nbAbsents = 0,
            nbRetards = 0, totalMin = 0;
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
            ? Math.round((nbPresents * 100.0 / total) * 10.0) / 10.0
            : 0;

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"rapport_"
            + eleve.getMatricule() + ".pdf\"");

        Document doc = new Document(PageSize.A4, 40, 40, 50, 50);
        PdfWriter.getInstance(doc, baos);
        doc.open();

        ajouterEnteteOfficiel(doc);

        Font fontTitre = new Font(Font.FontFamily.HELVETICA,
                14, Font.BOLD, BLEU_FONCE);
        Paragraph titre = new Paragraph(
                "RAPPORT D'ASSIDUITE - ELEVE\n", fontTitre);
        titre.setAlignment(Element.ALIGN_CENTER);
        titre.setSpacingBefore(15);
        doc.add(titre);

        Font fontSousTitre = new Font(Font.FontFamily.HELVETICA,
                10, Font.NORMAL, BaseColor.GRAY);
        Paragraph sousTitre = new Paragraph(
                "Annee scolaire 2024-2025\n\n", fontSousTitre);
        sousTitre.setAlignment(Element.ALIGN_CENTER);
        doc.add(sousTitre);

        PdfPTable tableInfo = new PdfPTable(2);
        tableInfo.setWidthPercentage(100);
        tableInfo.setSpacingBefore(5);
        tableInfo.setSpacingAfter(10);
        ajouterCelluleInfo(tableInfo, "Matricule",
                eleve.getMatricule());
        ajouterCelluleInfo(tableInfo, "Nom complet",
                eleve.getNomComplet());
        ajouterCelluleInfo(tableInfo, "Classe",
                eleve.getClasseNom());
        ajouterCelluleInfo(tableInfo, "Genre",
                "M".equals(eleve.getGenre())
                ? "Masculin" : "Feminin");
        ajouterCelluleInfo(tableInfo, "Statut",
                eleve.getStatut());
        ajouterCelluleInfo(tableInfo, "Parent",
                eleve.getNomParent() != null
                ? eleve.getNomParent() : "-");
        doc.add(tableInfo);

        PdfPTable tableStat = new PdfPTable(5);
        tableStat.setWidthPercentage(100);
        tableStat.setSpacingBefore(10);
        tableStat.setSpacingAfter(10);
        ajouterCelluleStat(tableStat, "Total jours",
                String.valueOf(total), BLEU_CLAIR, BLEU_FONCE);
        ajouterCelluleStat(tableStat, "Presences",
                String.valueOf(nbPresents),
                new BaseColor(232, 245, 233), VERT);
        ajouterCelluleStat(tableStat, "Absences",
                String.valueOf(nbAbsents),
                new BaseColor(252, 228, 236), ROUGE);
        ajouterCelluleStat(tableStat, "Retards",
                String.valueOf(nbRetards),
                new BaseColor(255, 243, 224), ORANGE);
        ajouterCelluleStat(tableStat, "Taux presence",
                taux + "%", BLEU_CLAIR, BLEU_FONCE);
        doc.add(tableStat);

        Font fontSection = new Font(Font.FontFamily.HELVETICA,
                11, Font.BOLD, BLEU_FONCE);
        doc.add(new Paragraph(
                "Historique des presences\n", fontSection));

        PdfPTable tableHisto = new PdfPTable(5);
        tableHisto.setWidthPercentage(100);
        tableHisto.setSpacingBefore(5);
        tableHisto.setWidths(
                new float[]{2f, 2f, 1.5f, 2f, 2.5f});

        String[] entetes = {"Date", "Statut", "Min. retard",
                             "Motif", "Decision"};
        for (String e : entetes) {
            PdfPCell cell = new PdfPCell(new Phrase(e,
                new Font(Font.FontFamily.HELVETICA, 9,
                    Font.BOLD, BaseColor.WHITE)));
            cell.setBackgroundColor(BLEU_FONCE);
            cell.setPadding(6);
            tableHisto.addCell(cell);
        }

        boolean pair = false;
        for (Presence p : presences) {
            BaseColor bg = pair ? GRIS_CLAIR : BaseColor.WHITE;
            ajouterCelluleHisto(tableHisto,
                p.getDatePresence() != null
                ? p.getDatePresence().toString() : "-", bg);
            ajouterCelluleHisto(tableHisto,
                p.getStatut() != null
                ? p.getStatut() : "-", bg);
            ajouterCelluleHisto(tableHisto,
                p.getMinutesRetard() > 0
                ? p.getMinutesRetard() + " min" : "-", bg);
            ajouterCelluleHisto(tableHisto,
                p.getMotif() != null
                ? p.getMotif() : "-", bg);
            ajouterCelluleHisto(tableHisto,
                p.getDecisionDisciplinaire() != null
                && !"AUCUNE".equals(p.getDecisionDisciplinaire())
                ? p.getDecisionDisciplinaire().replace("_", " ")
                : "-", bg);
            pair = !pair;
        }
        doc.add(tableHisto);
        doc.close();
    }

    // ── Export rapport classe ──────────────────────────────────────
    private void exporterRapportClasse(HttpServletRequest request,
            HttpServletResponse response,
            ByteArrayOutputStream baos) throws Exception {

        int classeId = Integer.parseInt(
                request.getParameter("classeId").trim());
        List<Eleve> eleves =
                eleveDAO.listerParClasse(classeId);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"rapport_classe_"
            + classeId + ".pdf\"");

        Document doc = new Document(PageSize.A4.rotate(),
                40, 40, 50, 50);
        PdfWriter.getInstance(doc, baos);
        doc.open();

        ajouterEnteteOfficiel(doc);

        Font fontTitre = new Font(Font.FontFamily.HELVETICA,
                14, Font.BOLD, BLEU_FONCE);
        Paragraph titre = new Paragraph(
                "RAPPORT GLOBAL - CLASSE\n", fontTitre);
        titre.setAlignment(Element.ALIGN_CENTER);
        titre.setSpacingBefore(15);
        doc.add(titre);

        Font fontSousTitre = new Font(Font.FontFamily.HELVETICA,
                10, Font.NORMAL, BaseColor.GRAY);
        Paragraph sousTitre = new Paragraph(
                "Annee scolaire 2024-2025\n\n", fontSousTitre);
        sousTitre.setAlignment(Element.ALIGN_CENTER);
        doc.add(sousTitre);

        PdfPTable table = new PdfPTable(8);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10);
        table.setWidths(new float[]{
                0.5f, 2f, 3f, 1f, 1.5f, 1.5f, 1.5f, 2f});

        String[] entetes = {"#", "Matricule", "Nom complet",
                "Genre", "Presences", "Absences",
                "Retards", "Taux"};
        for (String e : entetes) {
            PdfPCell cell = new PdfPCell(new Phrase(e,
                new Font(Font.FontFamily.HELVETICA, 9,
                    Font.BOLD, BaseColor.WHITE)));
            cell.setBackgroundColor(BLEU_FONCE);
            cell.setPadding(6);
            table.addCell(cell);
        }

        int rang = 1;
        boolean pair = false;
        for (Eleve e : eleves) {
            List<Presence> pres =
                    presenceDAO.listerParEleve(e.getId());
            int p = 0, a = 0, r = 0;
            for (Presence pr : pres) {
                if ("PRESENT".equals(pr.getStatut())) p++;
                else if ("ABSENT".equals(pr.getStatut())) a++;
                else if ("RETARD".equals(pr.getStatut())) r++;
            }
            int tot = p + a + r;
            double taux = tot > 0
                ? Math.round((p * 100.0 / tot) * 10.0) / 10.0
                : 0;

            BaseColor bg = pair ? GRIS_CLAIR : BaseColor.WHITE;
            ajouterCelluleHisto(table,
                    String.valueOf(rang++), bg);
            ajouterCelluleHisto(table, e.getMatricule(), bg);
            ajouterCelluleHisto(table, e.getNomComplet(), bg);
            ajouterCelluleHisto(table,
                    "M".equals(e.getGenre()) ? "M" : "F", bg);
            ajouterCelluleHisto(table, String.valueOf(p), bg);
            ajouterCelluleHisto(table, String.valueOf(a), bg);
            ajouterCelluleHisto(table, String.valueOf(r), bg);
            ajouterCelluleHisto(table, taux + "%", bg);
            pair = !pair;
        }
        doc.add(table);
        doc.close();
    }

    // ── Export rapport global ──────────────────────────────────────
    private void exporterRapportGlobal(HttpServletRequest request,
            HttpServletResponse response,
            ByteArrayOutputStream baos) throws Exception {

        String periode = request.getParameter("periode");
        if (periode == null) periode = "hebdomadaire";

        List<Classe> classes = classeDAO.listerTous();

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"rapport_global_"
            + periode + ".pdf\"");

        Document doc = new Document(PageSize.A4, 40, 40, 50, 50);
        PdfWriter.getInstance(doc, baos);
        doc.open();

        ajouterEnteteOfficiel(doc);

        Font fontTitre = new Font(Font.FontFamily.HELVETICA,
                14, Font.BOLD, BLEU_FONCE);
        Paragraph titre = new Paragraph(
                "RAPPORT GLOBAL - "
                + periode.toUpperCase() + "\n", fontTitre);
        titre.setAlignment(Element.ALIGN_CENTER);
        titre.setSpacingBefore(15);
        doc.add(titre);

        Font fontSousTitre = new Font(Font.FontFamily.HELVETICA,
                10, Font.NORMAL, BaseColor.GRAY);
        Paragraph sousTitre = new Paragraph(
                "Annee scolaire 2024-2025\n\n", fontSousTitre);
        sousTitre.setAlignment(Element.ALIGN_CENTER);
        doc.add(sousTitre);

        PdfPTable table = new PdfPTable(7);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10);
        table.setWidths(new float[]{
                0.5f, 2f, 2f, 1.5f, 1.5f, 1.5f, 2f});

        String[] entetes = {"#", "Classe", "Niveau",
                "Presences", "Absences", "Retards", "Taux"};
        for (String e : entetes) {
            PdfPCell cell = new PdfPCell(new Phrase(e,
                new Font(Font.FontFamily.HELVETICA, 9,
                    Font.BOLD, BaseColor.WHITE)));
            cell.setBackgroundColor(BLEU_FONCE);
            cell.setPadding(6);
            table.addCell(cell);
        }

        int rang = 1;
        boolean pair = false;
        for (Classe c : classes) {
            List<Eleve> eleves =
                    eleveDAO.listerParClasse(c.getId());
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
                ? Math.round((totalP * 100.0 / tot) * 10.0) / 10.0
                : 0;

            BaseColor bg = pair ? GRIS_CLAIR : BaseColor.WHITE;
            ajouterCelluleHisto(table,
                    String.valueOf(rang++), bg);
            ajouterCelluleHisto(table, c.getNom(), bg);
            ajouterCelluleHisto(table, c.getNiveau(), bg);
            ajouterCelluleHisto(table,
                    String.valueOf(totalP), bg);
            ajouterCelluleHisto(table,
                    String.valueOf(totalA), bg);
            ajouterCelluleHisto(table,
                    String.valueOf(totalR), bg);
            ajouterCelluleHisto(table, taux + "%", bg);
            pair = !pair;
        }
        doc.add(table);
        doc.close();
    }

    // ── En-tête officiel ───────────────────────────────────────────
    private void ajouterEnteteOfficiel(Document doc)
            throws Exception {

        Font fontEntete = new Font(Font.FontFamily.TIMES_ROMAN,
                8, Font.BOLD, BaseColor.BLACK);

        PdfPTable tableEntete = new PdfPTable(3);
        tableEntete.setWidthPercentage(100);
        tableEntete.setWidths(new float[]{2f, 1f, 2f});

        PdfPCell gauche = new PdfPCell();
        gauche.setBorder(Rectangle.NO_BORDER);
        gauche.addElement(new Paragraph(
            "MINISTERE DES ENSEIGNEMENTS SECONDAIRES\n" +
            "************\n" +
            "DELEGATION REGIONALE DE L'OUEST\n" +
            "************\n" +
            "DELEGATION DEPARTEMENTALE DU HAUT-NKAM\n" +
            "************\n" +
            "CES DE BATCHA; PO-BOX :-PHONE :\n" +
            "************\n" +
            "N D'IMMATRICULATION : 4EH1GSFD101775109",
            fontEntete));
        tableEntete.addCell(gauche);

        PdfPCell centre = new PdfPCell();
        centre.setBorder(Rectangle.NO_BORDER);
        centre.setHorizontalAlignment(Element.ALIGN_CENTER);
        centre.setVerticalAlignment(Element.ALIGN_MIDDLE);
        try {
            String logoPath = getServletContext()
                    .getRealPath("/images/logo.png");
            if (logoPath != null) {
                java.io.File logoFile =
                        new java.io.File(logoPath);
                if (logoFile.exists()) {
                    Image logo = Image.getInstance(logoPath);
                    logo.scaleToFit(70, 70);
                    centre.addElement(logo);
                } else {
                    centre.addElement(new Paragraph(
                            "CES BATCHA", fontEntete));
                }
            }
        } catch (Exception e) {
            centre.addElement(new Paragraph(
                    "CES BATCHA", fontEntete));
        }
        tableEntete.addCell(centre);

        PdfPCell droite = new PdfPCell();
        droite.setBorder(Rectangle.NO_BORDER);
        droite.setHorizontalAlignment(Element.ALIGN_RIGHT);
        droite.addElement(new Paragraph(
            "MINISTRY OF SECONDARY EDUCATION\n" +
            "************\n" +
            "WEST REGIONAL DELEGATION\n" +
            "************\n" +
            "UPPER NKAM DIVISIONAL DELEGATION\n" +
            "************\n" +
            "GSS BATCHA; PO-BOX :-PHONE :\n" +
            "************\n" +
            "N D'IMMATRICULATION : 4EH1GSFD101775109",
            fontEntete));
        tableEntete.addCell(droite);

        doc.add(tableEntete);
        doc.add(new Paragraph(" "));
    }

    // ── Méthodes utilitaires ───────────────────────────────────────
    private void ajouterCelluleInfo(PdfPTable table,
            String label, String valeur) {
        Font fontLabel = new Font(Font.FontFamily.HELVETICA,
                9, Font.BOLD, BaseColor.GRAY);
        Font fontValeur = new Font(Font.FontFamily.HELVETICA,
                10, Font.BOLD, BLEU_FONCE);
        PdfPCell cellLabel = new PdfPCell(
                new Phrase(label, fontLabel));
        cellLabel.setBackgroundColor(GRIS_CLAIR);
        cellLabel.setPadding(6);
        table.addCell(cellLabel);
        PdfPCell cellValeur = new PdfPCell(
                new Phrase(valeur, fontValeur));
        cellValeur.setPadding(6);
        table.addCell(cellValeur);
    }

    private void ajouterCelluleStat(PdfPTable table,
            String label, String valeur,
            BaseColor bg, BaseColor couleurTexte) {
        Font fontVal = new Font(Font.FontFamily.HELVETICA,
                16, Font.BOLD, couleurTexte);
        Font fontLab = new Font(Font.FontFamily.HELVETICA,
                8, Font.NORMAL, BaseColor.GRAY);
        PdfPCell cell = new PdfPCell();
        cell.setBackgroundColor(bg);
        cell.setPadding(10);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.addElement(new Paragraph(valeur, fontVal));
        cell.addElement(new Paragraph(label, fontLab));
        table.addCell(cell);
    }

    private void ajouterCelluleHisto(PdfPTable table,
            String valeur, BaseColor bg) {
        Font font = new Font(Font.FontFamily.HELVETICA,
                8, Font.NORMAL, BaseColor.DARK_GRAY);
        PdfPCell cell = new PdfPCell(
                new Phrase(valeur, font));
        cell.setBackgroundColor(bg);
        cell.setPadding(5);
        table.addCell(cell);
    }
}