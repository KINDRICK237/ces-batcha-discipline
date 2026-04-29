<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion — CES de Batcha</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #1a3c5e 0%, #2e7d32 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .carte {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 420px;
            overflow: hidden;
        }

        .carte-entete {
            background: linear-gradient(135deg, #1a3c5e, #1565c0);
            color: white;
            text-align: center;
            padding: 35px 30px 25px;
        }

        .carte-entete .icone {
            font-size: 52px;
            display: block;
            margin-bottom: 10px;
        }

        .carte-entete h1 {
            font-size: 22px;
            font-weight: 700;
        }

        .carte-entete p {
            font-size: 13px;
            opacity: 0.85;
            margin-top: 5px;
        }

        .carte-corps {
            padding: 30px 35px 35px;
        }

        .alerte-erreur {
            background: #fdecea;
            border-left: 4px solid #e53935;
            color: #b71c1c;
            padding: 12px 15px;
            border-radius: 6px;
            font-size: 14px;
            margin-bottom: 20px;
        }

        .champ-groupe {
            margin-bottom: 20px;
        }

        .champ-groupe label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #37474f;
            margin-bottom: 7px;
        }

        .champ-groupe input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #cfd8dc;
            border-radius: 8px;
            font-size: 14px;
            color: #263238;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .champ-groupe input:focus {
            border-color: #1565c0;
            box-shadow: 0 0 0 3px rgba(21,101,192,0.15);
        }

        .btn-connexion {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #1a3c5e, #1565c0);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s, transform 0.1s;
            margin-top: 5px;
        }

        .btn-connexion:hover {
            opacity: 0.92;
            transform: translateY(-1px);
        }

        .carte-pied {
            text-align: center;
            padding: 15px;
            background: #f5f7fa;
            border-top: 1px solid #eceff1;
            font-size: 12px;
            color: #90a4ae;
        }
    </style>
</head>
<body>

    <div class="carte">

        <div class="carte-entete">
            <span class="icone">🏫</span>
            <h1>CES de Batcha</h1>
            <p>Système de Suivi Disciplinaire</p>
        </div>

        <div class="carte-corps">

            <% if (request.getAttribute("erreur") != null) { %>
                <div class="alerte-erreur">
                    ⚠️ <%= request.getAttribute("erreur") %>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/login" method="post">

                <div class="champ-groupe">
                    <label for="email">Adresse email</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        placeholder="exemple@cesbatcha.cm"
                        value="<%= request.getParameter("email") != null
                                    ? request.getParameter("email") : "" %>"
                        required
                        autofocus
                    />
                </div>

                <div class="champ-groupe">
                    <label for="motDePasse">Mot de passe</label>
                    <input
                        type="password"
                        id="motDePasse"
                        name="motDePasse"
                        placeholder="Votre mot de passe"
                        required
                    />
                </div>

                <button type="submit" class="btn-connexion">
                    🔐 Se connecter
                </button>

            </form>

        </div>

        <div class="carte-pied">
            &copy; 2024-2025 CES de Batcha — Tous droits réservés
        </div>

    </div>

</body>
</html>