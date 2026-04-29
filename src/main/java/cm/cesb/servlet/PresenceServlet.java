package cm.cesb.servlet;

import cm.cesb.dao.AlerteDAO;
import cm.cesb.dao.ClasseDAO;
import cm.cesb.dao.PresenceDAO;
import cm.cesb.model.Classe;
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
import java.util.List;

@WebServlet("/presences")
public class PresenceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final PresenceDAO presenceDAO = new PresenceDAO();
    private final ClasseDAO   classeDAO   = new ClasseDAO();
    private final AlerteDAO   alerteDAO   = new AlerteDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("login");
            return;
        }

        try {
            List<Classe> classes = classeDAO.listerTous();
            request.setAttribute("classes", classes);

            String classeIdParam = request.getParameter("classeId");
            String dateParam     = request.getParameter("date");

            if (classeIdParam != null && !classeIdParam.isEmpty()
                    && dateParam != null && !dateParam.isEmpty()) {

                int classeId   = Integer.parseInt(classeIdParam);
                LocalDate date = LocalDate.parse(dateParam);
                Classe classe  = classeDAO.trouverParId(classeId);

                List<Presence> presences =
                        presenceDAO.listerParClasseEtDate(classeId, date);

                request.setAttribute("presences",          presences);
                request.setAttribute("classeSelectionnee", classe);
                request.setAttribute("dateSelectionnee",   dateParam);
                request.setAttribute("classeId",           classeIdParam);
            }

            request.getRequestDispatcher("/WEB-INF/jsp/presences.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERREUR : " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("login");
            return;
        }

        Utilisateur u = (Utilisateur) session.getAttribute("utilisateur");
        if (!u.isAdmin()) {
            response.sendRedirect("presences");
            return;
        }

        try {
            String dateParam     = request.getParameter("date");
            String classeIdParam = request.getParameter("classeId");
            String[] eleveIds    = request.getParameterValues("eleveId");

            if (eleveIds != null) {
                for (String eleveIdStr : eleveIds) {
                    int eleveId = Integer.parseInt(eleveIdStr);

                    String statut = request.getParameter(
                            "statut_" + eleveId);
                    if (statut == null) statut = "PRESENT";

                    String minutesStr = request.getParameter(
                            "minutes_" + eleveId);
                    int minutes = 0;
                    if (minutesStr != null && !minutesStr.isEmpty()) {
                        try { minutes = Integer.parseInt(minutesStr); }
                        catch (NumberFormatException e) { minutes = 0; }
                    }

                    String motif = request.getParameter(
                            "motif_" + eleveId);
                    if (motif == null) motif = "INCONNU";

                    String justifieStr = request.getParameter(
                            "justifie_" + eleveId);
                    boolean justifie = "on".equals(justifieStr);

                    String decision = request.getParameter(
                            "decision_" + eleveId);
                    if (decision == null) decision = "AUCUNE";

                    String note = request.getParameter(
                            "note_" + eleveId);

                    Presence p = new Presence();
                    p.setEleveId(eleveId);
                    p.setDatePresence(LocalDate.parse(dateParam));
                    p.setStatut(statut);
                    p.setMinutesRetard(minutes);
                    p.setMotif(motif);
                    p.setJustifie(justifie);
                    p.setDecisionDisciplinaire(decision);
                    p.setNoteAdmin(note);
                    p.setEnregistrePar(u.getId());

                    // Enregistrer la présence
                    presenceDAO.enregistrer(p);

                    // Vérifier et créer les alertes automatiquement
                    alerteDAO.verifierEtCreerAlertes(eleveId);
                }
            }

            response.sendRedirect("presences?classeId="
                    + classeIdParam + "&date=" + dateParam
                    + "&succes=Presences+enregistrees+avec+succes");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(
                    "presences?erreur=Erreur+base+de+donnees");
        }
    }
}