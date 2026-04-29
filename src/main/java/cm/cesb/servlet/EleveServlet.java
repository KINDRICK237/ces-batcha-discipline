package cm.cesb.servlet;

import cm.cesb.dao.EleveDAO;
import cm.cesb.dao.ClasseDAO;
import cm.cesb.model.Eleve;
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
import java.time.LocalDate;
import java.util.List;

@WebServlet("/eleves")
public class EleveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final EleveDAO eleveDAO   = new EleveDAO();
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

        String action = request.getParameter("action");
        if (action == null) action = "lister";

        try {
            switch (action) {

                case "ajouter":
                    List<Classe> classesAjouter = classeDAO.listerTous();
                    request.setAttribute("classes", classesAjouter);
                    request.getRequestDispatcher("/WEB-INF/jsp/ajouterEleve.jsp")
                           .forward(request, response);
                    break;

                case "modifier":
                    int idModifier = Integer.parseInt(
                            request.getParameter("id"));
                    Eleve eleve = eleveDAO.trouverParId(idModifier);
                    List<Classe> classesModif = classeDAO.listerTous();
                    request.setAttribute("eleve", eleve);
                    request.setAttribute("classes", classesModif);
                    request.getRequestDispatcher("/WEB-INF/jsp/modifierEleve.jsp")
                           .forward(request, response);
                    break;

                case "supprimer":
                    int idSupprimer = Integer.parseInt(
                            request.getParameter("id"));
                    eleveDAO.supprimer(idSupprimer);
                    response.sendRedirect(
                            "eleves?succes=Eleve+supprime+avec+succes");
                    break;

                default:
                    String filtreClasse = request.getParameter("classeId");
                    List<Eleve> eleves;

                    if (filtreClasse != null && !filtreClasse.isEmpty()) {
                        eleves = eleveDAO.listerParClasse(
                                Integer.parseInt(filtreClasse));
                    } else {
                        eleves = eleveDAO.listerTous();
                    }

                    List<Classe> toutesClasses = classeDAO.listerTous();
                    request.setAttribute("eleves", eleves);
                    request.setAttribute("classes", toutesClasses);
                    request.getRequestDispatcher("/WEB-INF/jsp/eleves.jsp")
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
            response.sendRedirect("eleves");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("ajouter".equals(action)) {

                Eleve eleve = new Eleve();
                eleve.setMatricule(request.getParameter("matricule"));
                eleve.setNom(request.getParameter("nom").toUpperCase());
                eleve.setPrenom(request.getParameter("prenom"));
                eleve.setGenre(request.getParameter("genre"));
                eleve.setClasseId(Integer.parseInt(
                        request.getParameter("classeId")));
                eleve.setTelephoneParent(
                        request.getParameter("telephoneParent"));
                eleve.setNomParent(request.getParameter("nomParent"));
                eleve.setAdresse(request.getParameter("adresse"));

                String dateNaissance = request.getParameter("dateNaissance");
                if (dateNaissance != null && !dateNaissance.isEmpty()) {
                    eleve.setDateNaissance(LocalDate.parse(dateNaissance));
                }

                eleveDAO.ajouter(eleve);
                response.sendRedirect(
                        "eleves?succes=Eleve+ajoute+avec+succes");

            } else if ("modifier".equals(action)) {

                Eleve eleve = new Eleve();
                eleve.setId(Integer.parseInt(request.getParameter("id")));
                eleve.setNom(request.getParameter("nom").toUpperCase());
                eleve.setPrenom(request.getParameter("prenom"));
                eleve.setGenre(request.getParameter("genre"));
                eleve.setClasseId(Integer.parseInt(
                        request.getParameter("classeId")));
                eleve.setTelephoneParent(
                        request.getParameter("telephoneParent"));
                eleve.setNomParent(request.getParameter("nomParent"));
                eleve.setAdresse(request.getParameter("adresse"));
                eleve.setStatut(request.getParameter("statut"));

                String dateNaissance = request.getParameter("dateNaissance");
                if (dateNaissance != null && !dateNaissance.isEmpty()) {
                    eleve.setDateNaissance(LocalDate.parse(dateNaissance));
                }

                eleveDAO.modifier(eleve);
                response.sendRedirect(
                        "eleves?succes=Eleve+modifie+avec+succes");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("eleves?erreur=Erreur+base+de+donnees");
        }
    }
}