package cm.cesb.servlet;

import cm.cesb.dao.UtilisateurDAO;
import cm.cesb.model.Utilisateur;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/utilisateurs")
public class UtilisateurServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UtilisateurDAO utilisateurDAO = new UtilisateurDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("login");
            return;
        }

        // Seul l'admin peut gérer les utilisateurs
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
                            "/WEB-INF/jsp/ajouterUtilisateur.jsp")
                           .forward(request, response);
                    break;

                case "modifier":
                    int idModifier = Integer.parseInt(
                            request.getParameter("id").trim());
                    Utilisateur utilisateur =
                            utilisateurDAO.trouverParId(idModifier);
                    request.setAttribute("utilisateur", utilisateur);
                    request.getRequestDispatcher(
                            "/WEB-INF/jsp/modifierUtilisateur.jsp")
                           .forward(request, response);
                    break;

                case "activer":
                    int idActiver = Integer.parseInt(
                            request.getParameter("id").trim());
                    utilisateurDAO.changerStatut(idActiver, true);
                    response.sendRedirect(
                            "utilisateurs?succes=Compte+active");
                    break;

                case "desactiver":
                    int idDesactiver = Integer.parseInt(
                            request.getParameter("id").trim());
                    utilisateurDAO.changerStatut(idDesactiver, false);
                    response.sendRedirect(
                            "utilisateurs?succes=Compte+desactive");
                    break;

                case "supprimer":
                    int idSupprimer = Integer.parseInt(
                            request.getParameter("id").trim());
                    utilisateurDAO.supprimer(idSupprimer);
                    response.sendRedirect(
                            "utilisateurs?succes=Utilisateur+supprime");
                    break;

                default:
                    List<Utilisateur> utilisateurs =
                            utilisateurDAO.listerTous();
                    request.setAttribute("utilisateurs", utilisateurs);
                    request.getRequestDispatcher(
                            "/WEB-INF/jsp/utilisateurs.jsp")
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

        Utilisateur connecte = (Utilisateur) session.getAttribute("utilisateur");
        if (!connecte.isAdmin()) {
            response.sendRedirect("dashboard");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("ajouter".equals(action)) {

                String email = request.getParameter("email").trim();

                // Vérifier si email existe déjà
                if (utilisateurDAO.trouverParEmail(email) != null) {
                    request.setAttribute("erreur",
                            "Cet email est déjà utilisé.");
                    request.getRequestDispatcher(
                            "/WEB-INF/jsp/ajouterUtilisateur.jsp")
                           .forward(request, response);
                    return;
                }

                Utilisateur u = new Utilisateur();
                u.setNom(request.getParameter("nom").toUpperCase());
                u.setPrenom(request.getParameter("prenom"));
                u.setEmail(email);
                u.setMotDePasse(hashSHA256(request.getParameter("motDePasse")));
                u.setRole(request.getParameter("role"));
                u.setActif(true);

                utilisateurDAO.ajouter(u);
                response.sendRedirect(
                        "utilisateurs?succes=Utilisateur+ajoute+avec+succes");

            } else if ("modifier".equals(action)) {

                Utilisateur u = new Utilisateur();
                u.setId(Integer.parseInt(
                        request.getParameter("id").trim()));
                u.setNom(request.getParameter("nom").toUpperCase());
                u.setPrenom(request.getParameter("prenom"));
                u.setEmail(request.getParameter("email").trim());
                u.setRole(request.getParameter("role"));

                // Changer le mot de passe seulement si renseigné
                String nouveauMdp = request.getParameter("motDePasse");
                if (nouveauMdp != null && !nouveauMdp.trim().isEmpty()) {
                    u.setMotDePasse(hashSHA256(nouveauMdp));
                } else {
                    // Garder l'ancien mot de passe
                    Utilisateur ancien = utilisateurDAO.trouverParId(u.getId());
                    u.setMotDePasse(ancien.getMotDePasse());
                }

                utilisateurDAO.modifier(u);
                response.sendRedirect(
                        "utilisateurs?succes=Utilisateur+modifie+avec+succes");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(
                    "utilisateurs?erreur=Erreur+base+de+donnees");
        }
    }

    private String hashSHA256(String texte) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(texte.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 non disponible", e);
        }
    }
}