package cm.cesb.servlet;

import cm.cesb.dao.AlerteDAO;
import cm.cesb.model.Alerte;
import cm.cesb.model.Utilisateur;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/alertes")
public class AlerteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final AlerteDAO alerteDAO = new AlerteDAO();

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
            response.sendRedirect("dashboard");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "lister";

        try {
            switch (action) {

                case "lire":
                    int id = Integer.parseInt(
                            request.getParameter("id").trim());
                    alerteDAO.marquerCommeLue(id);
                    response.sendRedirect("alertes");
                    break;

                case "toutLire":
                    alerteDAO.marquerToutesCommeLues();
                    response.sendRedirect(
                            "alertes?succes=Toutes+alertes+marquees+comme+lues");
                    break;

                default:
                    List<Alerte> alertes = alerteDAO.listerToutes();
                    int nbNonLues = alerteDAO.compterNonLues();
                    request.setAttribute("alertes",   alertes);
                    request.setAttribute("nbNonLues", nbNonLues);
                    request.getRequestDispatcher("/WEB-INF/jsp/alertes.jsp")
                           .forward(request, response);
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERREUR : " + e.getMessage());
        }
    }
}