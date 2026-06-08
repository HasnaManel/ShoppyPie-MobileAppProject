<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$color=$_POST["color"];

$link = mysqli_connect($dbhost, $dbuser,$dbpassword, $db);

$sth = mysqli_query($link, "SELECT * FROM stationary  WHERE color LIKE '%$color%';");

$rows = array();
//Fetching rows from DB
while($r = mysqli_fetch_assoc($sth)) {
$rows[] = $r;
}
//Encoding results in json
print json_encode($rows);
?>