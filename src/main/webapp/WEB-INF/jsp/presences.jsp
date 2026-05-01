<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%@ page import="cm.cesb.model.Presence" %>
<%@ page import="cm.cesb.model.Classe" %>
<%@ page import="java.util.List" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("login");
        return;
    }
    List<Presence> presences = (List<Presence>) request.getAttribute("presences");
    List<Classe> classes = (List<Classe>) request.getAttribute("classes");
    Classe classeSelectionnee = (Classe) request.getAttribute("classeSelectionnee");
    String dateSelectionnee = (String) request.getAttribute("dateSelectionnee");
    String classeId = (String) request.getAttribute("classeId");
    String succes = request.getParameter("succes");
    String erreur = request.getParameter("erreur");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Présences — CES de Batcha</title>
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
        .carte-filtre {
            background: white;
            border-radius: 10px;
            padding: 20px 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            margin-bottom: 20px;
        }
        .carte-filtre h3 {
            font-size: 15px;
            color: #1a3c5e;
            margin-bottom: 15px;
            font-weight: 700;
        }
        .grille-filtre {
            display: grid;
            grid-template-columns: 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }
        .champ-groupe { display: flex; flex-direction: column; gap: 6px; }
        .champ-groupe label {
            font-size: 13px;
            font-weight: 600;
            color: #37474f;
        }
        .champ-groupe select,
        .champ-groupe input[type="date"] {
            padding: 10px 14px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
            font-size: 14px;
            color: #263238;
            outline: none;
        }
        .btn-charger {
            padding: 10px 20px;
            background: #1565c0;
            color: white;
            border: none;
            border-radius: 7px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
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
            background: #f5f7fa;
        }
        .carte-tableau-entete h3 { font-size: 16px; color: #1a3c5e; }
        .btn-enregistrer-tout {
            padding: 9px 20px;
            background: #2e7d32;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }
        table { width: 100%; border-collapse: collapse; }
        th {
            background: #f5f7fa;
            padding: 12px 10px;
            text-align: left;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #78909c;
            font-weight: 600;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #f5f7fa;
            font-size: 13px;
            color: #37474f;
            vertical-align: middle;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }
        .radio-groupe { display: flex; gap: 6px; }
        .radio-btn {
            padding: 6px 12px;
            border: 2px solid #cfd8dc;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.2s;
            background: white;
        }
        .radio-btn.present  { border-color: #2e7d32; color: #2e7d32; }
        .radio-btn.absent   { border-color: #e53935; color: #e53935; }
        .radio-btn.retard   { border-color: #f57c00; color: #f57c00; }
        .radio-btn.present.selectionne  { background: #2e7d32; color: white; }
        .radio-btn.absent.selectionne   { background: #e53935; color: white; }
        .radio-btn.retard.selectionne   { background: #f57c00; color: white; }
        .badge-detail {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            margin-top: 3px;
            cursor: pointer;
        }
        .badge-detail-rouge { background: #fce4ec; color: #c62828; }
        .badge-detail-orange { background: #fff3e0; color: #e65100; }
        .info-classe {
            background: #e3f2fd;
            border-left: 4px solid #1565c0;
            color: #1a3c5e;
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            font-size: 14px;
            font-weight: 600;
        }
        .vide {
            text-align: center;
            padding: 40px;
            color: #90a4ae;
            font-size: 15px;
        }

        /* ── Modal ── */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.visible {
            display: flex;
        }
        .modal {
            background: white;
            border-radius: 12px;
            width: 500px;
            max-width: 95%;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .modal-entete {
            padding: 18px 20px;
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-entete h3 { font-size: 16px; }
        .modal-entete-absent  { background: linear-gradient(135deg, #c62828, #e53935); }
        .modal-entete-retard  { background: linear-gradient(135deg, #e65100, #f57c00); }
        .modal-corps { padding: 20px; }
        .modal-champ {
            margin-bottom: 15px;
        }
        .modal-champ label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #37474f;
            margin-bottom: 6px;
        }
        .modal-champ select,
        .modal-champ input[type="text"],
        .modal-champ textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
            font-size: 14px;
            color: #263238;
            outline: none;
        }
        .modal-champ textarea {
            height: 70px;
            resize: vertical;
        }
        .modal-champ-inline {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .modal-champ-inline input[type="number"] {
            width: 100px;
            padding: 10px 14px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
            font-size: 14px;
            outline: none;
        }
        .modal-pied {
            padding: 15px 20px;
            background: #f5f7fa;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            border-top: 1px solid #eceff1;
        }
        .btn-confirmer {
            padding: 9px 20px;
            background: #2e7d32;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-annuler-modal {
            padding: 9px 20px;
            background: #eceff1;
            color: #37474f;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
        }
        
        .btn-marquer-present {
    padding: 9px 20px;
    background: #1565c0;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
}
.btn-marquer-present:hover { background: #0d47a1; }

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
            <a href="presences" class="menu-item actif">📋 Présences</a>
            <a href="rapports" class="menu-item">📈 Rapports</a>
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
            <h1>📋 Gestion des Présences</h1>
            <div class="topbar-droite">
                <span class="badge-role"><%= utilisateur.getRole() %></span>
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

            <!-- Filtre -->
            <div class="carte-filtre">
                <h3>🔍 Sélectionner une classe et une date</h3>
                <form method="get" action="presences">
                    <div class="grille-filtre">
                        <div class="champ-groupe">
                            <label>Classe</label>
                            <select name="classeId" required>
                                <option value="">-- Choisir --</option>
                                <% if (classes != null) {
                                    for (Classe c : classes) { %>
                                <option value="<%= c.getId() %>"
                                    <%= c.getId() == (classeId != null ? Integer.parseInt(classeId) : 0) ? "selected" : "" %>>
                                    <%= c.getNom() %>
                                </option>
                                <% }} %>
                            </select>
                        </div>
                        <div class="champ-groupe">
                            <label>Date</label>
                            <input type="date" name="date"
                                   value="<%= dateSelectionnee != null ? dateSelectionnee : java.time.LocalDate.now() %>"
                                   required/>
                        </div>
                        <button type="submit" class="btn-charger">
                            📋 Charger
                        </button>
                    </div>
                </form>
            </div>

            <!-- Tableau -->
            <% if (presences != null && !presences.isEmpty()) { %>

                <% if (classeSelectionnee != null) { %>
                <div class="info-classe">
                    🏛️ Classe : <%= classeSelectionnee.getNom() %>
                    &nbsp;|&nbsp; 📅 Date : <%= dateSelectionnee %>
                    &nbsp;|&nbsp; 👨‍🎓 <%= presences.size() %> élève(s)
                </div>
                <% } %>

                <div class="carte-tableau">
                    <form id="formPresences" method="post" action="presences">
                        <input type="hidden" name="date" value="<%= dateSelectionnee %>"/>
                        <input type="hidden" name="classeId" value="<%= classeId %>"/>

                        <div class="carte-tableau-entete">
    <h3>Liste des élèves</h3>
    <% if (utilisateur.isAdmin()) { %>
    <div style="display:flex; gap:10px;">
        <button type="button"
                class="btn-marquer-present"
                onclick="marquerRestePresent()">
            ✅ Marquer le reste présent
        </button>
        <button type="submit"
                class="btn-enregistrer-tout">
            💾 Enregistrer tout
        </button>
    </div>
    <% } %>
</div>

                        <table>
                            <thead>
                                <tr>
                                    <th>Matricule</th>
                                    <th>Nom complet</th>
                                    <th>Statut</th>
                                    <th>Détails</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (Presence p : presences) { %>
                                <tr>
                                    <td>
                                        <input type="hidden" name="eleveId" value="<%= p.getEleveId() %>"/>
                                        <input type="hidden" name="minutes_<%= p.getEleveId() %>" id="minutes_<%= p.getEleveId() %>" value="<%= p.getMinutesRetard() %>"/>
                                        <input type="hidden" name="motif_<%= p.getEleveId() %>" id="motif_<%= p.getEleveId() %>" value="<%= p.getMotif() != null ? p.getMotif() : "INCONNU" %>"/>
                                        <input type="hidden" name="justifie_<%= p.getEleveId() %>" id="justifie_<%= p.getEleveId() %>" value="<%= p.isJustifie() ? "on" : "" %>"/>
                                        <input type="hidden" name="decision_<%= p.getEleveId() %>" id="decision_<%= p.getEleveId() %>" value="<%= p.getDecisionDisciplinaire() != null ? p.getDecisionDisciplinaire() : "AUCUNE" %>"/>
                                        <input type="hidden" name="note_<%= p.getEleveId() %>" id="note_<%= p.getEleveId() %>" value="<%= p.getNoteAdmin() != null ? p.getNoteAdmin() : "" %>"/>
                                        <input type="hidden" name="statut_<%= p.getEleveId() %>" id="statut_<%= p.getEleveId() %>" value="<%= p.getStatut() != null ? p.getStatut() : "PRESENT" %>"/>
                                        <strong><%= p.getEleveMatricule() %></strong>
                                    </td>
                                    <td><%= p.getEleveNomComplet() %></td>
                                    <td>
                                        <% if (utilisateur.isAdmin()) { %>
                                        <div class="radio-groupe">
                                            <button type="button"
                                                class="radio-btn present <%= (p.getStatut() == null || "PRESENT".equals(p.getStatut())) ? "selectionne" : "" %>"
                                                onclick="setStatut(<%= p.getEleveId() %>,'PRESENT',this)">
                                                ✅ Présent
                                            </button>
                                            <button type="button"
                                                class="radio-btn absent <%= "ABSENT".equals(p.getStatut()) ? "selectionne" : "" %>"
                                                onclick="ouvrirModal(<%= p.getEleveId() %>,'ABSENT',this,'<%= p.getEleveNomComplet() %>')">
                                                ❌ Absent
                                            </button>
                                            <button type="button"
                                                class="radio-btn retard <%= "RETARD".equals(p.getStatut()) ? "selectionne" : "" %>"
                                                onclick="ouvrirModal(<%= p.getEleveId() %>,'RETARD',this,'<%= p.getEleveNomComplet() %>')">
                                                ⏰ Retard
                                            </button>
                                        </div>
                                        <% } else { %>
                                            <%= p.getStatut() != null ? p.getStatut() : "-" %>
                                        <% } %>
                                    </td>
                                    <td id="detail_<%= p.getEleveId() %>">
                                        <% if ("ABSENT".equals(p.getStatut())) { %>
                                            <span class="badge-detail badge-detail-rouge"
                                                  onclick="ouvrirModal(<%= p.getEleveId() %>,'ABSENT',null,'<%= p.getEleveNomComplet() %>')">
                                                ✏️ <%= p.getMotif() != null ? p.getMotif() : "Inconnu" %>
                                                | <%= p.isJustifie() ? "Justifié" : "Non justifié" %>
                                                <% if (p.getDecisionDisciplinaire() != null && !"AUCUNE".equals(p.getDecisionDisciplinaire())) { %>
                                                | <%= p.getDecisionDisciplinaire().replace("_"," ") %>
                                                <% } %>
                                            </span>
                                        <% } else if ("RETARD".equals(p.getStatut())) { %>
                                            <span class="badge-detail badge-detail-orange"
                                                  onclick="ouvrirModal(<%= p.getEleveId() %>,'RETARD',null,'<%= p.getEleveNomComplet() %>')">
                                                ✏️ <%= p.getMinutesRetard() %> min
                                                | <%= p.getMotif() != null ? p.getMotif() : "Inconnu" %>
                                            </span>
                                        <% } else { %>
                                            <span style="color:#90a4ae; font-size:12px;">—</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </form>
                </div>

            <% } else if (presences != null && presences.isEmpty()) { %>
                <div class="carte-tableau">
                    <div class="vide">Aucun élève actif dans cette classe.</div>
                </div>
            <% } %>

        </div>
    </div>

    <!-- ── Modal Absent / Retard ── -->
    <div class="modal-overlay" id="modalOverlay">
        <div class="modal">
            <div class="modal-entete" id="modalEntete">
                <h3 id="modalTitre">Détails</h3>
                <button type="button" class="btn-annuler-modal"
                        onclick="fermerModal()"
                        style="background:rgba(255,255,255,0.2);
                               color:white; border-radius:50%;
                               width:28px; height:28px; font-size:16px;">
                    ✕
                </button>
            </div>
           <div class="modal-corps">
    <p id="modalEleve" style="font-weight:700; color:#1a3c5e;
       font-size:15px; margin-bottom:15px;"></p>

    <!-- Minutes retard -->
    <div class="modal-champ" id="champMinutes" style="display:none;">
        <label>⏱️ Minutes de retard</label>
        <div class="modal-champ-inline">
            <input type="number" id="modalMinutes"
                   min="0" max="120" value="0"
                   placeholder="Ex: 15"/>
            <span style="font-size:13px; color:#78909c;">minutes</span>
        </div>
    </div>

    <!-- Motif -->
    <div class="modal-champ">
        <label>📋 Motif</label>
        <select id="modalMotif" onchange="afficherAutreMotif()">
            <option value="INCONNU">Inconnu</option>
            <option value="MALADIE">Maladie</option>
            <option value="FAMILIAL">Familial</option>
            <option value="EVENEMENT">Événement</option>
            <option value="AUTRE">Autre (préciser)</option>
        </select>
    </div>

    <!-- Autre motif personnalisé -->
    <div class="modal-champ" id="champAutreMotif" style="display:none;">
        <label>✏️ Précisez le motif</label>
        <input type="text" id="modalAutreMotif"
               placeholder="Saisissez le motif..."/>
    </div>

    <!-- Justifié -->
    <div class="modal-champ">
        <label style="display:flex; align-items:center; gap:10px; cursor:pointer;">
            <input type="checkbox" id="modalJustifie"
                   style="width:18px; height:18px;"/>
            ✅ Absence / Retard justifié
        </label>
    </div>

    <!-- Décision disciplinaire -->
    <div class="modal-champ">
        <label>⚖️ Décision disciplinaire</label>
        <select id="modalDecision" onchange="afficherAutreDecision()">
            <option value="AUCUNE">Aucune</option>
            <option value="AVERTISSEMENT_ORAL">Avertissement oral</option>
            <option value="AVERTISSEMENT_ECRIT">Avertissement écrit</option>
            <option value="CONVOCATION_PARENT">Convocation parent</option>
            <option value="RENVOI_TEMPORAIRE">Renvoi temporaire</option>
            <option value="CONSEIL_DISCIPLINE">Conseil de discipline</option>
            <option value="AUTRE_DECISION">Autre décision (préciser)</option>
        </select>
    </div>

    <!-- Autre décision personnalisée -->
    <div class="modal-champ" id="champAutreDecision" style="display:none;">
        <label>✏️ Précisez la décision</label>
        <input type="text" id="modalAutreDecision"
               placeholder="Saisissez la décision..."/>
    </div>

    <!-- Note -->
    <div class="modal-champ">
        <label>📝 Note</label>
        <textarea id="modalNote"
                  placeholder="Remarque ou observation..."></textarea>
    </div>
</div>

                <!-- Motif -->
                <div class="modal-champ">
                    <label>📋 Motif</label>
                    <select id="modalMotif">
                        <option value="INCONNU">Inconnu</option>
                        <option value="MALADIE">Maladie</option>
                        <option value="FAMILIAL">Familial</option>
                        <option value="EVENEMENT">Événement</option>
                        <option value="AUTRE">Autre</option>
                    </select>
                </div>

                <!-- Justifié -->
                <div class="modal-champ">
                    <label style="display:flex; align-items:center; gap:10px; cursor:pointer;">
                        <input type="checkbox" id="modalJustifie"
                               style="width:18px; height:18px;"/>
                        ✅ Absence / Retard justifié
                    </label>
                </div>

                <!-- Décision disciplinaire -->
                <div class="modal-champ">
                    <label>⚖️ Décision disciplinaire</label>
                    <select id="modalDecision">
                        <option value="AUCUNE">Aucune</option>
                        <option value="AVERTISSEMENT_ORAL">Avertissement oral</option>
                        <option value="AVERTISSEMENT_ECRIT">Avertissement écrit</option>
                        <option value="CONVOCATION_PARENT">Convocation parent</option>
                        <option value="RENVOI_TEMPORAIRE">Renvoi temporaire</option>
                        <option value="CONSEIL_DISCIPLINE">Conseil de discipline</option>
                    </select>
                </div>

                <!-- Note -->
                <div class="modal-champ">
                    <label>📝 Note</label>
                    <textarea id="modalNote" placeholder="Remarque ou observation..."></textarea>
                </div>
            </div>
            <div class="modal-pied">
                <button type="button" class="btn-annuler-modal"
                        onclick="fermerModal()">Annuler</button>
                <button type="button" class="btn-confirmer"
                        onclick="confirmerModal()">✅ Confirmer</button>
            </div>
        </div>
    </div>

    <script>
    var eleveIdCourant  = null;
    var statutCourant   = null;
    var btnCourant      = null;

    function afficherAutreMotif() {
        var motif = document.getElementById('modalMotif').value;
        var champ = document.getElementById('champAutreMotif');
        champ.style.display = motif === 'AUTRE' ? 'block' : 'none';
        if (motif !== 'AUTRE') {
            document.getElementById('modalAutreMotif').value = '';
        }
    }

    function afficherAutreDecision() {
        var decision = document.getElementById('modalDecision').value;
        var champ    = document.getElementById('champAutreDecision');
        champ.style.display = decision === 'AUTRE_DECISION' ? 'block' : 'none';
        if (decision !== 'AUTRE_DECISION') {
            document.getElementById('modalAutreDecision').value = '';
        }
    }

    function getMotifFinal() {
        var motif = document.getElementById('modalMotif').value;
        if (motif === 'AUTRE') {
            var autreMotif = document.getElementById('modalAutreMotif').value.trim();
            return autreMotif !== '' ? autreMotif : 'AUTRE';
        }
        return motif;
    }

    function getDecisionFinal() {
        var decision = document.getElementById('modalDecision').value;
        if (decision === 'AUTRE_DECISION') {
            var autreDecision = document.getElementById('modalAutreDecision').value.trim();
            return autreDecision !== '' ? autreDecision : 'AUCUNE';
        }
        return decision;
    }

    function ouvrirModal(eleveId, statut, btn, nomEleve) {
        eleveIdCourant = eleveId;
        statutCourant  = statut;
        btnCourant     = btn;

        var entete = document.getElementById('modalEntete');
        var titre  = document.getElementById('modalTitre');
        entete.className = 'modal-entete modal-entete-' + statut.toLowerCase();
        titre.textContent = statut === 'ABSENT' ? '❌ Marquer Absent' : '⏰ Marquer Retard';
        document.getElementById('modalEleve').textContent = '👤 ' + nomEleve;

        document.getElementById('champMinutes').style.display =
            statut === 'RETARD' ? 'block' : 'none';

        // Remplir valeurs existantes
        document.getElementById('modalMinutes').value =
            document.getElementById('minutes_' + eleveId).value || 0;

        // Motif
        var motifSauve = document.getElementById('motif_' + eleveId).value || 'INCONNU';
        var selectMotif = document.getElementById('modalMotif');
        var motifTrouve = false;
        for (var i = 0; i < selectMotif.options.length; i++) {
            if (selectMotif.options[i].value === motifSauve) {
                motifTrouve = true;
                break;
            }
        }
        if (motifTrouve) {
            selectMotif.value = motifSauve;
            document.getElementById('modalAutreMotif').value = '';
            document.getElementById('champAutreMotif').style.display = 'none';
        } else {
            selectMotif.value = 'AUTRE';
            document.getElementById('modalAutreMotif').value = motifSauve;
            document.getElementById('champAutreMotif').style.display = 'block';
        }

        // Décision
        var decisionSauve = document.getElementById('decision_' + eleveId).value || 'AUCUNE';
        var selectDecision = document.getElementById('modalDecision');
        var decisionTrouvee = false;
        for (var j = 0; j < selectDecision.options.length; j++) {
            if (selectDecision.options[j].value === decisionSauve) {
                decisionTrouvee = true;
                break;
            }
        }
        if (decisionTrouvee) {
            selectDecision.value = decisionSauve;
            document.getElementById('modalAutreDecision').value = '';
            document.getElementById('champAutreDecision').style.display = 'none';
        } else {
            selectDecision.value = 'AUTRE_DECISION';
            document.getElementById('modalAutreDecision').value = decisionSauve;
            document.getElementById('champAutreDecision').style.display = 'block';
        }

        document.getElementById('modalJustifie').checked =
            document.getElementById('justifie_' + eleveId).value === 'on';
        document.getElementById('modalNote').value =
            document.getElementById('note_' + eleveId).value || '';

        document.getElementById('modalOverlay').classList.add('visible');
    }

    function fermerModal() {
        document.getElementById('modalOverlay').classList.remove('visible');
        eleveIdCourant = null;
        statutCourant  = null;
        btnCourant     = null;
    }

    function confirmerModal() {
        if (!eleveIdCourant) return;

        var minutes  = document.getElementById('modalMinutes').value;
        var motif    = getMotifFinal();
        var justifie = document.getElementById('modalJustifie').checked;
        var decision = getDecisionFinal();
        var note     = document.getElementById('modalNote').value;

        document.getElementById('statut_'   + eleveIdCourant).value = statutCourant;
        document.getElementById('minutes_'  + eleveIdCourant).value = statutCourant === 'RETARD' ? minutes : 0;
        document.getElementById('motif_'    + eleveIdCourant).value = motif;
        document.getElementById('justifie_' + eleveIdCourant).value = justifie ? 'on' : '';
        document.getElementById('decision_' + eleveIdCourant).value = decision;
        document.getElementById('note_'     + eleveIdCourant).value = note;

        var row = document.querySelector(
            'input[name="eleveId"][value="' + eleveIdCourant + '"]').closest('tr');
        var boutons = row.querySelectorAll('.radio-btn');
        boutons.forEach(function(b) { b.classList.remove('selectionne'); });

        if (btnCourant) {
            btnCourant.classList.add('selectionne');
        } else {
            boutons.forEach(function(b) {
                if ((statutCourant === 'ABSENT' && b.classList.contains('absent')) ||
                    (statutCourant === 'RETARD' && b.classList.contains('retard'))) {
                    b.classList.add('selectionne');
                }
            });
        }

        var nomEleve = row.cells[1].textContent.trim();
        var detail   = document.getElementById('detail_' + eleveIdCourant);
        var badge    = '';
        if (statutCourant === 'ABSENT') {
            badge = '<span class="badge-detail badge-detail-rouge" ' +
                    'onclick="ouvrirModal(' + eleveIdCourant + ',\'ABSENT\',null,\'' +
                    nomEleve + '\')">' +
                    '✏️ ' + motif +
                    ' | ' + (justifie ? 'Justifié' : 'Non justifié') +
                    (decision !== 'AUCUNE' ? ' | ' + decision.replace(/_/g,' ') : '') +
                    '</span>';
        } else if (statutCourant === 'RETARD') {
            badge = '<span class="badge-detail badge-detail-orange" ' +
                    'onclick="ouvrirModal(' + eleveIdCourant + ',\'RETARD\',null,\'' +
                    nomEleve + '\')">' +
                    '✏️ ' + minutes + ' min | ' + motif +
                    '</span>';
        }
        detail.innerHTML = badge;

        fermerModal();
    }

    function setStatut(eleveId, statut, btn) {
        document.getElementById('statut_'   + eleveId).value = statut;
        document.getElementById('minutes_'  + eleveId).value = 0;
        document.getElementById('decision_' + eleveId).value = 'AUCUNE';

        var row = btn.closest('tr');
        var boutons = row.querySelectorAll('.radio-btn');
        boutons.forEach(function(b) { b.classList.remove('selectionne'); });
        btn.classList.add('selectionne');

        document.getElementById('detail_' + eleveId).innerHTML =
            '<span style="color:#90a4ae; font-size:12px;">—</span>';
    }

    document.getElementById('modalOverlay').addEventListener('click', function(e) {
        if (e.target === this) fermerModal();
    });
    
    function marquerRestePresent() {
        // Récupérer tous les élèves
        var eleveIds = document.querySelectorAll(
                'input[name="eleveId"]');

        eleveIds.forEach(function(input) {
            var eleveId = input.value;
            var statutInput = document.getElementById(
                    'statut_' + eleveId);

            // Si le statut n'est pas encore défini
            // ou est déjà PRESENT → ne pas changer
            // Si ABSENT ou RETARD → ne pas changer
            // Sinon → marquer PRESENT
            if (statutInput.value === 'PRESENT'
                    || statutInput.value === '') {

                // Trouver la ligne de cet élève
                var row = input.closest('tr');
                var boutons = row.querySelectorAll('.radio-btn');

                // Mettre à jour le statut
                statutInput.value = 'PRESENT';

                // Mettre à jour les boutons visuellement
                boutons.forEach(function(b) {
                    b.classList.remove('selectionne');
                });

                // Sélectionner le bouton Présent
                var btnPresent = row.querySelector(
                        '.radio-btn.present');
                if (btnPresent) {
                    btnPresent.classList.add('selectionne');
                }

                // Vider le badge détail
                var detail = document.getElementById(
                        'detail_' + eleveId);
                if (detail) {
                    detail.innerHTML =
                        '<span style="color:#90a4ae;'
                        + 'font-size:12px;">—</span>';
                }
            }
        });

        // Message de confirmation
        alert('✅ Tous les élèves sans statut ont été'
            + ' marqués présents !\n'
            + 'Cliquez sur "Enregistrer tout" pour sauvegarder.');
    }
    </script>

</body>
</html>