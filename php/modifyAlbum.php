<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);

// Get the JSON input
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data['id'])) {
    die(json_encode(["success" => false, "message" => "Missing album ID or data"]));
}

// Sanitize inputs
$id = $data['id'];
$title = $data['title'];
$artist = $data['artist'];
$genre = $data['genre'];
$price = $data['price'];
$image = $data['image'];
$year = $data['year'];
$description = $data['description'];
$rating = $data['rating'];
$number_of_likes = $data['number_of_likes'];
$quantity_in_stock = $data['quantity_in_stock'];

$query = "UPDATE albums SET 
    title = '$title',
    artist = '$artist',
    genre = '$genre',
    price = '$price',
    image = '$image',
    year = '$year',
    description = '$description',
    rating = '$rating',
    number_of_likes = '$number_of_likes',
    quantity_in_stock = '$quantity_in_stock'
    WHERE id = '$id'";

$result = mysqli_query($link, $query);

if ($result) {
    echo json_encode(["success" => true, "message" => "Album updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Update failed: " . mysqli_error($link)]);
}
?>

