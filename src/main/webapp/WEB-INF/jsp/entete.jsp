<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    .entete-officiel {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 25px;
        background: white;
        border-bottom: 2px solid #1a3c5e;
        font-family: 'Times New Roman', serif;
    }
    .entete-gauche,
    .entete-droite {
        flex: 1;
        font-size: 11px;
        text-transform: uppercase;
        font-weight: bold;
        line-height: 1.9;
        color: #1a1a1a;
    }
    .entete-droite { text-align: right; }
    .entete-centre {
        flex: 0 0 120px;
        text-align: center;
        padding: 0 15px;
    }
    .entete-centre img {
        width: 100px;
        height: 100px;
        object-fit: contain;
    }
    .entete-officiel .sep {
        color: #333;
        font-size: 10px;
        letter-spacing: 2px;
    }
</style>

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