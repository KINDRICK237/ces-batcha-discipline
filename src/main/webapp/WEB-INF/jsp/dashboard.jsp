<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>

<%
    // Vérification de l'utilisateur connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { 
        response.sendRedirect("login"); 
        return; 
    }
    
    // Récupération des statistiques depuis les attributs de la requête
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css"/>
    <style>
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
            cursor: pointer;
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
            flex-shrink: 0;
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

        @media (max-width: 1024px) {
            .grille-stats { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 768px) {
            .bienvenue { padding: 15px; }
            .bienvenue h2 { font-size: 17px; }
            .grille-stats { grid-template-columns: repeat(2, 1fr); }
            .grille-raccourcis { grid-template-columns: 1fr; }
            .icone-stat { width: 40px; height: 40px; font-size: 20px; }
            .info-stat h3 { font-size: 20px; }
        }
        @media (max-width: 480px) {
            .grille-stats { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>

    <!-- Inclusion dynamique de la sidebar (évite les conflits de variables) -->
    <jsp:include page="sidebar.jsp" />

    <div class="contenu">
        <div class="topbar">
            <h1>📊 Tableau de bord</h1>
            <div class="topbar-droite">
                <span class="badge-role"><%= utilisateur.getRole() %></span>
                <a href="<%= request.getContextPath() %>/logout"
                   class="btn-deconnexion">🚪 Déconnexion</a>
            </div>
        </div>

        <div class="zone-principale">

            <div class="bienvenue">
                <h2>Bienvenue, <%= utilisateur.getNomComplet() %> 👋</h2>
                <p>Tableau de bord — Année scolaire 2025-2026</p>
            </div>

            <div class="grille-stats">
                <div class="carte-stat" onclick="window.location='eleves'">
                    <div class="icone-stat bg-bleu">👨‍🎓</div>
                    <div class="info-stat">
                        <h3><%= nbEleves %></h3>
                        <p>Élèves inscrits</p>
                    </div>
                </div>
                <div class="carte-stat" onclick="window.location='presences'">
                    <div class="icone-stat bg-vert">✅</div>
                    <div class="info-stat">
                        <h3><%= nbPresents %></h3>
                        <p>Présents aujourd'hui</p>
                    </div>
                </div>
                <div class="carte-stat" onclick="window.location='presences'">
                    <div class="icone-stat bg-rouge">❌</div>
                    <div class="info-stat">
                        <h3><%= nbAbsents %></h3>
                        <p>Absents aujourd'hui</p>
                    </div>
                </div>
                <div class="carte-stat" onclick="window.location='presences'">
                    <div class="icone-stat bg-orange">⏰</div>
                    <div class="info-stat">
                        <h3><%= nbRetards %></h3>
                        <p>Retards aujourd'hui</p>
                    </div>
                </div>
                <div class="carte-stat" onclick="window.location='alertes'">
                    <div class="icone-stat bg-rouge">🔔</div>
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