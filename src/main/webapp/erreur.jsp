<%@ page contentType="text/html;charset=UTF-8" 
         isErrorPage="true" %>
<html>
<body>
    <h2>Erreur détectée :</h2>
    <p><%= exception != null ? exception.getMessage() : "Inconnue" %></p>
    <pre>
    <% if (exception != null) { 
           exception.printStackTrace(new java.io.PrintWriter(out)); 
       } %>
    </pre>
</body>
</html>