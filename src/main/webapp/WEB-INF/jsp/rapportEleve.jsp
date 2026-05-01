<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Eleve" %>
<%@ page import="cm.cesb.model.Presence" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }
    Eleve eleve             = (Eleve) request.getAttribute("eleve");
    List<Presence> presences = (List<Presence>) request.getAttribute("presences");
    int totalJours          = (int) request.getAttribute("totalJours");
    int nbPresents          = (int) request.getAttribute("nbPresents");
    int nbAbsents           = (int) request.getAttribute("nbAbsents");
    int nbRetards           = (int) request.getAttribute("nbRetards");
    int totalMinutes        = (int) request.getAttribute("totalMinutes");
    int absJustifies        = (int) request.getAttribute("absJustifies");
    int absNonJustifies     = (int) request.getAttribute("absNonJustifies");
    double tauxPresence     = (double) request.getAttribute("tauxPresence");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Élève — CES de Batcha</title>
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

        /* ── Zone imprimable ── */
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

        /* ── Titre rapport ── */
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
        .titre-rapport p {
            font-size: 13px;
            color: #78909c;
        }

        /* ── Infos élève ── */
        .info-eleve {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
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

        /* ── Statistiques ── */
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
        .stat-carte h3 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .stat-carte p {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .bg-bleu   { background: #e3f2fd; color: #1565c0; }
        .bg-vert   { background: #e8f5e9; color: #2e7d32; }
        .bg-rouge  { background: #fce4ec; color: #c62828; }
        .bg-orange { background: #fff3e0; color: #e65100; }

        /* ── Taux de présence ── */
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
            transition: width 0.5s;
        }
        .taux-valeur {
            font-size: 18px;
            font-weight: 700;
            color: #1a3c5e;
            white-space: nowrap;
        }

        /* ── Tableau historique ── */
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

        .badge-statut {
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .statut-present  { background: #e8f5e9; color: #2e7d32; }
        .statut-absent   { background: #fce4ec; color: #c62828; }
        .statut-retard   { background: #fff3e0; color: #e65100; }

        .badge-decision {
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            background: #f3e5f5;
            color: #6a1b9a;
        }

        .vide {
            text-align: center;
            padding: 30px;
            color: #90a4ae;
            font-size: 14px;
        }

        /* ── Impression ── */
        @media print {
            .sidebar,
            .topbar,
            .btn-imprimer,
            .btn-retour,
            .btn-deconnexion { display: none !important; }
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
            <h1>📊 Rapport individuel</h1>
            <div class="topbar-droite">
                <a href="rapports" class="btn-retour">← Retour</a>
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
                    <h2>Rapport d'Assiduité — Élève</h2>
                    <p>Année scolaire 2025-2026</p>
                </div>

                <!-- Infos élève -->
                <% if (eleve != null) { %>
                <div class="info-eleve">
                    <div class="info-item">
                        <label>Matricule</label>
                        <p><%= eleve.getMatricule() %></p>
                    </div>
                    <div class="info-item">
                        <label>Nom complet</label>
                        <p><%= eleve.getNomComplet() %></p>
                    </div>
                    <div class="info-item">
                        <label>Classe</label>
                        <p><%= eleve.getClasseNom() %></p>
                    </div>
                    <div class="info-item">
                        <label>Genre</label>
                        <p><%= "M".equals(eleve.getGenre()) ? "Masculin" : "Féminin" %></p>
                    </div>
                    <div class="info-item">
                        <label>Statut</label>
                        <p><%= eleve.getStatut() %></p>
                    </div>
                    <div class="info-item">
                        <label>Parent</label>
                        <p><%= eleve.getNomParent() != null ? eleve.getNomParent() : "-" %></p>
                    </div>
                </div>
                <% } %>

                <!-- Statistiques -->
                <div class="grille-stats">
                    <div class="stat-carte bg-bleu">
                        <h3><%= totalJours %></h3>
                        <p>Total jours</p>
                    </div>
                    <div class="stat-carte bg-vert">
                        <h3><%= nbPresents %></h3>
                        <p>Présences</p>
                    </div>
                    <div class="stat-carte bg-rouge">
                        <h3><%= nbAbsents %></h3>
                        <p>Absences</p>
                    </div>
                    <div class="stat-carte bg-orange">
                        <h3><%= nbRetards %></h3>
                        <p>Retards</p>
                    </div>
                </div>

                <!-- Détails absences -->
                <div class="grille-stats" style="padding-top:0;">
                    <div class="stat-carte bg-vert">
                        <h3><%= absJustifies %></h3>
                        <p>Abs. justifiées</p>
                    </div>
                    <div class="stat-carte bg-rouge">
                        <h3><%= absNonJustifies %></h3>
                        <p>Abs. non justifiées</p>
                    </div>
                    <div class="stat-carte bg-orange">
                        <h3><%= totalMinutes %></h3>
                        <p>Minutes de retard</p>
                    </div>
                    <div class="stat-carte bg-bleu">
                        <h3><%= tauxPresence %>%</h3>
                        <p>Taux présence</p>
                    </div>
                </div>

                <!-- Barre de progression -->
                <div class="taux-section">
                    <span class="taux-label">Taux de présence :</span>
                    <div class="barre-progression">
                        <div class="barre-remplissage"
                             style="width: <%= tauxPresence %>%">
                        </div>
                    </div>
                    <span class="taux-valeur"><%= tauxPresence %>%</span>
                </div>

                <!-- Historique -->
                <div class="section-titre">
                    📅 Historique des présences
                </div>
                <% if (presences == null || presences.isEmpty()) { %>
                <div class="vide">Aucun enregistrement trouvé</div>
                <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Statut</th>
                            <th>Min. retard</th>
                            <th>Motif</th>
                            <th>Justifié</th>
                            <th>Décision</th>
                            <th>Note</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Presence p : presences) { %>
                        <tr>
                            <td><%= p.getDatePresence() %></td>
                            <td>
                                <span class="badge-statut statut-<%= p.getStatut().toLowerCase() %>">
                                    <%= p.getStatut() %>
                                </span>
                            </td>
                            <td><%= p.getMinutesRetard() > 0 ? p.getMinutesRetard() + " min" : "-" %></td>
                            <td><%= p.getMotif() != null ? p.getMotif() : "-" %></td>
                            <td><%= p.isJustifie() ? "✅ Oui" : "❌ Non" %></td>
                            <td>
                                <% if (p.getDecisionDisciplinaire() != null && !"AUCUNE".equals(p.getDecisionDisciplinaire())) { %>
                                <span class="badge-decision">
                                    <%= p.getDecisionDisciplinaire().replace("_", " ") %>
                                </span>
                                <% } else { %>-<% } %>
                            </td>
                            <td><%= p.getNoteAdmin() != null ? p.getNoteAdmin() : "-" %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>

            </div>
        </div>
    </div>

</body>
</html>