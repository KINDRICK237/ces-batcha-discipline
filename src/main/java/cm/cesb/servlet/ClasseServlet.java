package cm.cesb.servlet;

import cm.cesb.dao.ClasseDAO;
import cm.cesb.model.Classe;
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

@WebServlet("/classes")
public class ClasseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ClasseDAO classeDAO = new ClasseDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("login");
            return;
        }

        // Seul l'admin peut gérer les classes
        Utilisateur u = (Utilisateur) session.getAttribute("utilisateur");
        if (!u.isAdmin()) {
            response.sendRedirect("dashboard");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "lister";

        try {
            switch (action) {

                case "ajouter":
                    request.getRequestDispatcher(
                            "/WEB-INF/jsp/ajouterClasse.jsp")
                           .forward(request, response);
                    break;

                case "modifier":
                    int idModifier = Integer.parseInt(
                            request.getParameter("id").trim());
                    Classe classe = classeDAO.trouverParId(idModifier);
                    request.setAttribute("classe", classe);
                    request.getRequestDispatcher(
                            "/WEB-INF/jsp/modifierClasse.jsp")
                           .forward(request, response);
                    break;

                case "supprimer":
                    int idSupprimer = Integer.parseInt(
                            request.getParameter("id").trim());
                    classeDAO.supprimer(idSupprimer);
                    response.sendRedirect(
                            "classes?succes=Classe+supprimee+avec+succes");
                    break;

                default:
                    List<Classe> classes = classeDAO.listerTous();
                    request.setAttribute("classes", classes);
                    request.getRequestDispatcher("/WEB-INF/jsp/classes.jsp")
                           .forward(request, response);
                    break;
            }

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
            response.sendRedirect("dashboard");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("ajouter".equals(action)) {

                Classe classe = new Classe();
                classe.setNom(request.getParameter("nom"));
                classe.setNiveau(request.getParameter("niveau"));
                classe.setAnneeScolaire(
                        request.getParameter("anneeScolaire"));

                classeDAO.ajouter(classe);
                response.sendRedirect(
                        "classes?succes=Classe+ajoutee+avec+succes");

            } else if ("modifier".equals(action)) {

                Classe classe = new Classe();
                classe.setId(Integer.parseInt(
                        request.getParameter("id").trim()));
                classe.setNom(request.getParameter("nom"));
                classe.setNiveau(request.getParameter("niveau"));
                classe.setAnneeScolaire(
                        request.getParameter("anneeScolaire"));

                classeDAO.modifier(classe);
                response.sendRedirect(
                        "classes?succes=Classe+modifiee+avec+succes");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(
                    "classes?erreur=Erreur+base+de+donnees");
        }
    }
}