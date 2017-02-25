<html>
  <body>
    <h1>Hello, <?php echo($_SERVER['REMOTE_USER']) ?></h1>
    <pre><?php print_r(array_map("htmlentities", apache_request_headers())); ?></pre>
    <a href="/example/redirect_uri?logout=http%3A%2F%2Fforgerock.xdct.net%2Floggedout.html">Logout</a>
<?php print("PHP"); ?>
  </body>
</html>
