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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UtilisateurDAO utilisateurDAO = new UtilisateurDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("utilisateur") != null) {
            Utilisateur u = (Utilisateur) session.getAttribute("utilisateur");
            if (u.isAdmin()) {
                response.sendRedirect("dashboard");
            } else {
                response.sendRedirect("eleves");
            }
            return;
        }

        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String email      = request.getParameter("email");
        String motDePasse = request.getParameter("motDePasse");

        if (email == null || email.trim().isEmpty()
                || motDePasse == null || motDePasse.trim().isEmpty()) {
            request.setAttribute("erreur", "Veuillez remplir tous les champs.");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp")
                   .forward(request, response);
            return;
        }

        try {
            Utilisateur utilisateur = utilisateurDAO
                    .trouverParEmail(email.trim());

            if (utilisateur == null) {
                request.setAttribute("erreur",
                        "Email ou mot de passe incorrect.");
                request.getRequestDispatcher("/WEB-INF/jsp/login.jsp")
                       .forward(request, response);
                return;
            }

            if (!utilisateur.isActif()) {
                request.setAttribute("erreur",
                        "Compte desactive. Contactez l'administrateur.");
                request.getRequestDispatcher("/WEB-INF/jsp/login.jsp")
                       .forward(request, response);
                return;
            }

            String motDePasseHash = hashSHA256(motDePasse);
            if (!motDePasseHash.equals(utilisateur.getMotDePasse())) {
                request.setAttribute("erreur",
                        "Email ou mot de passe incorrect.");
                request.getRequestDispatcher("/WEB-INF/jsp/login.jsp")
                       .forward(request, response);
                return;
            }

            utilisateurDAO.majDerniereConnexion(utilisateur.getId());

            HttpSession ancienneSession = request.getSession(false);
            if (ancienneSession != null) {
                ancienneSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("utilisateur", utilisateur);
            session.setMaxInactiveInterval(30 * 60);

            if (utilisateur.isAdmin()) {
                response.sendRedirect("dashboard");
            } else {
                response.sendRedirect("eleves");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("erreur",
                    "Erreur base de donnees. Reessayez.");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp")
                   .forward(request, response);
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