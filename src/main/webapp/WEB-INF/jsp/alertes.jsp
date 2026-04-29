<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Alerte" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }
    if (!utilisateur.isAdmin()) { response.sendRedirect("dashboard"); return; }
    List<Alerte> alertes = (List<Alerte>) request.getAttribute("alertes");
    int nbNonLues = request.getAttribute("nbNonLues") != null
            ? (int) request.getAttribute("nbNonLues") : 0;
    String succes = request.getParameter("succes");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alertes — CES de Batcha</title>
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
        .badge-menu {
            background: #e53935;
            color: white;
            padding: 2px 7px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 700;
            margin-left: auto;
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
        .barre-outils {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .info-nonlues {
            background: #fce4ec;
            color: #c62828;
            padding: 8px 15px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
        }
        .btn-tout-lire {
            padding: 9px 18px;
            background: #1565c0;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
        }
        .liste-alertes {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .carte-alerte {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 15px;
            border-left: 4px solid #ccc;
            transition: transform 0.2s;
        }
        .carte-alerte:hover { transform: translateX(3px); }
        .carte-alerte.non-lue { background: #fffde7; }
        .icone-alerte { font-size: 30px; flex-shrink: 0; }
        .contenu-alerte { flex: 1; }
        .contenu-alerte h4 {
            font-size: 14px;
            font-weight: 700;
            color: #1a3c5e;
            margin-bottom: 4px;
        }
        .contenu-alerte p {
            font-size: 13px;
            color: #546e7a;
            margin-bottom: 4px;
        }
        .contenu-alerte .meta {
            font-size: 11px;
            color: #90a4ae;
        }
        .badge-nonlue {
            background: #e53935;
            color: white;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 700;
            margin-left: 8px;
        }
        .btn-lire {
            padding: 6px 12px;
            background: #e8f5e9;
            color: #2e7d32;
            border: none;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
            white-space: nowrap;
        }
        .btn-voir-eleve {
            padding: 6px 12px;
            background: #e3f2fd;
            color: #1565c0;
            border: none;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
            white-space: nowrap;
        }
        .actions-alerte {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .vide {
            text-align: center;
            padding: 60px;
            color: #90a4ae;
            font-size: 16px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
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
            <a href="alertes" class="menu-item actif">
                🔔 Alertes
                <% if (nbNonLues > 0) { %>
                <span class="badge-menu"><%= nbNonLues %></span>
                <% } %>
            </a>
            <div class="menu-titre">Administration</div>
            <a href="utilisateurs" class="menu-item">👥 Utilisateurs</a>
            <a href="classes" class="menu-item">🏛️ Classes</a>
        </div>
        <div class="sidebar-pied">
            👤 <%= utilisateur.getNomComplet() %>
        </div>
    </div>

    <div class="contenu">
        <div class="topbar">
            <h1>🔔 Alertes disciplinaires</h1>
            <div class="topbar-droite">
                <span class="badge-role">ADMIN</span>
                <a href="logout" class="btn-deconnexion">🚪 Déconnexion</a>
            </div>
        </div>

        <div class="zone-principale">

            <% if (succes != null) { %>
            <div class="alerte-succes">✅ <%= succes %></div>
            <% } %>

            <div class="barre-outils">
                <div class="info-nonlues">
                    🔔 <%= nbNonLues %> alerte(s) non lue(s)
                </div>
                <% if (nbNonLues > 0) { %>
                <a href="alertes?action=toutLire" class="btn-tout-lire">
                    ✅ Tout marquer comme lu
                </a>
                <% } %>
            </div>

            <div class="liste-alertes">
                <% if (alertes == null || alertes.isEmpty()) { %>
                <div class="vide">✅ Aucune alerte — tout va bien !</div>
                <% } else { for (Alerte a : alertes) { %>
                <div class="carte-alerte <%= !a.isLue() ? "non-lue" : "" %>"
                     style="border-left-color:<%= a.getCouleur() %>;">
                    <div class="icone-alerte"><%= a.getIcone() %></div>
                    <div class="contenu-alerte">
                        <h4>
                            <%= a.getTypeAlerteLibelle() %>
                            — <%= a.getEleveNomComplet() %>
                            <% if (!a.isLue()) { %>
                            <span class="badge-nonlue">NOUVEAU</span>
                            <% } %>
                        </h4>
                        <p><%= a.getMessage() %></p>
                        <p class="meta">
                            📚 Classe : <%= a.getEleveClasse() %>
                            &nbsp;|&nbsp;
                            🎫 Matricule : <%= a.getEleveMatricule() %>
                            &nbsp;|&nbsp;
                            📅 <%= a.getDateAlerte() != null
                                ? a.getDateAlerte().toString()
                                   .replace("T"," ").substring(0,16)
                                : "" %>
                        </p>
                    </div>
                    <div class="actions-alerte">
                        <a href="rapports?type=eleve&eleveId=<%= a.getEleveId() %>"
                           class="btn-voir-eleve">👁️ Voir élève</a>
                        <% if (!a.isLue()) { %>
                        <a href="alertes?action=lire&id=<%= a.getId() %>"
                           class="btn-lire">✅ Marquer lu</a>
                        <% } %>
                    </div>
                </div>
                <% }} %>
            </div>
        </div>
    </div>

</body>
</html>