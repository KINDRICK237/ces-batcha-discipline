<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Eleve" %>
<%@ page import="cm.cesb.model.Classe" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("login");
        return;
    }
    List<Eleve> eleves = (List<Eleve>) request.getAttribute("eleves");
    List<Classe> classes = (List<Classe>) request.getAttribute("classes");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapports — CES de Batcha</title>
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
        .grille-rapports {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 25px;
        }
        .carte-rapport {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .carte-rapport-entete {
            padding: 20px 25px;
            color: white;
            font-size: 17px;
            font-weight: 700;
        }
        .bg-bleu   { background: linear-gradient(135deg, #1a3c5e, #1565c0); }
        .bg-vert   { background: linear-gradient(135deg, #1b5e20, #2e7d32); }
        .bg-violet { background: linear-gradient(135deg, #4a148c, #7b1fa2); }
        .carte-rapport-corps { padding: 20px 25px; }
        .champ-groupe {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 15px;
        }
        .champ-groupe label {
            font-size: 13px;
            font-weight: 600;
            color: #37474f;
        }
        .champ-groupe select {
            padding: 10px 14px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
            font-size: 14px;
            color: #263238;
            outline: none;
        }
        .btn-rapport {
            width: 100%;
            padding: 11px;
            color: white;
            border: none;
            border-radius: 7px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: block;
            text-align: center;
        }
        .btn-bleu   { background: linear-gradient(135deg, #1a3c5e, #1565c0); }
        .btn-vert   { background: linear-gradient(135deg, #1b5e20, #2e7d32); }
        .btn-violet { background: linear-gradient(135deg, #4a148c, #7b1fa2); }
        .btn-rapport:hover { opacity: 0.9; }

        /* ── Carte rapport global ── */
        .carte-global {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
            margin-bottom: 25px;
        }
        .carte-global-entete {
            padding: 20px 25px;
            color: white;
            font-size: 17px;
            font-weight: 700;
            background: linear-gradient(135deg, #b71c1c, #e53935);
        }
        .carte-global-corps {
            padding: 20px 25px;
        }
        .grille-periodes {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
        }
        .carte-periode {
            border: 2px solid #eceff1;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            text-decoration: none;
            color: #1a3c5e;
            transition: all 0.2s;
            display: block;
        }
        .carte-periode:hover {
            border-color: #1565c0;
            background: #e3f2fd;
            transform: translateY(-2px);
        }
        .carte-periode .icone-periode {
            font-size: 35px;
            display: block;
            margin-bottom: 10px;
        }
        .carte-periode h3 {
            font-size: 15px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .carte-periode p {
            font-size: 12px;
            color: #78909c;
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
            <a href="rapports" class="menu-item actif">📈 Rapports</a>
            <% if (utilisateur.isAdmin()) { %>
            <div class="menu-titre">Administration</div>
            <a href="utilisateurs" class="menu-item">👥 Utilisateurs</a>
            <a href="classes" class="menu-item">🏛️ Classes</a>
            <% } %>
        </div>
        <div class="sidebar-pied">
            👤 <%= utilisateur.getNomComplet() %>
        </div>
    </div>

    <div class="contenu">
        <div class="topbar">
            <h1>📈 Rapports</h1>
            <div class="topbar-droite">
                <span class="badge-role"><%= utilisateur.getRole() %></span>
                <a href="logout" class="btn-deconnexion">🚪 Déconnexion</a>
            </div>
        </div>

        <div class="zone-principale">

            <!-- Rapport global par période -->
            <div class="carte-global">
                <div class="carte-global-entete">
                    🌍 Rapport Global — Toutes les classes
                </div>
                <div class="carte-global-corps">
                    <div class="grille-periodes">
                        <a href="rapports?type=global&periode=hebdomadaire"
                           class="carte-periode">
                            <span class="icone-periode">📅</span>
                            <h3>Hebdomadaire</h3>
                            <p>Cette semaine</p>
                        </a>
                        <a href="rapports?type=global&periode=mensuel"
                           class="carte-periode">
                            <span class="icone-periode">📆</span>
                            <h3>Mensuel</h3>
                            <p>Ce mois</p>
                        </a>
                        <a href="rapports?type=global&periode=annuel"
                           class="carte-periode">
                            <span class="icone-periode">🗓️</span>
                            <h3>Annuel</h3>
                            <p>Cette année</p>
                        </a>
                    </div>
                </div>
            </div>

            <div class="grille-rapports">

                <!-- Rapport par élève -->
                <div class="carte-rapport">
                    <div class="carte-rapport-entete bg-bleu">
                        👨‍🎓 Rapport individuel par élève
                    </div>
                    <div class="carte-rapport-corps">
                        <form method="get" action="rapports">
                            <input type="hidden" name="type" value="eleve"/>
                            <div class="champ-groupe">
                                <label>Filtrer par classe</label>
                                <select id="filtreClasse"
                                        onchange="filtrerEleves()">
                                    <option value="">Toutes les classes</option>
                                    <% if (classes != null) {
                                        for (Classe c : classes) { %>
                                    <option value="<%= c.getId() %>">
                                        <%= c.getNom() %>
                                    </option>
                                    <% }} %>
                                </select>
                            </div>
                            <div class="champ-groupe">
                                <label>Sélectionner un élève *</label>
                                <select name="eleveId"
                                        id="listeEleves" required>
                                    <option value="">-- Choisir un élève --</option>
                                    <% if (eleves != null) {
                                        for (Eleve e : eleves) { %>
                                    <option value="<%= e.getId() %>"
                                            data-classe="<%= e.getClasseId() %>">
                                        <%= e.getNomComplet() %>
                                        (<%= e.getClasseNom() %>)
                                    </option>
                                    <% }} %>
                                </select>
                            </div>
                            <button type="submit"
                                    class="btn-rapport btn-bleu">
                                📊 Voir le rapport
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Rapport par classe -->
                <div class="carte-rapport">
                    <div class="carte-rapport-entete bg-vert">
                        🏛️ Rapport global par classe
                    </div>
                    <div class="carte-rapport-corps">
                        <form method="get" action="rapports">
                            <input type="hidden" name="type" value="classe"/>
                            <div class="champ-groupe">
                                <label>Sélectionner une classe *</label>
                                <select name="classeId" required>
                                    <option value="">-- Choisir une classe --</option>
                                    <% if (classes != null) {
                                        for (Classe c : classes) { %>
                                    <option value="<%= c.getId() %>">
                                        <%= c.getNom() %>
                                    </option>
                                    <% }} %>
                                </select>
                            </div>
                            <button type="submit"
                                    class="btn-rapport btn-vert">
                                📊 Voir le rapport
                            </button>
                        </form>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script>
        function filtrerEleves() {
            var classeId = document.getElementById('filtreClasse').value;
            var options  = document.getElementById('listeEleves').options;
            for (var i = 0; i < options.length; i++) {
                var opt = options[i];
                if (opt.value === '') {
                    opt.style.display = '';
                } else if (classeId === '' ||
                           opt.getAttribute('data-classe') === classeId) {
                    opt.style.display = '';
                } else {
                    opt.style.display = 'none';
                }
            }
            document.getElementById('listeEleves').value = '';
        }
    </script>

</body>
</html>