<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);

// Get raw POST data
$data = json_decode(file_get_contents("php://input"), true);

// Basic validation
if (!$data) {
    die(json_encode(["success" => false, "message" => "No data received"]));
}

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

// Build SQL insert query
$query = "INSERT INTO albums (title, artist, genre, price, image, year, description, rating, number_of_likes, quantity_in_stock)
          VALUES ('$title', '$artist', '$genre', '$price', '$image', '$year', '$description', '$rating', '$number_of_likes', '$quantity_in_stock')";

$result = mysqli_query($link, $query);

if ($result) {
    echo json_encode(["success" => true, "message" => "Album inserted successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Insert failed: " . mysqli_error($link)]);
}
?>
