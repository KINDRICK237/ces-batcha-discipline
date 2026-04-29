<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Eleve" %>
<%@ page import="cm.cesb.model.Classe" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }
    Classe classe           = (Classe) request.getAttribute("classe");
    List<Eleve> eleves      = (List<Eleve>) request.getAttribute("eleves");
    int nbGarcons           = (int) request.getAttribute("nbGarcons");
    int nbFilles            = (int) request.getAttribute("nbFilles");
    List<int[]> statsEleves = (List<int[]>) request.getAttribute("statsEleves");

    int totalPresents = 0, totalAbsents = 0, totalRetards = 0;
    if (statsEleves != null) {
        for (int[] s : statsEleves) {
            totalPresents += s[0];
            totalAbsents  += s[1];
            totalRetards  += s[2];
        }
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Classe — CES de Batcha</title>
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
        .btn-imprimer {
            background: #1565c0;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
        }
        .btn-retour {
            background: #78909c;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
        }
        .zone-principale { padding: 25px 30px; flex: 1; }
        .zone-impression {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .entete-officiel {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 25px;
            border-bottom: 2px solid #1a3c5e;
            font-family: 'Times New Roman', serif;
        }
        .entete-gauche, .entete-droite {
            flex: 1;
            font-size: 10px;
            text-transform: uppercase;
            font-weight: bold;
            line-height: 1.9;
        }
        .entete-droite { text-align: right; }
        .entete-centre {
            flex: 0 0 110px;
            text-align: center;
            padding: 0 10px;
        }
        .entete-centre img {
            width: 90px;
            height: 90px;
            object-fit: contain;
        }
        .sep { color: #333; font-size: 9px; letter-spacing: 2px; }
        .titre-rapport {
            text-align: center;
            padding: 20px;
            border-bottom: 1px solid #eceff1;
        }
        .titre-rapport h2 {
            font-size: 18px;
            color: #1a3c5e;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        .titre-rapport p { font-size: 13px; color: #78909c; }
        .info-classe {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            padding: 20px 25px;
            background: #f5f7fa;
            border-bottom: 1px solid #eceff1;
        }
        .info-item label {
            font-size: 11px;
            text-transform: uppercase;
            color: #90a4ae;
            font-weight: 600;
        }
        .info-item p {
            font-size: 14px;
            color: #1a3c5e;
            font-weight: 700;
            margin-top: 3px;
        }
        .grille-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            padding: 20px 25px;
            border-bottom: 1px solid #eceff1;
        }
        .stat-carte {
            text-align: center;
            padding: 15px;
            border-radius: 8px;
        }
        .stat-carte h3 { font-size: 28px; font-weight: 700; margin-bottom: 5px; }
        .stat-carte p  { font-size: 12px; font-weight: 600; text-transform: uppercase; }
        .bg-bleu   { background: #e3f2fd; color: #1565c0; }
        .bg-vert   { background: #e8f5e9; color: #2e7d32; }
        .bg-rouge  { background: #fce4ec; color: #c62828; }
        .bg-orange { background: #fff3e0; color: #e65100; }
        .bg-cyan   { background: #e0f7fa; color: #00695c; }
        .bg-violet { background: #f3e5f5; color: #6a1b9a; }
        .section-titre {
            padding: 15px 25px 10px;
            font-size: 15px;
            font-weight: 700;
            color: #1a3c5e;
            border-bottom: 1px solid #eceff1;
        }
        table { width: 100%; border-collapse: collapse; }
        th {
            background: #f5f7fa;
            padding: 10px 15px;
            text-align: left;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #78909c;
            font-weight: 600;
        }
        td {
            padding: 10px 15px;
            border-bottom: 1px solid #f5f7fa;
            font-size: 13px;
            color: #37474f;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }
        .badge-genre-m {
            background: #e3f2fd; color: #1565c0;
            padding: 2px 8px; border-radius: 4px;
            font-size: 11px; font-weight: 600;
        }
        .badge-genre-f {
            background: #fce4ec; color: #c62828;
            padding: 2px 8px; border-radius: 4px;
            font-size: 11px; font-weight: 600;
        }
        .taux-barre {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .mini-barre {
            flex: 1;
            height: 8px;
            background: #eceff1;
            border-radius: 4px;
            overflow: hidden;
        }
        .mini-remplissage {
            height: 100%;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            border-radius: 4px;
        }
        .vide {
            text-align: center;
            padding: 30px;
            color: #90a4ae;
            font-size: 14px;
        }
        @media print {
            .sidebar, .topbar,
            .btn-imprimer, .btn-retour,
            .btn-deconnexion { display: none !important; }
            .contenu { margin-left: 0 !important; }
            .zone-principale { padding: 0 !important; }
            .zone-impression { box-shadow: none !important; border-radius: 0 !important; }
            body { background: white !important; }
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
            <h1>📊 Rapport de classe</h1>
            <div class="topbar-droite">
    <a href="rapports" class="btn-retour">← Retour</a>
    <a href="exportPdf?type=classe&classeId=<%= classe.getId() %>"
       class="btn-pdf">
        📄 PDF
    </a>
    <a href="exportExcel?type=classe&classeId=<%= classe.getId() %>"
       class="btn-excel">
        📊 Excel
    </a>
    <button class="btn-imprimer" onclick="window.print()">
        🖨️ Imprimer
    </button>
    <span class="badge-role"><%= utilisateur.getRole() %></span>
    <a href="logout" class="btn-deconnexion">🚪 Déconnexion</a>
</div>
        </div>

        <div class="zone-principale">
            <div class="zone-impression">

                <!-- En-tête officiel -->
                <div class="entete-officiel">
                    <div class="entete-gauche">
                        <p>MINISTERE DES ENSEIGNEMENTS SECONDAIRES</p>
                        <p class="sep">************</p>
                        <p>DELEGATION REGIONALE DE L'OUEST</p>
                        <p class="sep">************</p>
                        <p>DELEGATION DEPARTEMENTALE DU HAUT-NKAM</p>
                        <p class="sep">************</p>
                        <p>CES DE BATCHA; PO-BOX :-PHONE :</p>
                        <p class="sep">************</p>
                        <p>N° D'IMMATRICULATION : 4EH1GSFD101775109</p>
                    </div>
                    <div class="entete-centre">
                        <img src="<%= request.getContextPath() %>/images/logo.png"
                             alt="Logo CES de Batcha"/>
                    </div>
                    <div class="entete-droite">
                        <p>MINISTRY OF SECONDARY EDUCATION</p>
                        <p class="sep">************</p>
                        <p>WEST REGIONAL DELEGATION</p>
                        <p class="sep">************</p>
                        <p>UPPER NKAM DIVISIONAL DELEGATION</p>
                        <p class="sep">************</p>
                        <p>GSS BATCHA; PO-BOX :-PHONE :</p>
                        <p class="sep">************</p>
                        <p>N° D'IMMATRICULATION : 4EH1GSFD101775109</p>
                    </div>
                </div>

                <!-- Titre -->
                <div class="titre-rapport">
                    <h2>Rapport Global — Classe</h2>
                    <p>Année scolaire 2025-2026</p>
                </div>

                <!-- Infos classe -->
                <% if (classe != null) { %>
                <div class="info-classe">
                    <div class="info-item">
                        <label>Classe</label>
                        <p><%= classe.getNom() %></p>
                    </div>
                    <div class="info-item">
                        <label>Niveau</label>
                        <p><%= classe.getNiveau() %></p>
                    </div>
                    <div class="info-item">
                        <label>Année scolaire</label>
                        <p><%= classe.getAnneeScolaire() %></p>
                    </div>
                    <div class="info-item">
                        <label>Total élèves</label>
                        <p><%= eleves != null ? eleves.size() : 0 %></p>
                    </div>
                </div>
                <% } %>

                <!-- Stats par genre -->
                <div class="grille-stats">
                    <div class="stat-carte bg-bleu">
                        <h3><%= eleves != null ? eleves.size() : 0 %></h3>
                        <p>Total élèves</p>
                    </div>
                    <div class="stat-carte bg-cyan">
                        <h3><%= nbGarcons %></h3>
                        <p>♂ Garçons</p>
                    </div>
                    <div class="stat-carte bg-violet">
                        <h3><%= nbFilles %></h3>
                        <p>♀ Filles</p>
                    </div>
                    <div class="stat-carte bg-vert">
                        <h3><%= totalPresents %></h3>
                        <p>Total présences</p>
                    </div>
                </div>

                <!-- Stats globales classe -->
                <div class="grille-stats" style="padding-top:0;">
                    <div class="stat-carte bg-rouge">
                        <h3><%= totalAbsents %></h3>
                        <p>Total absences</p>
                    </div>
                    <div class="stat-carte bg-orange">
                        <h3><%= totalRetards %></h3>
                        <p>Total retards</p>
                    </div>
                </div>

                <!-- Liste élèves -->
                <div class="section-titre">
                    👨‍🎓 Détail des élèves — Assiduité
                </div>

                <% if (eleves == null || eleves.isEmpty()) { %>
                <div class="vide">Aucun élève dans cette classe</div>
                <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Matricule</th>
                            <th>Nom complet</th>
                            <th>Genre</th>
                            <th>Présences</th>
                            <th>Absences</th>
                            <th>Retards</th>
                            <th>Taux présence</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        for (int i = 0; i < eleves.size(); i++) {
                            Eleve e  = eleves.get(i);
                            int[] s  = statsEleves.get(i);
                            int pres = s[0], abs = s[1], ret = s[2];
                            int tot  = pres + abs + ret;
                            double taux = tot > 0
                                ? Math.round((pres * 100.0 / tot) * 10.0) / 10.0
                                : 0;
                        %>
                        <tr>
                            <td><%= i + 1 %></td>
                            <td><strong><%= e.getMatricule() %></strong></td>
                            <td><%= e.getNomComplet() %></td>
                            <td>
                                <% if ("M".equals(e.getGenre())) { %>
                                <span class="badge-genre-m">♂ M</span>
                                <% } else { %>
                                <span class="badge-genre-f">♀ F</span>
                                <% } %>
                            </td>
                            <td style="color:#2e7d32; font-weight:700;"><%= pres %></td>
                            <td style="color:#c62828; font-weight:700;"><%= abs %></td>
                            <td style="color:#e65100; font-weight:700;"><%= ret %></td>
                            <td>
                                <div class="taux-barre">
                                    <div class="mini-barre">
                                        <div class="mini-remplissage"
                                             style="width:<%= taux %>%"></div>
                                    </div>
                                    <span style="font-weight:700;
                                                 color:#1a3c5e;
                                                 font-size:12px;">
                                        <%= taux %>%
                                    </span>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr style="background:#f5f7fa; font-weight:700;">
                            <td colspan="4"
                                style="padding:10px 15px; color:#1a3c5e;">
                                TOTAL CLASSE
                            </td>
                            <td style="color:#2e7d32; padding:10px 15px;">
                                <%= totalPresents %>
                            </td>
                            <td style="color:#c62828; padding:10px 15px;">
                                <%= totalAbsents %>
                            </td>
                            <td style="color:#e65100; padding:10px 15px;">
                                <%= totalRetards %>
                            </td>
                            <td style="padding:10px 15px;"></td>
                        </tr>
                    </tfoot>
                </table>
                <% } %>

            </div>
        </div>
    </div>

</body>
</html>