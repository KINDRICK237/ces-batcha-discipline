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

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.time.DayOfWeek;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/rapports")
public class RapportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final EleveDAO    eleveDAO    = new EleveDAO();
    private final ClasseDAO   classeDAO   = new ClasseDAO();
    private final PresenceDAO presenceDAO = new PresenceDAO();

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
        if (type == null) type = "menu";

        try {
            switch (type) {
                case "eleve":
                    traiterRapportEleve(request, response);
                    break;
                case "classe":
                    traiterRapportClasse(request, response);
                    break;
                case "global":
                    traiterRapportGlobal(request, response);
                    break;
                default:
                    List<Eleve> eleves   = eleveDAO.listerTous();
                    List<Classe> classes = classeDAO.listerTous();
                    request.setAttribute("eleves", eleves);
                    request.setAttribute("classes", classes);
                    request.getRequestDispatcher("/WEB-INF/jsp/rapports.jsp")
                           .forward(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERREUR : " + e.getMessage());
        }
    }

    // ── Rapport individuel élève ───────────────────────────────────
    private void traiterRapportEleve(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String eleveIdParam = request.getParameter("eleveId");

        if (eleveIdParam != null && !eleveIdParam.isEmpty()) {
            int eleveId = Integer.parseInt(eleveIdParam.trim());
            Eleve eleve = eleveDAO.trouverParId(eleveId);
            List<Presence> presences = presenceDAO.listerParEleve(eleveId);

            int totalJours = presences.size();
            int nbPresents = 0, nbAbsents = 0, nbRetards = 0;
            int totalMinutes = 0, absJustifies = 0, absNonJustifies = 0;

            for (Presence p : presences) {
                if ("PRESENT".equals(p.getStatut())) nbPresents++;
                else if ("ABSENT".equals(p.getStatut())) {
                    nbAbsents++;
                    if (p.isJustifie()) absJustifies++;
                    else absNonJustifies++;
                } else if ("RETARD".equals(p.getStatut())) {
                    nbRetards++;
                    totalMinutes += p.getMinutesRetard();
                }
            }

            double tauxPresence = totalJours > 0
                    ? Math.round((nbPresents * 100.0 / totalJours) * 10.0) / 10.0
                    : 0;

            request.setAttribute("eleve",           eleve);
            request.setAttribute("presences",       presences);
            request.setAttribute("totalJours",      totalJours);
            request.setAttribute("nbPresents",      nbPresents);
            request.setAttribute("nbAbsents",       nbAbsents);
            request.setAttribute("nbRetards",       nbRetards);
            request.setAttribute("totalMinutes",    totalMinutes);
            request.setAttribute("absJustifies",    absJustifies);
            request.setAttribute("absNonJustifies", absNonJustifies);
            request.setAttribute("tauxPresence",    tauxPresence);

            request.getRequestDispatcher("/WEB-INF/jsp/rapportEleve.jsp")
                   .forward(request, response);
        } else {
            afficherMenuRapports(request, response);
        }
    }

    // ── Rapport par classe ─────────────────────────────────────────
    private void traiterRapportClasse(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String classeIdParam = request.getParameter("classeId");

        if (classeIdParam != null && !classeIdParam.isEmpty()) {
            int classeId = Integer.parseInt(classeIdParam.trim());
            Classe classe = classeDAO.trouverParId(classeId);
            List<Eleve> elevesClasse = eleveDAO.listerParClasse(classeId);

            int nbGarcons = 0, nbFilles = 0;
            for (Eleve e : elevesClasse) {
                if ("M".equals(e.getGenre())) nbGarcons++;
                else nbFilles++;
            }

            // Calculer les stats de chaque élève dans le servlet
            List<int[]> statsEleves = new ArrayList<>();
            for (Eleve e : elevesClasse) {
                List<Presence> presEleve =
                        presenceDAO.listerParEleve(e.getId());
                int pres = 0, abs = 0, ret = 0, min = 0;
                for (Presence p : presEleve) {
                    if ("PRESENT".equals(p.getStatut())) pres++;
                    else if ("ABSENT".equals(p.getStatut())) abs++;
                    else if ("RETARD".equals(p.getStatut())) {
                        ret++;
                        min += p.getMinutesRetard();
                    }
                }
                statsEleves.add(new int[]{pres, abs, ret, min});
            }

            request.setAttribute("classe",      classe);
            request.setAttribute("eleves",      elevesClasse);
            request.setAttribute("nbGarcons",   nbGarcons);
            request.setAttribute("nbFilles",    nbFilles);
            request.setAttribute("statsEleves", statsEleves);

            request.getRequestDispatcher("/WEB-INF/jsp/rapportClasse.jsp")
                   .forward(request, response);
        } else {
            afficherMenuRapports(request, response);
        }
    }

    // ── Rapport global (hebdo, mensuel, annuel) ────────────────────
    private void traiterRapportGlobal(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String periode = request.getParameter("periode");
        if (periode == null) periode = "hebdomadaire";

        LocalDate aujourd_hui = LocalDate.now();
        LocalDate debut, fin;

        switch (periode) {
            case "mensuel":
                debut = aujourd_hui.with(TemporalAdjusters.firstDayOfMonth());
                fin   = aujourd_hui.with(TemporalAdjusters.lastDayOfMonth());
                break;
            case "annuel":
                debut = LocalDate.of(aujourd_hui.getYear(), 1, 1);
                fin   = LocalDate.of(aujourd_hui.getYear(), 12, 31);
                break;
            default:
                debut = aujourd_hui.with(DayOfWeek.MONDAY);
                fin   = aujourd_hui.with(DayOfWeek.SUNDAY);
                break;
        }

        int[] statsGlobales  = presenceDAO.statsGlobalesParPeriode(debut, fin);
        List<Classe> classes = classeDAO.listerTous();
        int[][] statsClasses = new int[classes.size()][4];

        for (int i = 0; i < classes.size(); i++) {
            statsClasses[i] = presenceDAO.statsParPeriodeEtClasse(
                    classes.get(i).getId(), debut, fin);
        }

        request.setAttribute("periode",       periode);
        request.setAttribute("debut",         debut.toString());
        request.setAttribute("fin",           fin.toString());
        request.setAttribute("statsGlobales", statsGlobales);
        request.setAttribute("classes",       classes);
        request.setAttribute("statsClasses",  statsClasses);

        request.getRequestDispatcher("/WEB-INF/jsp/rapportGlobal.jsp")
               .forward(request, response);
    }

    // ── Menu rapports ──────────────────────────────────────────────
    private void afficherMenuRapports(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        List<Eleve> eleves   = eleveDAO.listerTous();
        List<Classe> classes = classeDAO.listerTous();
        request.setAttribute("eleves", eleves);
        request.setAttribute("classes", classes);
        request.getRequestDispatcher("/WEB-INF/jsp/rapports.jsp")
               .forward(request, response);
    }
}