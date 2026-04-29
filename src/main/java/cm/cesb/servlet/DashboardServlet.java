package cm.cesb.servlet;

import cm.cesb.dao.AlerteDAO;
import cm.cesb.dao.EleveDAO;
import cm.cesb.dao.PresenceDAO;
import cm.cesb.model.Utilisateur;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final EleveDAO    eleveDAO    = new EleveDAO();
    private final PresenceDAO presenceDAO = new PresenceDAO();
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

        Utilisateur u = (Utilisateur) session.getAttribute("utilisateur");
        if (!u.isAdmin()) {
            response.sendRedirect("eleves");
            return;
        }

        try {
            int nbEleves   = eleveDAO.compterTous();
            int nbPresents = presenceDAO.compterPresentsAujourdhui();
            int nbAbsents  = presenceDAO.compterAbsentsAujourdhui();
            int nbRetards  = presenceDAO.compterRetardsAujourdhui();
            int nbAlertes  = alerteDAO.compterNonLues();

            request.setAttribute("nbEleves",  nbEleves);
            request.setAttribute("nbPresents", nbPresents);
            request.setAttribute("nbAbsents",  nbAbsents);
            request.setAttribute("nbRetards",  nbRetards);
            request.setAttribute("nbAlertes",  nbAlertes);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("nbEleves",  0);
            request.setAttribute("nbPresents", 0);
            request.setAttribute("nbAbsents",  0);
            request.setAttribute("nbRetards",  0);
            request.setAttribute("nbAlertes",  0);
        }

        request.getRequestDispatcher("/WEB-INF/jsp/dashboard.jsp")
               .forward(request, response);
    }
}