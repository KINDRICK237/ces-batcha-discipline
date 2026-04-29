<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Classe" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }
    if (!utilisateur.isAdmin()) { response.sendRedirect("dashboard"); return; }
    List<Classe> classes = (List<Classe>) request.getAttribute("classes");
    String succes = request.getParameter("succes");
    String erreur = request.getParameter("erreur");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Classes — CES de Batcha</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: #f0f2f5;
            display: flex;
            min-height: 100vh;
        }
        .sidebar {
            width: 250px;
            background: linear-gradient(180deg, #1a3c5e, #1565c0);
            color: white;
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
        }
        .sidebar-entete {
            padding: 25px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.15);
        }
        .sidebar-entete .icone { font-size: 40px; display: block; margin-bottom: 8px; }
        .sidebar-entete h2 { font-size: 15px; font-weight: 700; }
        .sidebar-entete p  { font-size: 11px; opacity: 0.75; margin-top: 3px; }
        .sidebar-menu { padding: 15px 0; flex: 1; }
        .menu-titre {
            padding: 15px 20px 5px;
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.5;
        }
        .menu-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 13px 20px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            font-size: 14px;
            transition: background 0.2s;
        }
        .menu-item:hover { background: rgba(255,255,255,0.15); color: white; }
        .menu-item.actif {
            background: rgba(255,255,255,0.2);
            color: white;
            font-weight: 600;
            border-left: 3px solid white;
        }
        .sidebar-pied {
            padding: 15px 20px;
            border-top: 1px solid rgba(255,255,255,0.15);
            font-size: 12px;
            opacity: 0.75;
        }
        .contenu {
            margin-left: 250px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .topbar {
            background: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }
        .topbar h1 { font-size: 20px; color: #1a3c5e; font-weight: 700; }
        .topbar-droite { display: flex; align-items: center; gap: 15px; }
        .badge-role {
            background: #e3f2fd;
            color: #1565c0;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .btn-deconnexion {
            background: #e53935;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
        }
        .zone-principale { padding: 25px 30px; flex: 1; }
        .alerte-succes {
            background: #e8f5e9;
            border-left: 4px solid #2e7d32;
            color: #1b5e20;
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .alerte-erreur {
            background: #fdecea;
            border-left: 4px solid #e53935;
            color: #b71c1c;
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .barre-outils {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .btn-ajouter {
            padding: 9px 18px;
            background: #2e7d32;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
        }
        .carte-tableau {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .carte-tableau-entete {
            padding: 18px 20px;
            border-bottom: 1px solid #eceff1;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .carte-tableau-entete h3 { font-size: 16px; color: #1a3c5e; }
        .badge-total {
            background: #e3f2fd;
            color: #1565c0;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        table { width: 100%; border-collapse: collapse; }
        th {
            background: #f5f7fa;
            padding: 12px 15px;
            text-align: left;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #78909c;
            font-weight: 600;
        }
        td {
            padding: 13px 15px;
            border-bottom: 1px solid #f5f7fa;
            font-size: 14px;
            color: #37474f;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }
        .badge-niveau {
            background: #e3f2fd;
            color: #1565c0;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .actions { display: flex; gap: 6px; }
        .btn-modifier {
            padding: 5px 10px;
            background: #1565c0;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-supprimer {
            padding: 5px 10px;
            background: #e53935;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
        }
        .vide {
            text-align: center;
            padding: 40px;
            color: #90a4ae;
            font-size: 15px;
        }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-entete">
            <span class="icone">🏫</span>
            <h2>CES de Batcha</h2>
            <p>Suivi Disciplinaire</p>
        </div>
        <div class="sidebar-menu">
            <div class="menu-titre">Navigation</div>
            <a href="dashboard" class="menu-item">📊 Tableau de bord</a>
            <a href="eleves" class="menu-item">👨‍🎓 Élèves</a>
            <a href="presences" class="menu-item">📋 Présences</a>
            <a href="rapports" class="menu-item">📈 Rapports</a>
            <div class="menu-titre">Administration</div>
            <a href="utilisateurs" class="menu-item">👥 Utilisateurs</a>
            <a href="classes" class="menu-item actif">🏛️ Classes</a>
        </div>
        <div class="sidebar-pied">
            👤 <%= utilisateur.getNomComplet() %>
        </div>
    </div>

    <div class="contenu">
        <div class="topbar">
            <h1>🏛️ Gestion des Classes</h1>
            <div class="topbar-droite">
                <span class="badge-role">ADMIN</span>
                <a href="logout" class="btn-deconnexion">🚪 Déconnexion</a>
            </div>
        </div>

        <div class="zone-principale">

            <% if (succes != null) { %>
                <div class="alerte-succes">✅ <%= succes %></div>
            <% } %>
            <% if (erreur != null) { %>
                <div class="alerte-erreur">⚠️ <%= erreur %></div>
            <% } %>

            <div class="barre-outils">
                <div></div>
                <a href="classes?action=ajouter" class="btn-ajouter">
                    ➕ Ajouter une classe
                </a>
            </div>

            <div class="carte-tableau">
                <div class="carte-tableau-entete">
                    <h3>Liste des classes</h3>
                    <span class="badge-total">
                        <%= classes != null ? classes.size() : 0 %> classe(s)
                    </span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Nom</th>
                            <th>Niveau</th>
                            <th>Année scolaire</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (classes == null || classes.isEmpty()) { %>
                        <tr>
                            <td colspan="5" class="vide">
                                Aucune classe enregistrée
                            </td>
                        </tr>
                        <% } else {
                            int rang = 1;
                            for (Classe c : classes) { %>
                        <tr>
                            <td><%= rang++ %></td>
                            <td><strong><%= c.getNom() %></strong></td>
                            <td>
                                <span class="badge-niveau">
                                    <%= c.getNiveau() %>
                                </span>
                            </td>
                            <td><%= c.getAnneeScolaire() %></td>
                            <td>
                                <div class="actions">
                                    <a href="classes?action=modifier&id=<%= c.getId() %>"
                                       class="btn-modifier">✏️ Modifier</a>
                                    <a href="classes?action=supprimer&id=<%= c.getId() %>"
                                       class="btn-supprimer"
                                       onclick="return confirm('Supprimer cette classe ?')">
                                       🗑️ Supprimer</a>
                                </div>
                            </td>
                        </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</body>
</html>