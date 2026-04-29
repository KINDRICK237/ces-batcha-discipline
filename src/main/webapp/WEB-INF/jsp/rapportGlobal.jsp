<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Classe" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }

    String periode       = (String) request.getAttribute("periode");
    String debut         = (String) request.getAttribute("debut");
    String fin           = (String) request.getAttribute("fin");
    int[] statsGlobales  = (int[]) request.getAttribute("statsGlobales");
    List<Classe> classes = (List<Classe>) request.getAttribute("classes");
    int[][] statsClasses = (int[][]) request.getAttribute("statsClasses");

    int totalPresents = statsGlobales[0];
    int totalAbsents  = statsGlobales[1];
    int totalRetards  = statsGlobales[2];
    int totalMinutes  = statsGlobales[3];
    int totalJours    = totalPresents + totalAbsents + totalRetards;
    double tauxGlobal = totalJours > 0
        ? Math.round((totalPresents * 100.0 / totalJours) * 10.0) / 10.0 : 0;

    String libellePeriode = "hebdomadaire".equals(periode) ? "Hebdomadaire"
                          : "mensuel".equals(periode) ? "Mensuel" : "Annuel";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Global — CES de Batcha</title>
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

        /* ── Sélecteur période ── */
        .selecteur-periode {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .btn-periode {
            padding: 9px 20px;
            border: 2px solid #cfd8dc;
            border-radius: 7px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            color: #37474f;
            background: white;
            transition: all 0.2s;
        }
        .btn-periode:hover { border-color: #1565c0; color: #1565c0; }
        .btn-periode.actif {
            background: #1565c0;
            color: white;
            border-color: #1565c0;
        }

        .zone-impression {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
        }

        /* ── En-tête officiel ── */
        .entete-officiel {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 25px;
            border-bottom: 2px solid #1a3c5e;
            font-family: 'Times New Roman', serif;
        }
        .entete-gauche,
        .entete-droite {
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

        /* ── Stats globales ── */
        .grille-stats {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 15px;
            padding: 20px 25px;
            border-bottom: 1px solid #eceff1;
        }
        .stat-carte {
            text-align: center;
            padding: 15px;
            border-radius: 8px;
        }
        .stat-carte h3 {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .stat-carte p {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .bg-bleu   { background: #e3f2fd; color: #1565c0; }
        .bg-vert   { background: #e8f5e9; color: #2e7d32; }
        .bg-rouge  { background: #fce4ec; color: #c62828; }
        .bg-orange { background: #fff3e0; color: #e65100; }
        .bg-violet { background: #f3e5f5; color: #6a1b9a; }

        /* ── Taux global ── */
        .taux-section {
            padding: 15px 25px;
            border-bottom: 1px solid #eceff1;
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .taux-label {
            font-size: 14px;
            font-weight: 600;
            color: #37474f;
            white-space: nowrap;
        }
        .barre-progression {
            flex: 1;
            height: 20px;
            background: #eceff1;
            border-radius: 10px;
            overflow: hidden;
        }
        .barre-remplissage {
            height: 100%;
            border-radius: 10px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
        }
        .taux-valeur {
            font-size: 18px;
            font-weight: 700;
            color: #1a3c5e;
            white-space: nowrap;
        }

        /* ── Tableau par classe ── */
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
            padding: 12px 15px;
            border-bottom: 1px solid #f5f7fa;
            font-size: 13px;
            color: #37474f;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }
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

        @media print {
            .sidebar,
            .topbar,
            .btn-imprimer,
            .btn-retour,
            .btn-deconnexion,
            .selecteur-periode { display: none !important; }
            .contenu { margin-left: 0 !important; }
            .zone-principale { padding: 0 !important; }
            .zone-impression {
                box-shadow: none !important;
                border-radius: 0 !important;
            }
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
            <h1>🌍 Rapport Global</h1>
            <div class="topbar-droite">
    <a href="rapports" class="btn-retour">← Retour</a>
    <a href="exportPdf?type=global&periode=<%= periode %>"
       class="btn-pdf">
        📄 PDF
    </a>
    <a href="exportExcel?type=global&periode=<%= periode %>"
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

            <!-- Sélecteur période -->
            <div class="selecteur-periode">
                <a href="rapports?type=global&periode=hebdomadaire"
                   class="btn-periode <%= "hebdomadaire".equals(periode) ? "actif" : "" %>">
                    📅 Hebdomadaire
                </a>
                <a href="rapports?type=global&periode=mensuel"
                   class="btn-periode <%= "mensuel".equals(periode) ? "actif" : "" %>">
                    📆 Mensuel
                </a>
                <a href="rapports?type=global&periode=annuel"
                   class="btn-periode <%= "annuel".equals(periode) ? "actif" : "" %>">
                    🗓️ Annuel
                </a>
            </div>

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
                    <h2>Rapport Global <%= libellePeriode %> — Toutes Classes</h2>
                    <p>Période : du <%= debut %> au <%= fin %></p>
                </div>

                <!-- Stats globales -->
                <div class="grille-stats">
                    <div class="stat-carte bg-bleu">
                        <h3><%= totalJours %></h3>
                        <p>Total enregistrements</p>
                    </div>
                    <div class="stat-carte bg-vert">
                        <h3><%= totalPresents %></h3>
                        <p>Présences</p>
                    </div>
                    <div class="stat-carte bg-rouge">
                        <h3><%= totalAbsents %></h3>
                        <p>Absences</p>
                    </div>
                    <div class="stat-carte bg-orange">
                        <h3><%= totalRetards %></h3>
                        <p>Retards</p>
                    </div>
                    <div class="stat-carte bg-violet">
                        <h3><%= totalMinutes %></h3>
                        <p>Min. retard</p>
                    </div>
                </div>

                <!-- Taux global -->
                <div class="taux-section">
                    <span class="taux-label">Taux de présence global :</span>
                    <div class="barre-progression">
                        <div class="barre-remplissage"
                             style="width:<%= tauxGlobal %>%"></div>
                    </div>
                    <span class="taux-valeur"><%= tauxGlobal %>%</span>
                </div>

                <!-- Tableau par classe -->
                <div class="section-titre">
                    🏛️ Détail par classe
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Classe</th>
                            <th>Niveau</th>
                            <th>Présences</th>
                            <th>Absences</th>
                            <th>Retards</th>
                            <th>Min. retard</th>
                            <th>Taux présence</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (classes != null) {
                            for (int i = 0; i < classes.size(); i++) {
                                Classe c = classes.get(i);
                                int[] s  = statsClasses[i];
                                int pres = s[0], abs = s[1], ret = s[2], min = s[3];
                                int tot  = pres + abs + ret;
                                double taux = tot > 0
                                    ? Math.round((pres * 100.0 / tot) * 10.0) / 10.0
                                    : 0;
                        %>
                        <tr>
                            <td><%= i + 1 %></td>
                            <td><strong><%= c.getNom() %></strong></td>
                            <td><%= c.getNiveau() %></td>
                            <td style="color:#2e7d32; font-weight:700;">
                                <%= pres %>
                            </td>
                            <td style="color:#c62828; font-weight:700;">
                                <%= abs %>
                            </td>
                            <td style="color:#e65100; font-weight:700;">
                                <%= ret %>
                            </td>
                            <td><%= min %> min</td>
                            <td>
                                <div class="taux-barre">
                                    <div class="mini-barre">
                                        <div class="mini-remplissage"
                                             style="width:<%= taux %>%"></div>
                                    </div>
                                    <span style="font-weight:700;
                                                 color:#1a3c5e;
                                                 font-size:12px;
                                                 white-space:nowrap;">
                                        <%= taux %>%
                                    </span>
                                </div>
                            </td>
                        </tr>
                        <% }} %>
                    </tbody>
                    <tfoot>
                        <tr style="background:#f5f7fa; font-weight:700;">
                            <td colspan="3"
                                style="padding:12px 15px; color:#1a3c5e;">
                                TOTAL GÉNÉRAL
                            </td>
                            <td style="color:#2e7d32; padding:12px 15px;">
                                <%= totalPresents %>
                            </td>
                            <td style="color:#c62828; padding:12px 15px;">
                                <%= totalAbsents %>
                            </td>
                            <td style="color:#e65100; padding:12px 15px;">
                                <%= totalRetards %>
                            </td>
                            <td style="padding:12px 15px;">
                                <%= totalMinutes %> min
                            </td>
                            <td style="padding:12px 15px;
                                       color:#1a3c5e; font-weight:700;">
                                <%= tauxGlobal %>%
                            </td>
                        </tr>
                    </tfoot>
                </table>

            </div>
        </div>
    </div>

</body>
</html>