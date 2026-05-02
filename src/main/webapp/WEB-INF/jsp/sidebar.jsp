<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.dao.AlerteDAO" %>

<%
    // Récupération de l'utilisateur depuis la session
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    
    // Calcul du nombre d'alertes non lues (seulement pour les admins)
    int nbAlertes = 0;
    if (utilisateur != null && utilisateur.isAdmin()) {
        try {
            AlerteDAO aDAO = new AlerteDAO();
            nbAlertes = aDAO.compterNonLues();
        } catch (Exception e) {
            nbAlertes = 0;
        }
    }
    
    // Récupération du chemin de la page courante
    String pageCourante = request.getServletPath();
%>

<!-- Bouton Hamburger -->
<button class="btn-hamburger" onclick="toggleSidebar()">☰</button>

<!-- Overlay -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="fermerSidebar()"></div>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
    <div class="sidebar-entete">
        <span class="icone">🏫</span>
        <h2>CES de Batcha</h2>
        <p>Suivi Disciplinaire</p>
    </div>
    
    <div class="sidebar-menu">
        <div class="menu-titre">Navigation</div>

        <% if (utilisateur != null && utilisateur.isAdmin()) { %>
        <a href="<%= request.getContextPath() %>/dashboard"
           class="menu-item <%= request.getServletPath().contains("dashboard") ? "actif" : "" %>">
            📊 Tableau de bord
        </a>
        <% } %>

        <a href="<%= request.getContextPath() %>/eleves"
           class="menu-item <%= request.getServletPath().contains("eleve") ? "actif" : "" %>">
            👨‍🎓 Élèves
        </a>

        <a href="<%= request.getContextPath() %>/presences"
           class="menu-item <%= request.getServletPath().contains("presence") ? "actif" : "" %>">
            📋 Présences
        </a>

        <a href="<%= request.getContextPath() %>/rapports"
           class="menu-item <%= request.getServletPath().contains("rapport") ? "actif" : "" %>">
            📈 Rapports
        </a>

        <% if (utilisateur != null && utilisateur.isAdmin()) { %>
        <a href="<%= request.getContextPath() %>/alertes"
           class="menu-item <%= request.getServletPath().contains("alerte") ? "actif" : "" %>">
            🔔 Alertes
            <% if (nbAlertes > 0) { %>
            <span class="badge-menu"><%= nbAlertes %></span>
            <% } %>
        </a>

        <div class="menu-titre">Administration</div>

        <a href="<%= request.getContextPath() %>/utilisateurs"
           class="menu-item <%= request.getServletPath().contains("utilisateur") ? "actif" : "" %>">
            👥 Utilisateurs
        </a>

        <a href="<%= request.getContextPath() %>/classes"
           class="menu-item <%= request.getServletPath().contains("classe") ? "actif" : "" %>">
            🏛️ Classes
        </a>
        <% } %>
    </div>
    
    <div class="sidebar-pied">
        👤 <%= utilisateur != null ? utilisateur.getNomComplet() : "" %>
    </div>
</div>

<script>
function toggleSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    sidebar.classList.toggle('ouverte');
    overlay.classList.toggle('visible');
}

function fermerSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    sidebar.classList.remove('ouverte');
    overlay.classList.remove('visible');
}
</script>