<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }
    if (!utilisateur.isAdmin()) { response.sendRedirect("dashboard"); return; }
    List<Utilisateur> utilisateurs = (List<Utilisateur>) request.getAttribute("utilisateurs");
    String succes = request.getParameter("succes");
    String erreur = request.getParameter("erreur");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Utilisateurs — CES de Batcha</title>
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
        .badge-role-admin {
            background: #fce4ec;
            color: #c62828;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-role-enseignant {
            background: #e3f2fd;
            color: #1565c0;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-actif {
            background: #e8f5e9;
            color: #2e7d32;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-inactif {
            background: #f5f5f5;
            color: #9e9e9e;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .actions { display: flex; gap: 6px; flex-wrap: wrap; }
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
        .btn-activer {
            padding: 5px 10px;
            background: #2e7d32;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-desactiver {
            padding: 5px 10px;
            background: #f57c00;
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
            <a href="utilisateurs" class="menu-item actif">👥 Utilisateurs</a>
            <a href="classes" class="menu-item">🏛️ Classes</a>
        </div>
        <div class="sidebar-pied">
            👤 <%= utilisateur.getNomComplet() %>
        </div>
    </div>

    <div class="contenu">
        <div class="topbar">
            <h1>👥 Gestion des Utilisateurs</h1>
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
                <a href="utilisateurs?action=ajouter" class="btn-ajouter">
                    ➕ Ajouter un utilisateur
                </a>
            </div>

            <div class="carte-tableau">
                <div class="carte-tableau-entete">
                    <h3>Liste des utilisateurs</h3>
                    <span class="badge-total">
                        <%= utilisateurs != null ? utilisateurs.size() : 0 %>
                        utilisateur(s)
                    </span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Nom complet</th>
                            <th>Email</th>
                            <th>Rôle</th>
                            <th>Statut</th>
                            <th>Dernière connexion</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (utilisateurs == null || utilisateurs.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="vide">
                                Aucun utilisateur trouvé
                            </td>
                        </tr>
                        <% } else { for (Utilisateur u : utilisateurs) { %>
                        <tr>
                            <td><strong><%= u.getNomComplet() %></strong></td>
                            <td><%= u.getEmail() %></td>
                            <td>
                                <% if ("ADMIN".equals(u.getRole())) { %>
                                <span class="badge-role-admin">👑 ADMIN</span>
                                <% } else { %>
                                <span class="badge-role-enseignant">
                                    👨‍🏫 ENSEIGNANT
                                </span>
                                <% } %>
                            </td>
                            <td>
                                <% if (u.isActif()) { %>
                                <span class="badge-actif">✅ Actif</span>
                                <% } else { %>
                                <span class="badge-inactif">⛔ Inactif</span>
                                <% } %>
                            </td>
                            <td>
                                <%= u.getDerniereConnexion() != null
                                    ? u.getDerniereConnexion()
                                       .toString().replace("T", " ")
                                       .substring(0, 16)
                                    : "Jamais" %>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="utilisateurs?action=modifier&id=<%= u.getId() %>"
                                       class="btn-modifier">✏️</a>
                                    <% if (u.getId() != utilisateur.getId()) { %>
                                    <% if (u.isActif()) { %>
                                    <a href="utilisateurs?action=desactiver&id=<%= u.getId() %>"
                                       class="btn-desactiver"
                                       onclick="return confirm('Désactiver ce compte ?')">
                                       ⛔</a>
                                    <% } else { %>
                                    <a href="utilisateurs?action=activer&id=<%= u.getId() %>"
                                       class="btn-activer">✅</a>
                                    <% } %>
                                    <a href="utilisateurs?action=supprimer&id=<%= u.getId() %>"
                                       class="btn-supprimer"
                                       onclick="return confirm('Supprimer cet utilisateur ?')">
                                       🗑️</a>
                                    <% } %>
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