<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";


$link = mysqli_connect($dbhost, $dbuser,$dbpassword, $db);

$sth = mysqli_query($link, "SELECT id,title,brand,color,price,image,year,description,rating,number_of_likes,quantity_in_stock  FROM stationary ;");

$rows = array();
//Fetching rows from DB
while($r = mysqli_fetch_assoc($sth)) {
$rows[] = $r;
}
//Encoding results in json
print json_encode($rows);
?>