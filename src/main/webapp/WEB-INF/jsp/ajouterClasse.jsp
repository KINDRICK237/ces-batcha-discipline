<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cm.cesb.model.Utilisateur" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) { response.sendRedirect("login"); return; }
    if (!utilisateur.isAdmin()) { response.sendRedirect("dashboard"); return; }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ajouter une classe — CES de Batcha</title>
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
        .carte-form {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
            max-width: 500px;
        }
        .carte-form-entete {
            background: linear-gradient(135deg, #1a3c5e, #1565c0);
            color: white;
            padding: 20px 25px;
        }
        .carte-form-entete h3 { font-size: 17px; }
        .carte-form-entete p  { font-size: 13px; opacity: 0.85; margin-top: 3px; }
        .carte-form-corps { padding: 25px; }
        .champ-groupe {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 18px;
        }
        .champ-groupe label {
            font-size: 13px;
            font-weight: 600;
            color: #37474f;
        }
        .champ-groupe input,
        .champ-groupe select {
            padding: 10px 14px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
            font-size: 14px;
            color: #263238;
            outline: none;
            transition: border-color 0.2s;
        }
        .champ-groupe input:focus,
        .champ-groupe select:focus {
            border-color: #1565c0;
            box-shadow: 0 0 0 3px rgba(21,101,192,0.12);
        }
        .barre-boutons {
            display: flex;
            gap: 12px;
            margin-top: 10px;
            padding-top: 20px;
            border-top: 1px solid #eceff1;
        }
        .btn-enregistrer {
            padding: 11px 25px;
            background: #2e7d32;
            color: white;
            border: none;
            border-radius: 7px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-enregistrer:hover { background: #1b5e20; }
        .btn-annuler {
            padding: 11px 25px;
            background: #eceff1;
            color: #37474f;
            border: none;
            border-radius: 7px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-annuler:hover { background: #cfd8dc; }
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
            <h1>➕ Ajouter une classe</h1>
            <div class="topbar-droite">
                <span class="badge-role">ADMIN</span>
                <a href="logout" class="btn-deconnexion">🚪 Déconnexion</a>
            </div>
        </div>

        <div class="zone-principale">
            <div class="carte-form">
                <div class="carte-form-entete">
                    <h3>🏛️ Nouvelle classe</h3>
                    <p>Remplissez les informations de la classe</p>
                </div>
                <div class="carte-form-corps">
                    <form method="post" action="classes">
                        <input type="hidden" name="action" value="ajouter"/>

                        <div class="champ-groupe">
                            <label>Nom de la classe *</label>
                            <input type="text" name="nom"
                                   placeholder="Ex: 6ème A, 5ème B..."
                                   required/>
                        </div>

                        <div class="champ-groupe">
                            <label>Niveau *</label>
                            <select name="niveau" required>
                                <option value="">-- Choisir --</option>
                                <option value="6ème">6ème</option>
                                <option value="5ème">5ème</option>
                                <option value="4ème">4ème</option>
                                <option value="3ème">3ème</option>
                            </select>
                        </div>

                        <div class="champ-groupe">
                            <label>Année scolaire *</label>
                            <select name="anneeScolaire" required>
                                <option value="2024-2025">2024-2025</option>
                                <option value="2025-2026">2025-2026</option>
                                <option value="2026-2027">2026-2027</option>
                            </select>
                        </div>

                        <div class="barre-boutons">
                            <button type="submit" class="btn-enregistrer">
                                ✅ Enregistrer
                            </button>
                            <a href="classes" class="btn-annuler">
                                ❌ Annuler
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>