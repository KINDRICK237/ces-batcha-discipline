<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("login");
        return;
    }
    int nbEleves   = request.getAttribute("nbEleves")   != null ? (int) request.getAttribute("nbEleves")   : 0;
    int nbPresents = request.getAttribute("nbPresents") != null ? (int) request.getAttribute("nbPresents") : 0;
    int nbAbsents  = request.getAttribute("nbAbsents")  != null ? (int) request.getAttribute("nbAbsents")  : 0;
    int nbRetards  = request.getAttribute("nbRetards")  != null ? (int) request.getAttribute("nbRetards")  : 0;
    int nbAlertes  = request.getAttribute("nbAlertes")  != null ? (int) request.getAttribute("nbAlertes")  : 0;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — CES de Batcha</title>
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
        .bienvenue {
            background: linear-gradient(135deg, #1a3c5e, #1565c0);
            color: white;
            padding: 25px 30px;
            border-radius: 12px;
            margin-bottom: 25px;
        }
        .bienvenue h2 { font-size: 22px; margin-bottom: 5px; }
        .bienvenue p  { opacity: 0.85; font-size: 14px; }
        .grille-stats {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }
        .carte-stat {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            display: flex;
            align-items: center;
            gap: 15px;
            transition: transform 0.2s;
        }
        .carte-stat:hover { transform: translateY(-2px); }
        .icone-stat {
            width: 55px;
            height: 55px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
        }
        .info-stat h3 {
            font-size: 26px;
            font-weight: 700;
            color: #1a3c5e;
        }
        .info-stat p {
            font-size: 13px;
            color: #78909c;
            margin-top: 2px;
        }
        .bg-bleu   { background: #e3f2fd; }
        .bg-vert   { background: #e8f5e9; }
        .bg-orange { background: #fff3e0; }
        .bg-rouge  { background: #fce4ec; }
        .bg-alerte { background: #fce4ec; }
        .grille-raccourcis {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        .carte-raccourci {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            text-align: center;
            text-decoration: none;
            color: #1a3c5e;
            transition: transform 0.2s, box-shadow 0.2s;
            display: block;
        }
        .carte-raccourci:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        }
        .icone-raccourci {
            font-size: 40px;
            margin-bottom: 12px;
            display: block;
        }
        .carte-raccourci h3 {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .carte-raccourci p { font-size: 12px; color: #78909c; }
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
            <a href="dashboard" class="menu-item actif">📊 Tableau de bord</a>
            <a href="eleves" class="menu-item">👨‍🎓 Élèves</a>
            <a href="presences" class="menu-item">📋 Présences</a>
            <a href="rapports" class="menu-item">📈 Rapports</a>
            <a href="alertes" class="menu-item">
                🔔 Alertes
                <% if (nbAlertes > 0) { %>
                <span class="badge-menu"><%= nbAlertes %></span>
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
            <h1>📊 Tableau de bord</h1>
            <div class="topbar-droite">
                <span class="badge-role"><%= utilisateur.getRole() %></span>
                <a href="logout" class="btn-deconnexion">🚪 Déconnexion</a>
            </div>
        </div>

        <div class="zone-principale">

            <div class="bienvenue">
                <h2>Bienvenue, <%= utilisateur.getNomComplet() %> 👋</h2>
                <p>Tableau de bord — Année scolaire 2025-2026</p>
            </div>

            <div class="grille-stats">
                <div class="carte-stat">
                    <div class="icone-stat bg-bleu">👨‍🎓</div>
                    <div class="info-stat">
                        <h3><%= nbEleves %></h3>
                        <p>Élèves inscrits</p>
                    </div>
                </div>
                <div class="carte-stat">
                    <div class="icone-stat bg-vert">✅</div>
                    <div class="info-stat">
                        <h3><%= nbPresents %></h3>
                        <p>Présents aujourd'hui</p>
                    </div>
                </div>
                <div class="carte-stat">
                    <div class="icone-stat bg-rouge">❌</div>
                    <div class="info-stat">
                        <h3><%= nbAbsents %></h3>
                        <p>Absents aujourd'hui</p>
                    </div>
                </div>
                <div class="carte-stat">
                    <div class="icone-stat bg-orange">⏰</div>
                    <div class="info-stat">
                        <h3><%= nbRetards %></h3>
                        <p>Retards aujourd'hui</p>
                    </div>
                </div>
                <div class="carte-stat" style="cursor:pointer;"
                     onclick="window.location='alertes'">
                    <div class="icone-stat bg-alerte">🔔</div>
                    <div class="info-stat">
                        <h3 style="color:#e53935;"><%= nbAlertes %></h3>
                        <p>Alertes actives</p>
                    </div>
                </div>
            </div>

            <div class="grille-raccourcis">
                <a href="eleves" class="carte-raccourci">
                    <span class="icone-raccourci">👨‍🎓</span>
                    <h3>Gérer les élèves</h3>
                    <p>Ajouter, modifier, consulter</p>
                </a>
                <a href="presences" class="carte-raccourci">
                    <span class="icone-raccourci">📋</span>
                    <h3>Enregistrer les présences</h3>
                    <p>Présent, absent, retard</p>
                </a>
                <a href="rapports" class="carte-raccourci">
                    <span class="icone-raccourci">📈</span>
                    <h3>Voir les rapports</h3>
                    <p>Statistiques et assiduité</p>
                </a>
            </div>

        </div>
    </div>

</body>
</html>