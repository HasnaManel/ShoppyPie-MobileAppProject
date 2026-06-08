<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$id=$_POST["id"];
$isLiked=$_POST["isLiked"];

$link = mysqli_connect($dbhost, $dbuser,$dbpassword, $db);
if ($isLiked == "1") {
    $query = "UPDATE albums SET number_of_likes = number_of_likes + 1 WHERE id = $id";
} else {
    $query = "UPDATE albums SET number_of_likes = number_of_likes - 1 WHERE id = $id";
}
$sth = mysqli_query($link, $query);

?>